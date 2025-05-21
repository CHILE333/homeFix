require('dotenv').config();
const express = require('express');
const { createClient } = require('@supabase/supabase-js');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const bodyParser = require('body-parser');
const cors = require('cors');

const app = express();
const PORT = process.env.PORT || 1000;

// Middleware
app.use(cors());
app.use(bodyParser.json());

// Supabase client setup
const supabaseUrl = process.env.SUPABASE_URL;
const supabaseKey = process.env.SUPABASE_KEY;
const supabase = createClient(supabaseUrl, supabaseKey);

// JWT configuration
const jwtSecret = process.env.JWT_SECRET || 'your_very_strong_secret_here_at_least_32_chars';
const tokenExpiry = process.env.TOKEN_EXPIRY || '1h';

// Updated validation functions
const validatePhone = (phone) => {
  const phoneRegex = /^(?:\+?[0-9]{8,15}|[0-9]{8,15})$/;
  return phoneRegex.test(phone);
};

const validateEmail = (email) => {
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  return emailRegex.test(email);
};

const validatePassword = (password) => {
  // At least 4 characters, containing both letters and numbers
  const passwordRegex = /^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{4,}$/;
  return passwordRegex.test(password);
};

// Helper function to generate JWT token
const generateToken = (userId, email) => {
  return jwt.sign({ userId, email }, jwtSecret, { expiresIn: tokenExpiry });
};

// Token blacklist helper functions
const addToBlacklist = async (token, userId) => {
  const decoded = jwt.decode(token);
  const expiresAt = new Date(decoded.exp * 1000);
  
  const { error } = await supabase
    .from('blacklisted_tokens')
    .insert([
      {
        token,
        expires_at: expiresAt.toISOString(),
        user_id: userId
      }
    ]);
  
  if (error) throw error;
};

const isTokenBlacklisted = async (token) => {
  const { data, error } = await supabase
    .from('blacklisted_tokens')
    .select('token')
    .eq('token', token)
    .maybeSingle();
  
  if (error) throw error;
  return !!data;
};

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

    // Check if token is blacklisted
    const isBlacklisted = await isTokenBlacklisted(token);
    if (isBlacklisted) {
      return res.status(401).json({ error: 'Token is no longer valid' });
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

// Updated register endpoint with enhanced validation
app.post('/register', async (req, res) => {
  try {
    const { full_name, email, phone, password, confirm_password } = req.body;

    // Validate input presence
    if (!full_name || !email || !phone || !password || !confirm_password) {
      return res.status(400).json({ error: 'All fields are required' });
    }

    // Validate phone format (8-15 digits, optionally starting with +)
    if (!validatePhone(phone)) {
      return res.status(400).json({ 
        error: 'Phone must be 8-15 digits, optionally starting with +' 
      });
    }

    // Validate email format
    if (!validateEmail(email)) {
      return res.status(400).json({ 
        error: 'Please enter a valid email address (e.g., user@example.com)' 
      });
    }

    // Validate password match
    if (password !== confirm_password) {
      return res.status(400).json({ error: 'Passwords do not match' });
    }

    // Validate password strength
    if (!validatePassword(password)) {
      return res.status(400).json({ 
        error: 'Password must be at least 4 characters and contain both letters and numbers' 
      });
    }

    // Check if user already exists in userss table
    const { data: existingUserByEmail, error: emailError } = await supabase
      .from('userss')
      .select('id')
      .eq('email', email)
      .maybeSingle();

    if (emailError) throw emailError;
    if (existingUserByEmail) {
      return res.status(400).json({ error: 'Email already in use' });
    }

    const { data: existingUserByPhone, error: phoneError } = await supabase
      .from('userss')
      .select('id')
      .eq('phone', phone)
      .maybeSingle();

    if (phoneError) throw phoneError;
    if (existingUserByPhone) {
      return res.status(400).json({ error: 'Phone number already in use' });
    }

    // Hash password
    const hashedPassword = await bcrypt.hash(password, 10);

    // Create user in userss table
    const { data: newUser, error: insertError } = await supabase
      .from('userss')
      .insert([
        {
          email,
          phone,
          full_name,
          encrypted_password: hashedPassword,
          is_verified: false,
          created_at: new Date().toISOString(),
          updated_at: new Date().toISOString()
        }
      ])
      .select('id, email, phone, full_name, created_at')
      .single();

    if (insertError) {
      console.error('Supabase insert error:', insertError);
      return res.status(500).json({ 
        error: 'Failed to create user',
        details: insertError.message 
      });
    }

    // Generate JWT token
    const token = generateToken(newUser.id, newUser.email);

    // Return success response
    res.status(201).json({
      message: 'User registered successfully',
      user: newUser,
      token
    });

  } catch (error) {
    console.error('Registration error:', error);
    res.status(500).json({ 
      error: 'Internal server error',
      details: error.message 
    });
  }
});

// Updated login endpoint with validation
app.post('/login', async (req, res) => {
  try {
    const { email_or_phone, password } = req.body;

    if (!email_or_phone || !password) {
      return res.status(400).json({ error: 'Email/Phone and password are required' });
    }

    // Validate all inputs format like emails, password and phone number 
    const isEmail = email_or_phone.includes('@');
    
    if (isEmail && !validateEmail(email_or_phone)) {
      return res.status(400).json({ 
        error: 'Please enter a valid email address (e.g., user@example.com)' 
      });
    }
    
    if (!isEmail && !validatePhone(email_or_phone)) {
      return res.status(400).json({ 
        error: 'Phone must be 8-15 digits, optionally starting with +' 
      });
    }

    const column = isEmail ? 'email' : 'phone';

    // Find user in userss table 
    const { data: user, error: findError } = await supabase
      .from('userss')
      .select('*')
      .eq(column, email_or_phone)
      .maybeSingle();

    if (findError) throw findError;
    if (!user) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }

    // Check password by comparing with the hashed password
    const isPasswordValid = await bcrypt.compare(password, user.encrypted_password);
    if (!isPasswordValid) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }

    // Generate JWT token
    const token = generateToken(user.id, user.email);

    // Update last login time
    await supabase
      .from('userss')
      .update({ last_login: new Date().toISOString() })
      .eq('id', user.id);

    // Return user data (excluding sensitive fields)
    const userData = {
      id: user.id,
      email: user.email,
      phone: user.phone,
      full_name: user.full_name,
      created_at: user.created_at
    };

    res.status(200).json({
      message: 'Login successful',
      user: userData,
      token
    });

  } catch (error) {
    console.error('Login error:', error);
    res.status(500).json({ 
      error: 'Internal server error',
      details: error.message 
    });
  }
});

// Logout endpoint
app.post('/logout', verifyToken, async (req, res) => {
  try {
    const token = req.headers.authorization.split(' ')[1];
    const decoded = jwt.decode(token);

    // Add token to blacklist
    await addToBlacklist(token, decoded.userId);

    res.status(200).json({ message: 'Successfully logged out' });
  } catch (error) {
    console.error('Logout error:', error);
    res.status(500).json({ 
      error: 'Internal server error',
      details: error.message 
    });
  }
});

// Protected route example using userss table our table is called userss where valid user tokens can be accesed
app.get('/profile', verifyToken, async (req, res) => {
  try {
    const token = req.headers.authorization.split(' ')[1];
    const decoded = jwt.verify(token, jwtSecret);
    
    // Get user data from userss table
    const { data: user, error } = await supabase
      .from('userss')
      .select('id, email, phone, full_name, created_at')
      .eq('id', decoded.userId)
      .single();

    if (error) throw error;
    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }

    res.status(200).json(user);
  } catch (error) {
    console.error('Profile error:', error);
    res.status(500).json({ 
      error: 'Internal server error',
      details: error.message 
    });
  }
});

// Health check endpoint 
app.get('/health', (req, res) => {
  res.status(200).json({ 
    status: 'OK',
    timestamp: new Date().toISOString(),
    supabase: supabaseUrl ? 'Configured' : 'Not configured'
  });
});

// Start server
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
  console.log(`Supabase connected to: ${supabaseUrl}`);
  console.log(`Using table: userss`);
});