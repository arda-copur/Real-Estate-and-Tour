const express = require('express');
const router = express.Router();
const authController = require('../controllers/authController');
const { authenticateToken } = require('../middlewares/authMiddleware');

// Kimlik doğrulama rotaları
router.post('/register', authController.register);
router.post('/login', authController.login);
router.get('/me', authenticateToken, authController.getCurrentUser);
router.post('/forgot-password', authController.forgotPassword);
router.post('/verify-token', authController.verifyToken);

module.exports = router; 