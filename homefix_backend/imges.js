require('dotenv').config();
const express = require('express');
const { createClient } = require('@supabase/supabase-js');
const multer = require('multer');
const path = require('path');
const fs = require('fs');
const { v4: uuidv4 } = require('uuid');
const jwt = require('jsonwebtoken');

const router = express.Router();

// Supabase client setup
const supabaseUrl = process.env.SUPABASE_URL;
const supabaseKey = process.env.SUPABASE_KEY;
const supabase = createClient(supabaseUrl, supabaseKey);

// JWT configuration
const jwtSecret = process.env.JWT_SECRET;

// Configure multer for image uploads only
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    const uploadDir = 'uploads/';
    if (!fs.existsSync(uploadDir)) {
      fs.mkdirSync(uploadDir);
    }
    cb(null, uploadDir);
  },
  filename: (req, file, cb) => {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    const ext = path.extname(file.originalname);
    cb(null, 'image-' + uniqueSuffix + ext);
  }
});

const upload = multer({ 
  storage: storage,
  limits: {
    fileSize: 10 * 1024 * 1024 // 10MB limit for images
  },
  fileFilter: (req, file, cb) => {
    const filetypes = /jpeg|jpg|png|gif/;
    const extname = filetypes.test(path.extname(file.originalname).toLowerCase());
    const mimetype = filetypes.test(file.mimetype);

    if (extname && mimetype) {
      return cb(null, true);
    } else {
      cb(new Error('Error: Only images (JPEG, JPG, PNG, GIF) are allowed!'));
    }
  }
});

// JWT verification middleware
const verifyToken = async (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;
    if (!authHeader) {
      return res.status(401).json({ error: 'Authorization header missing' });
    }

    const token = authHeader.split(' ')[1];
    if (!token) {
      return res.status(401).json({ error: 'Token not provided' });
    }

    jwt.verify(token, jwtSecret);
    next();
  } catch (error) {
    if (error.name === 'JsonWebTokenError') {
      return res.status(401).json({ error: 'Invalid token' });
    }
    if (error.name === 'TokenExpiredError') {
      return res.status(401).json({ error: 'Token expired' });
    }
    res.status(500).json({ error: 'Internal server error' });
  }
};

// Upload image endpoint
router.post('/upload', verifyToken, upload.single('image'), async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({ error: 'No image uploaded' });
    }

    const token = req.headers.authorization.split(' ')[1];
    const decoded = jwt.verify(token, jwtSecret);
    const userId = decoded.userId;

    const filePath = req.file.path;
    const fileExt = path.extname(req.file.originalname).toLowerCase();
    const fileName = `${uuidv4()}${fileExt}`;

    // Read the image file
    const fileData = fs.readFileSync(filePath);

    // Upload to Supabase Storage
    const { data, error } = await supabase.storage
      .from('images') // Using a dedicated images bucket
      .upload(`user-${userId}/${fileName}`, fileData, {
        contentType: `image/${fileExt.replace('.', '')}`,
        upsert: false
      });

    // Delete the temporary file
    fs.unlinkSync(filePath);

    if (error) {
      console.error('Supabase upload error:', error);
      return res.status(500).json({ error: 'Failed to upload image' });
    }

    // Get public URL
    const { data: { publicUrl } } = supabase.storage
      .from('images')
      .getPublicUrl(`user-${userId}/${fileName}`);

    // Save image metadata to database
    const { data: imageData, error: dbError } = await supabase
      .from('user_images')
      .insert([
        {
          user_id: userId,
          file_name: fileName,
          image_url: publicUrl,
          file_size: req.file.size,
          upload_date: new Date().toISOString()
        }
      ])
      .select('*')
      .single();

    if (dbError) {
      console.error('Database error:', dbError);
      return res.status(500).json({ error: 'Failed to save image metadata' });
    }

    res.status(201).json({
      message: 'Image uploaded successfully',
      image: imageData
    });

  } catch (error) {
    console.error('Upload error:', error);
    
    // Clean up temporary file if something went wrong
    if (req.file && fs.existsSync(req.file.path)) {
      fs.unlinkSync(req.file.path);
    }

    res.status(500).json({ 
      error: 'Internal server error',
      details: error.message 
    });
  }
});

// Get random images feed
router.get('/feed', verifyToken, async (req, res) => {
  try {
    const { limit = 10 } = req.query;
    const token = req.headers.authorization.split(' ')[1];
    const decoded = jwt.verify(token, jwtSecret);
    const userId = decoded.userId;

    // Get random images from different users
    const { data: images, error } = await supabase
      .from('user_images')
      .select(`
        id,
        image_url,
        upload_date,
        user:user_id (id, full_name)
      `)
      .neq('user_id', userId) // Exclude user's own images
      .order('upload_date', { ascending: false })
      .limit(parseInt(limit));

    if (error) throw error;

    // If we don't have enough images, include some from the current user
    if (images.length < limit) {
      const remaining = limit - images.length;
      const { data: userImages } = await supabase
        .from('user_images')
        .select(`
          id,
          image_url,
          upload_date,
          user:user_id (id, full_name)
        `)
        .eq('user_id', userId)
        .order('upload_date', { ascending: false })
        .limit(remaining);

      if (userImages) {
        images.push(...userImages);
      }
    }

    // Shuffle the images array to randomize the feed
    const shuffledImages = images.sort(() => 0.5 - Math.random());

    res.status(200).json({
      count: shuffledImages.length,
      images: shuffledImages
    });

  } catch (error) {
    console.error('Feed error:', error);
    res.status(500).json({ 
      error: 'Internal server error',
      details: error.message 
    });
  }
});

// Get user's own images
router.get('/my-images', verifyToken, async (req, res) => {
  try {
    const token = req.headers.authorization.split(' ')[1];
    const decoded = jwt.verify(token, jwtSecret);
    const userId = decoded.userId;

    const { data: images, error } = await supabase
      .from('user_images')
      .select('*')
      .eq('user_id', userId)
      .order('upload_date', { ascending: false });

    if (error) throw error;

    res.status(200).json({
      count: images.length,
      images
    });

  } catch (error) {
    console.error('My images error:', error);
    res.status(500).json({ 
      error: 'Internal server error',
      details: error.message 
    });
  }
});

// Delete image
router.delete('/:id', verifyToken, async (req, res) => {
  try {
    const token = req.headers.authorization.split(' ')[1];
    const decoded = jwt.verify(token, jwtSecret);
    const userId = decoded.userId;
    const imageId = req.params.id;

    // First get the image info to delete from storage
    const { data: image, error: fetchError } = await supabase
      .from('user_images')
      .select('*')
      .eq('id', imageId)
      .eq('user_id', userId)
      .single();

    if (fetchError) throw fetchError;
    if (!image) {
      return res.status(404).json({ error: 'Image not found or not owned by user' });
    }

    // Delete from storage
    const filePath = `user-${userId}/${image.file_name}`;
    const { error: storageError } = await supabase.storage
      .from('images')
      .remove([filePath]);

    if (storageError) throw storageError;

    // Delete from database
    const { error: dbError } = await supabase
      .from('user_images')
      .delete()
      .eq('id', imageId)
      .eq('user_id', userId);

    if (dbError) throw dbError;

    res.status(200).json({
      message: 'Image deleted successfully',
      deletedImage: image
    });

  } catch (error) {
    console.error('Delete image error:', error);
    res.status(500).json({ 
      error: 'Internal server error',
      details: error.message 
    });
  }
});

module.exports = router;