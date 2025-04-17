const express = require('express');
const router = express.Router();
const bookingController = require('../controllers/bookingController');
const { authenticateToken, isAdmin, isHost, isResourceOwner } = require('../middlewares/authMiddleware');

// Tüm rezervasyonları getir (Admin)
router.get('/', authenticateToken, isAdmin, bookingController.getAllBookings);

// Kullanıcının kendi rezervasyonlarını getir
router.get('/my-bookings', authenticateToken, bookingController.getMyBookings);

// Ev sahibinin/deneyim sahibinin rezervasyonlarını getir
router.get('/host-bookings', authenticateToken, isHost, bookingController.getHostBookings);

// Rezervasyon detaylarını getir
router.get('/:id', authenticateToken, bookingController.getBookingById);

// Yeni rezervasyon oluştur
router.post('/', authenticateToken, bookingController.createBooking);

// Rezervasyon durumunu güncelle
router.put('/:id/status', authenticateToken, bookingController.updateBookingStatus);

// Ödeme durumunu güncelle (Admin)
router.put('/:id/payment', authenticateToken, isAdmin, bookingController.updatePaymentStatus);

// Rezervasyonu sil (Admin)
router.delete('/:id', authenticateToken, isAdmin, bookingController.deleteBooking);

module.exports = router; 