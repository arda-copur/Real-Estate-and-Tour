const express = require('express');
const router = express.Router();
const userController = require('../controllers/userController');
const { authenticateToken, isAdmin, isResourceOwner } = require('../middlewares/authMiddleware');
const { uploadProfileImage, handleMulterError } = require('../middlewares/uploadMiddleware');

// Profil işlemleri
router.get('/profile', authenticateToken, userController.getUserProfile);
router.put('/profile', authenticateToken, userController.updateUserProfile);
router.post('/profile/image', authenticateToken, uploadProfileImage, handleMulterError, userController.uploadProfileImage);
router.put('/change-password', authenticateToken, userController.changePassword);

// Kullanıcı favorileri
router.get('/saved/properties', authenticateToken, userController.getSavedProperties);
router.post('/saved/properties/:propertyId', authenticateToken, userController.saveProperty);
router.delete('/saved/properties/:propertyId', authenticateToken, userController.removeSavedProperty);

router.get('/saved/experiences', authenticateToken, userController.getSavedExperiences);
router.post('/saved/experiences/:experienceId', authenticateToken, userController.saveExperience);
router.delete('/saved/experiences/:experienceId', authenticateToken, userController.removeSavedExperience);

// Herkese açık kullanıcı bilgileri
router.get('/public/:userId', userController.getPublicUserProfile);

// Yönetici işlemleri
router.get('/:userId', authenticateToken, isResourceOwner('userId'), userController.getUserById);
router.put('/:userId/role', authenticateToken, isAdmin, userController.updateUserRole);

module.exports = router; 