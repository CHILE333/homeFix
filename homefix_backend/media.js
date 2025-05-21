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
const jwtSecret = process.env.JWT_SECRET || 'your_very_strong_secret_here_at_least_32_chars';

// Configure multer for file uploads
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
    cb(null, file.fieldname + '-' + uniqueSuffix + ext);
  }
});

const upload = multer({ 
  storage: storage,
  limits: {
    fileSize: 100 * 1024 * 1024 // 100MB limit
  },
  fileFilter: (req, file, cb) => {
    const filetypes = /jpeg|jpg|png|gif|mp4|mov|avi|mkv/;
    const extname = filetypes.test(path.extname(file.originalname).toLowerCase());
    const mimetype = filetypes.test(file.mimetype);

    if (extname && mimetype) {
      return cb(null, true);
    } else {
      cb(new Error('Error: Only images (JPEG, JPG, PNG, GIF) and videos (MP4, MOV, AVI, MKV) are allowed!'));
    }
  }
});

// JWT verification middleware (similar to your index.js)
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

    // Verify token
    jwt.verify(token, jwtSecret);
    next();
  } catch (error) {
    if (error.name === 'JsonWebTokenError') {
      return res.status(401).json({ error: 'Invalid token' });
    }
    if (error.name === 'TokenExpiredError') {
      return res.status(401).json({ error: 'Token expired' });
    }
    throw error;
  }
};

// Upload media endpoint (both images and videos)
router.post('/upload', verifyToken, upload.single('media'), async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({ error: 'No file uploaded' });
    }

    const token = req.headers.authorization.split(' ')[1];
    const decoded = jwt.verify(token, jwtSecret);
    const userId = decoded.userId;

    const filePath = req.file.path;
    const fileExt = path.extname(req.file.originalname).toLowerCase();
    const isVideo = ['.mp4', '.mov', '.avi', '.mkv'].includes(fileExt);
    const contentType = isVideo ? 'video/mp4' : `image/${fileExt.replace('.', '')}`;

    // Generate a unique filename for Supabase storage
    const fileName = `${uuidv4()}${fileExt}`;
    const folder = isVideo ? 'videos' : 'images';

    // Read the file
    const fileData = fs.readFileSync(filePath);

    // Upload to Supabase Storage
    const { data, error } = await supabase.storage
      .from('media') // Your Supabase storage bucket name
      .upload(`${folder}/${fileName}`, fileData, {
        contentType: contentType,
        upsert: false
      });

    // Delete the temporary file
    fs.unlinkSync(filePath);

    if (error) {
      console.error('Supabase upload error:', error);
      return res.status(500).json({ error: 'Failed to upload file to storage' });
    }

    // Get public URL
    const { data: { publicUrl } } = supabase.storage
      .from('media')
      .getPublicUrl(`${folder}/${fileName}`);

    // Save media metadata to database
    const { data: mediaData, error: dbError } = await supabase
      .from('media')
      .insert([
        {
          user_id: userId,
          file_name: fileName,
          file_url: publicUrl,
          file_type: isVideo ? 'video' : 'image',
          file_size: req.file.size,
          mime_type: contentType,
          upload_date: new Date().toISOString()
        }
      ])
      .select('*')
      .single();

    if (dbError) {
      console.error('Database error:', dbError);
      return res.status(500).json({ error: 'Failed to save media metadata' });
    }

    res.status(201).json({
      message: 'Media uploaded successfully',
      media: mediaData
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

// Get random media feed (similar to TikTok/Instagram)
router.get('/feed', verifyToken, async (req, res) => {
  try {
    const { limit = 10 } = req.query;
    const token = req.headers.authorization.split(' ')[1];
    const decoded = jwt.verify(token, jwtSecret);
    const userId = decoded.userId;

    // Get random media from different users
    const { data: media, error } = await supabase
      .from('media')
      .select(`
        id,
        file_url,
        file_type,
        upload_date,
        user:user_id (id, full_name)
      `)
      .neq('user_id', userId) // Exclude user's own media
      .order('upload_date', { ascending: false })
      .limit(parseInt(limit));

    if (error) throw error;

    // If we don't have enough media, include some from the current user
    if (media.length < limit) {
      const remaining = limit - media.length;
      const { data: userMedia } = await supabase
        .from('media')
        .select(`
          id,
          file_url,
          file_type,
          upload_date,
          user:user_id (id, full_name)
        `)
        .eq('user_id', userId)
        .order('upload_date', { ascending: false })
        .limit(remaining);

      if (userMedia) {
        media.push(...userMedia);
      }
    }

    // Shuffle the media array to randomize the feed
    const shuffledMedia = media.sort(() => 0.5 - Math.random());

    res.status(200).json({
      count: shuffledMedia.length,
      media: shuffledMedia
    });

  } catch (error) {
    console.error('Feed error:', error);
    res.status(500).json({ 
      error: 'Internal server error',
      details: error.message 
    });
  }
});

// Get user's own media
router.get('/my-media', verifyToken, async (req, res) => {
  try {
    const token = req.headers.authorization.split(' ')[1];
    const decoded = jwt.verify(token, jwtSecret);
    const userId = decoded.userId;

    const { data: media, error } = await supabase
      .from('media')
      .select('*')
      .eq('user_id', userId)
      .order('upload_date', { ascending: false });

    if (error) throw error;

    res.status(200).json({
      count: media.length,
      media
    });

  } catch (error) {
    console.error('My media error:', error);
    res.status(500).json({ 
      error: 'Internal server error',
      details: error.message 
    });
  }
});

// Delete media
router.delete('/:id', verifyToken, async (req, res) => {
  try {
    const token = req.headers.authorization.split(' ')[1];
    const decoded = jwt.verify(token, jwtSecret);
    const userId = decoded.userId;
    const mediaId = req.params.id;

    // First get the media info to delete from storage
    const { data: media, error: fetchError } = await supabase
      .from('media')
      .select('*')
      .eq('id', mediaId)
      .eq('user_id', userId)
      .single();

    if (fetchError) throw fetchError;
    if (!media) {
      return res.status(404).json({ error: 'Media not found or not owned by user' });
    }

    // Delete from storage
    const filePath = `${media.file_type === 'video' ? 'videos' : 'images'}/${media.file_name}`;
    const { error: storageError } = await supabase.storage
      .from('media')
      .remove([filePath]);

    if (storageError) throw storageError;

    // Delete from database
    const { error: dbError } = await supabase
      .from('media')
      .delete()
      .eq('id', mediaId)
      .eq('user_id', userId);

    if (dbError) throw dbError;

    res.status(200).json({
      message: 'Media deleted successfully',
      deletedMedia: media
    });

  } catch (error) {
    console.error('Delete media error:', error);
    res.status(500).json({ 
      error: 'Internal server error',
      details: error.message 
    });
  }
});

module.exports = router;