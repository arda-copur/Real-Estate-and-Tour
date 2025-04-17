const Booking = require('../models/Booking');
const Property = require('../models/Property');
const Experience = require('../models/Experience');
const User = require('../models/User');

/**
 * Get all bookings (for admin)
 * @route GET /api/bookings
 * @access Private (Admin)
 */
exports.getAllBookings = async (req, res) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 10;
    const skip = (page - 1) * limit;

    const bookings = await Booking.find()
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(limit)
      .populate('user', 'firstName lastName profileImage')
      .populate('property', 'title location')
      .populate('experience', 'title location');

    const total = await Booking.countDocuments();

    res.json({
      bookings,
      page,
      pages: Math.ceil(total / limit),
      total,
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Sunucu hatası' });
  }
};

/**
 * Get user's bookings (as a guest)
 * @route GET /api/bookings/my-bookings
 * @access Private
 */
exports.getMyBookings = async (req, res) => {
  try {
    const bookings = await Booking.find({ user: req.user.id })
      .sort({ createdAt: -1 })
      .populate('property', 'title location images')
      .populate('experience', 'title location image');

    res.json(bookings);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Sunucu hatası' });
  }
};

/**
 * Get bookings for property or experience owner (host)
 * @route GET /api/bookings/host-bookings
 * @access Private (Host/Admin)
 */
exports.getHostBookings = async (req, res) => {
  try {
    // Kullanıcının sahip olduğu mülkleri ve deneyimleri bulma
    const properties = await Property.find({ host: req.user.id }).select('_id');
    const experiences = await Experience.find({ host: req.user.id }).select('_id');

    const propertyIds = properties.map((p) => p._id);
    const experienceIds = experiences.map((e) => e._id);

    // Mülk ve deneyim rezervasyonlarını bulma
    const bookings = await Booking.find({
      $or: [
        { property: { $in: propertyIds } },
        { experience: { $in: experienceIds } },
      ],
    })
      .sort({ createdAt: -1 })
      .populate('user', 'firstName lastName profileImage')
      .populate('property', 'title location images')
      .populate('experience', 'title location image');

    res.json(bookings);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Sunucu hatası' });
  }
};

/**
 * Get booking by ID
 * @route GET /api/bookings/:id
 * @access Private (Owner of booking, property owner, admin)
 */
exports.getBookingById = async (req, res) => {
  try {
    const booking = await Booking.findById(req.params.id)
      .populate('user', 'firstName lastName email phone profileImage')
      .populate('property', 'title location images host')
      .populate('experience', 'title location image host');

    if (!booking) {
      return res.status(404).json({ message: 'Rezervasyon bulunamadı' });
    }

    res.json(booking);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Sunucu hatası' });
  }
};

/**
 * Create a new booking
 * @route POST /api/bookings
 * @access Private
 */
exports.createBooking = async (req, res) => {
  try {
    const {
      bookingType,
      propertyId,
      experienceId,
      startDate,
      endDate,
      timeSlot,
      guestCount,
      notes,
    } = req.body;

    // Gerekli alanların kontrolü
    if (!bookingType || (bookingType !== 'property' && bookingType !== 'experience')) {
      return res.status(400).json({ message: 'Geçerli bir rezervasyon türü belirtilmeli' });
    }

    if (bookingType === 'property' && !propertyId) {
      return res.status(400).json({ message: 'Mülk ID gerekli' });
    }

    if (bookingType === 'experience' && !experienceId) {
      return res.status(400).json({ message: 'Deneyim ID gerekli' });
    }

    if (!startDate) {
      return res.status(400).json({ message: 'Başlangıç tarihi gerekli' });
    }

    if (bookingType === 'property' && !endDate) {
      return res.status(400).json({ message: 'Bitiş tarihi gerekli' });
    }

    if (bookingType === 'experience' && (!timeSlot || !timeSlot.startTime || !timeSlot.endTime)) {
      return res.status(400).json({ message: 'Zaman dilimi gerekli' });
    }

    if (!guestCount || guestCount < 1) {
      return res.status(400).json({ message: 'Geçerli bir misafir sayısı belirtilmeli' });
    }

    // Toplam fiyat hesaplama
    let totalPrice = 0;
    let currency = '₺';
    let item;

    if (bookingType === 'property') {
      item = await Property.findById(propertyId);
      if (!item) {
        return res.status(404).json({ message: 'Mülk bulunamadı' });
      }

      // Başlangıç ve bitiş tarihleri arasındaki gün sayısını hesapla
      const start = new Date(startDate);
      const end = new Date(endDate);
      const dayDiff = Math.ceil((end - start) / (1000 * 60 * 60 * 24));

      // Toplam fiyatı hesapla
      totalPrice = item.price * dayDiff;
      currency = item.currency || '₺';
    } else {
      item = await Experience.findById(experienceId);
      if (!item) {
        return res.status(404).json({ message: 'Deneyim bulunamadı' });
      }

      // Deneyim için fiyat doğrudan atanır
      totalPrice = item.price;
      currency = item.currency || '₺';
    }

    // Misafir sayısına göre kontrol
    if (item.maxGuests < guestCount) {
      return res.status(400).json({ 
        message: `Maksimum misafir sayısı ${item.maxGuests} olmalıdır` 
      });
    }

    // Yeni rezervasyon oluştur
    const newBooking = new Booking({
      user: req.user.id,
      bookingType,
      property: bookingType === 'property' ? propertyId : undefined,
      experience: bookingType === 'experience' ? experienceId : undefined,
      startDate,
      endDate: bookingType === 'property' ? endDate : undefined,
      timeSlot: bookingType === 'experience' ? timeSlot : undefined,
      guestCount,
      totalPrice,
      currency,
      notes,
      status: 'pending',
      paymentStatus: 'pending',
    });

    const booking = await newBooking.save();

    res.status(201).json({
      booking,
      message: 'Rezervasyon talebi başarıyla oluşturuldu',
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Sunucu hatası' });
  }
};

/**
 * Update booking status
 * @route PUT /api/bookings/:id/status
 * @access Private (Property/Experience owner, Admin)
 */
exports.updateBookingStatus = async (req, res) => {
  try {
    const { status } = req.body;

    if (!status || !['pending', 'confirmed', 'completed', 'cancelled'].includes(status)) {
      return res.status(400).json({ message: 'Geçerli bir durum belirtilmeli' });
    }

    const booking = await Booking.findById(req.params.id);
    if (!booking) {
      return res.status(404).json({ message: 'Rezervasyon bulunamadı' });
    }

    // İptal edilme nedeni ve tarihi kontrolü
    if (status === 'cancelled') {
      const { cancellationReason } = req.body;
      if (!cancellationReason) {
        return res.status(400).json({ message: 'İptal nedeni belirtilmeli' });
      }
      booking.cancellationReason = cancellationReason;
      booking.cancellationDate = new Date();
    }

    booking.status = status;
    await booking.save();

    res.json({
      booking,
      message: `Rezervasyon durumu "${status}" olarak güncellendi`,
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Sunucu hatası' });
  }
};

/**
 * Update payment status
 * @route PUT /api/bookings/:id/payment
 * @access Private (Admin)
 */
exports.updatePaymentStatus = async (req, res) => {
  try {
    const { paymentStatus, paymentMethod } = req.body;

    if (!paymentStatus || !['pending', 'paid', 'refunded', 'failed'].includes(paymentStatus)) {
      return res.status(400).json({ message: 'Geçerli bir ödeme durumu belirtilmeli' });
    }

    const booking = await Booking.findById(req.params.id);
    if (!booking) {
      return res.status(404).json({ message: 'Rezervasyon bulunamadı' });
    }

    booking.paymentStatus = paymentStatus;
    if (paymentMethod) {
      booking.paymentMethod = paymentMethod;
    }
    await booking.save();

    res.json({
      booking,
      message: `Ödeme durumu "${paymentStatus}" olarak güncellendi`,
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Sunucu hatası' });
  }
};

/**
 * Delete booking
 * @route DELETE /api/bookings/:id
 * @access Private (Admin)
 */
exports.deleteBooking = async (req, res) => {
  try {
    const booking = await Booking.findById(req.params.id);
    if (!booking) {
      return res.status(404).json({ message: 'Rezervasyon bulunamadı' });
    }

    await booking.remove();

    res.json({ message: 'Rezervasyon başarıyla silindi' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Sunucu hatası' });
  }
}; 