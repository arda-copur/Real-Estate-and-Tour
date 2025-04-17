const jwt = require('jsonwebtoken');
const User = require('../models/User');

/**
 * Middleware to authenticate users with JWT token
 */
//kullanıcının giriş yapıp yapmadığını ve geçerli bir token ile oturum açıp açmadığını kontrol eder.
exports.authenticateToken = async (req, res, next) => {
  try {
    // Get token from Authorization header
    const authHeader = req.headers.authorization;
    const token = authHeader && authHeader.split(' ')[1];
    
    if (!token) {
      return res.status(401).json({ message: 'Authentication failed: No token provided' });
    }
    
    // Verify token
    jwt.verify(token, process.env.JWT_SECRET, async (err, decoded) => {
      if (err) {
        return res.status(403).json({ message: 'Authentication failed: Invalid token' });
      }
      
      // Get user from database
      const user = await User.findById(decoded.id);
      
      if (!user) {
        return res.status(404).json({ message: 'User not found' });
      }
      
      // Attach user to request object
      req.user = user;
      next();
    });
  } catch (error) {
    console.error('Auth middleware error:', error);
    res.status(500).json({ message: 'Server error during authentication' });
  }
};

/**
 * Middleware to check if user is a host
 */
exports.isHost = (req, res, next) => {
  if (req.user) {
    next();
  } else {
    res.status(403).json({ message: 'Access denied: Authentication required' });
  }
};

/**
 * Middleware to check if user is an admin
 */
//Kullanıcının admin (yönetici) rolüne sahip olup olmadığını kontrol eder.
exports.isAdmin = (req, res, next) => {
  if (req.user && req.user.role === 'admin') {
    next();
  } else {
    res.status(403).json({ message: 'Access denied: Admin privileges required' });
  }
};

/**
 * Middleware to check if user is the resource owner
 */
//Kullanıcının sahip olduğu bir kaynağa (örneğin, kullanıcıya ait bir veri) erişim hakkı olup olmadığını kontrol eder.
exports.isResourceOwner = (userIdField) => {
  return (req, res, next) => {
    const resourceUserId = req.params[userIdField] || req.body[userIdField];
    
    if (!resourceUserId) {
      return res.status(400).json({ message: 'User ID field is missing' });
    }
    
    if (req.user.role === 'admin' || req.user.id.toString() === resourceUserId.toString()) {
      next();
    } else {
      res.status(403).json({ message: 'Access denied: Not the resource owner' });
    }
  };
}; 