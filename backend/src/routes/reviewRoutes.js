const express = require('express');
const router = express.Router();
const reviewController = require('../controllers/reviewController');
const { authenticateToken, isHost, isAdmin } = require('../middlewares/authMiddleware');

// Genel erişilebilir rotalar
router.get('/', reviewController.getAllReviews);
router.get('/:id', reviewController.getReviewById);

// Kimlik doğrulama gerektiren rotalar
router.post('/property/:propertyId', authenticateToken, reviewController.createPropertyReview);
router.post('/experience/:experienceId', authenticateToken, reviewController.createExperienceReview);
router.post('/host/:hostId', authenticateToken, reviewController.createHostReview);
router.post('/guest/:guestId', authenticateToken, isHost, reviewController.createGuestReview);

// Yorum yanıtlama
router.post('/:id/respond', authenticateToken, reviewController.respondToReview);

// Yönetici işlemleri
router.put('/:id/visibility', authenticateToken, isAdmin, reviewController.updateReviewVisibility);

// Silme işlemi (yazar veya admin)
router.delete('/:id', authenticateToken, reviewController.deleteReview);

module.exports = router; 