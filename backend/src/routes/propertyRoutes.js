const express = require('express');
const router = express.Router();
const propertyController = require('../controllers/propertyController');
const { authenticateToken, isHost } = require('../middlewares/authMiddleware');
const { uploadPropertyImages, handleMulterError } = require('../middlewares/uploadMiddleware');

// Genel erişilebilir rotalar
router.get('/', propertyController.getAllProperties);
router.get('/:id', propertyController.getPropertyById);

// Kimlik doğrulama gerektiren rotalar
router.get('/host/my-properties', authenticateToken, isHost, propertyController.getMyProperties);

// Mülk oluşturma ve güncelleme
router.post('/', 
  authenticateToken, 
  uploadPropertyImages, 
  handleMulterError, 
  propertyController.createProperty
);

router.put('/:id', 
  authenticateToken, 
  propertyController.updateProperty
);

// Resim yükleme ve silme
router.post('/:id/images', 
  authenticateToken, 
  uploadPropertyImages, 
  handleMulterError, 
  propertyController.uploadPropertyImages
);

router.delete('/:id/images/:imageIndex', 
  authenticateToken, 
  propertyController.deletePropertyImage
);

// Mülk silme
router.delete('/:id', 
  authenticateToken, 
  propertyController.deleteProperty
);

module.exports = router; 