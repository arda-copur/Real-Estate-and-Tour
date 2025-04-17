const express = require('express');
const router = express.Router();
const experienceController = require('../controllers/experienceController');
const { authenticateToken, isHost } = require('../middlewares/authMiddleware');
const { uploadExperienceImage, handleMulterError } = require('../middlewares/uploadMiddleware');

// Genel erişilebilir rotalar
router.get('/', experienceController.getAllExperiences);
router.get('/categories/:category', experienceController.getExperiencesByCategory);
router.get('/:id', experienceController.getExperienceById);

// Kimlik doğrulama gerektiren rotalar
router.get('/host/my-experiences', authenticateToken, isHost, experienceController.getMyExperiences);

// Deneyim oluşturma ve güncelleme
router.post('/', 
  authenticateToken, 
  uploadExperienceImage, 
  handleMulterError, 
  experienceController.createExperience
);

router.put('/:id', 
  authenticateToken, 
  experienceController.updateExperience
);

// Resim yükleme
router.post('/:id/image', 
  authenticateToken, 
  uploadExperienceImage, 
  handleMulterError, 
  experienceController.uploadExperienceImage
);

// Program ekleme ve kaldırma
router.post('/:id/schedule', 
  authenticateToken, 
  isHost, 
  experienceController.addScheduleTime
);

router.delete('/:id/schedule/:scheduleId', 
  authenticateToken, 
  isHost, 
  experienceController.removeScheduleTime
);

// Deneyim silme
router.delete('/:id', 
  authenticateToken, 
  experienceController.deleteExperience
);

module.exports = router; 