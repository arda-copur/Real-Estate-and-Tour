const Review = require('../models/Review');
const Property = require('../models/Property');
const Experience = require('../models/Experience');
const Booking = require('../models/Booking');
const User = require('../models/User');

/**
 * Get all reviews
 * @route GET /api/reviews
 * @access Public
 */
exports.getAllReviews = async (req, res) => {
  try {
    const { type, itemId, page = 1, limit = 10 } = req.query;
    
    // Build filter object
    const filter = { isPublic: true };
    if (type && itemId) {
      if (type === 'property') {
        filter.property = itemId;
        filter.reviewType = 'property';
      } else if (type === 'experience') {
        filter.experience = itemId;
        filter.reviewType = 'experience';
      } else if (type === 'host') {
        filter.host = itemId;
        filter.reviewType = 'host';
      } else if (type === 'guest') {
        filter.guest = itemId;
        filter.reviewType = 'guest';
      }
    }
    
    // Pagination
    const skip = (parseInt(page) - 1) * parseInt(limit);
    
    // Get reviews
    const reviews = await Review.find(filter)
      .populate('user', 'firstName lastName username profileImage')
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(parseInt(limit));
    
    // Get total count
    const total = await Review.countDocuments(filter);
    
    res.json({
      reviews,
      currentPage: parseInt(page),
      totalPages: Math.ceil(total / parseInt(limit)),
      total
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Sunucu hatası' });
  }
};

/**
 * Get review by ID
 * @route GET /api/reviews/:id
 * @access Public
 */
exports.getReviewById = async (req, res) => {
  try {
    const review = await Review.findById(req.params.id)
      .populate('user', 'firstName lastName username profileImage');
    
    if (!review) {
      return res.status(404).json({ message: 'Yorum bulunamadı' });
    }
    
    // Only return public reviews or if the user is the author or admin
    if (!review.isPublic && 
        (!req.user || (req.user.id !== review.user.id && req.user.role !== 'admin'))) {
      return res.status(403).json({ message: 'Bu yoruma erişim izniniz yok' });
    }
    
    res.json(review);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Sunucu hatası' });
  }
};

/**
 * Create property review
 * @route POST /api/reviews/property/:propertyId
 * @access Private
 */
exports.createPropertyReview = async (req, res) => {
  try {
    const { rating, comment, bookingId } = req.body;
    const propertyId = req.params.propertyId;
    
    // Validate required fields
    if (!rating || !comment) {
      return res.status(400).json({ message: 'Puan ve yorum zorunludur' });
    }
    
    // Check if property exists
    const property = await Property.findById(propertyId);
    if (!property) {
      return res.status(404).json({ message: 'Mülk bulunamadı' });
    }
    
    // Check if the user has a booking for this property
    let booking;
    if (bookingId) {
      booking = await Booking.findById(bookingId);
      if (!booking || booking.user.toString() !== req.user.id || 
          booking.property.toString() !== propertyId) {
        return res.status(400).json({ message: 'Geçersiz rezervasyon' });
      }
      
      // Check if user already reviewed this booking
      if (booking.hasReview) {
        return res.status(400).json({ message: 'Bu rezervasyon için zaten yorum yapmışsınız' });
      }
    } else {
      booking = await Booking.findOne({
        user: req.user.id,
        property: propertyId,
        status: 'completed'
      });
      
      if (!booking) {
        return res.status(400).json({ 
          message: 'Yorum yapabilmek için bu mülkte tamamlanmış bir konaklamanız olmalıdır' 
        });
      }
    }
    
    // Create review
    const review = new Review({
      user: req.user.id,
      reviewType: 'property',
      property: propertyId,
      booking: booking._id,
      host: property.host,
      rating,
      comment,
      isPublic: true
    });
    
    await review.save();
    
    // Update booking
    booking.hasReview = true;
    await booking.save();
    
    // Update property with review reference
    await Property.findByIdAndUpdate(propertyId, {
      $push: { reviews: review._id }
    });
    
    res.status(201).json({ 
      review,
      message: 'Yorumunuz başarıyla eklendi' 
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Sunucu hatası' });
  }
};

/**
 * Create experience review
 * @route POST /api/reviews/experience/:experienceId
 * @access Private
 */
exports.createExperienceReview = async (req, res) => {
  try {
    const { rating, comment, bookingId } = req.body;
    const experienceId = req.params.experienceId;
    
    // Validate required fields
    if (!rating || !comment) {
      return res.status(400).json({ message: 'Puan ve yorum zorunludur' });
    }
    
    // Check if experience exists
    const experience = await Experience.findById(experienceId);
    if (!experience) {
      return res.status(404).json({ message: 'Deneyim bulunamadı' });
    }
    
    // Check if the user has a booking for this experience
    let booking;
    if (bookingId) {
      booking = await Booking.findById(bookingId);
      if (!booking || booking.user.toString() !== req.user.id || 
          booking.experience.toString() !== experienceId) {
        return res.status(400).json({ message: 'Geçersiz rezervasyon' });
      }
      
      // Check if user already reviewed this booking
      if (booking.hasReview) {
        return res.status(400).json({ message: 'Bu rezervasyon için zaten yorum yapmışsınız' });
      }
    } else {
      booking = await Booking.findOne({
        user: req.user.id,
        experience: experienceId,
        status: 'completed'
      });
      
      if (!booking) {
        return res.status(400).json({ 
          message: 'Yorum yapabilmek için bu deneyime katılmış olmalısınız' 
        });
      }
    }
    
    // Create review
    const review = new Review({
      user: req.user.id,
      reviewType: 'experience',
      experience: experienceId,
      booking: booking._id,
      host: experience.host,
      rating,
      comment,
      isPublic: true
    });
    
    await review.save();
    
    // Update booking
    booking.hasReview = true;
    await booking.save();
    
    // Update experience with review reference
    await Experience.findByIdAndUpdate(experienceId, {
      $push: { reviews: review._id }
    });
    
    res.status(201).json({ 
      review,
      message: 'Yorumunuz başarıyla eklendi' 
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Sunucu hatası' });
  }
};

/**
 * Create host review
 * @route POST /api/reviews/host/:hostId
 * @access Private
 */
exports.createHostReview = async (req, res) => {
  try {
    const { rating, comment, bookingId } = req.body;
    const hostId = req.params.hostId;
    
    // Validate required fields
    if (!rating || !comment) {
      return res.status(400).json({ message: 'Puan ve yorum zorunludur' });
    }
    
    // Check if host exists
    const host = await User.findById(hostId);
    if (!host || host.role !== 'host') {
      return res.status(404).json({ message: 'Ev sahibi bulunamadı' });
    }
    
    // Check if the user has a booking with this host
    let booking;
    if (bookingId) {
      booking = await Booking.findById(bookingId);
      
      // Verify it's a valid booking by this user with this host
      let isValidBooking = false;
      if (booking && booking.user.toString() === req.user.id) {
        if (booking.bookingType === 'property') {
          const property = await Property.findById(booking.property);
          isValidBooking = property && property.host.toString() === hostId;
        } else if (booking.bookingType === 'experience') {
          const experience = await Experience.findById(booking.experience);
          isValidBooking = experience && experience.host.toString() === hostId;
        }
      }
      
      if (!isValidBooking) {
        return res.status(400).json({ message: 'Geçersiz rezervasyon' });
      }
    } else {
      // Find any completed booking with this host
      const properties = await Property.find({ host: hostId });
      const experiences = await Experience.find({ host: hostId });
      
      const propertyIds = properties.map(p => p._id);
      const experienceIds = experiences.map(e => e._id);
      
      booking = await Booking.findOne({
        user: req.user.id,
        status: 'completed',
        $or: [
          { property: { $in: propertyIds } },
          { experience: { $in: experienceIds } }
        ]
      });
      
      if (!booking) {
        return res.status(400).json({ 
          message: 'Yorum yapabilmek için ev sahibinin bir ev veya deneyimini kullanmış olmalısınız' 
        });
      }
    }
    
    // Create review
    const review = new Review({
      user: req.user.id,
      reviewType: 'host',
      host: hostId,
      booking: booking._id,
      rating,
      comment,
      isPublic: true
    });
    
    await review.save();
    
    res.status(201).json({ 
      review,
      message: 'Yorumunuz başarıyla eklendi' 
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Sunucu hatası' });
  }
};

/**
 * Create guest review (by host)
 * @route POST /api/reviews/guest/:guestId
 * @access Private (Host)
 */
exports.createGuestReview = async (req, res) => {
  try {
    const { rating, comment, bookingId } = req.body;
    const guestId = req.params.guestId;
    
    // Validate required fields
    if (!rating || !comment) {
      return res.status(400).json({ message: 'Puan ve yorum zorunludur' });
    }
    
    // Check if guest exists
    const guest = await User.findById(guestId);
    if (!guest) {
      return res.status(404).json({ message: 'Misafir bulunamadı' });
    }
    
    // Check if the host has a booking with this guest
    let booking;
    if (bookingId) {
      booking = await Booking.findById(bookingId);
      
      // Verify it's a valid booking by this guest with this host
      let isValidBooking = false;
      if (booking && booking.user.toString() === guestId) {
        if (booking.bookingType === 'property') {
          const property = await Property.findById(booking.property);
          isValidBooking = property && property.host.toString() === req.user.id;
        } else if (booking.bookingType === 'experience') {
          const experience = await Experience.findById(booking.experience);
          isValidBooking = experience && experience.host.toString() === req.user.id;
        }
      }
      
      if (!isValidBooking) {
        return res.status(400).json({ message: 'Geçersiz rezervasyon' });
      }
    } else {
      // Find any completed booking by this guest to one of the host's listings
      const properties = await Property.find({ host: req.user.id });
      const experiences = await Experience.find({ host: req.user.id });
      
      const propertyIds = properties.map(p => p._id);
      const experienceIds = experiences.map(e => e._id);
      
      booking = await Booking.findOne({
        user: guestId,
        status: 'completed',
        $or: [
          { property: { $in: propertyIds } },
          { experience: { $in: experienceIds } }
        ]
      });
      
      if (!booking) {
        return res.status(400).json({ 
          message: 'Yorum yapabilmek için misafirin bir ev veya deneyiminizi kullanmış olması gerekir' 
        });
      }
    }
    
    // Create review
    const review = new Review({
      user: req.user.id,
      reviewType: 'guest',
      guest: guestId,
      booking: booking._id,
      rating,
      comment,
      isPublic: true
    });
    
    await review.save();
    
    res.status(201).json({ 
      review,
      message: 'Yorumunuz başarıyla eklendi' 
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Sunucu hatası' });
  }
};

/**
 * Respond to a review (as host)
 * @route POST /api/reviews/:id/respond
 * @access Private (Host)
 */
exports.respondToReview = async (req, res) => {
  try {
    const { comment } = req.body;
    const reviewId = req.params.id;
    
    if (!comment) {
      return res.status(400).json({ message: 'Yorum yapmalısınız' });
    }
    
    // Find the review
    const review = await Review.findById(reviewId);
    if (!review) {
      return res.status(404).json({ message: 'Yorum bulunamadı' });
    }
    
    // Check if user is the host of the reviewed item
    let isHost = false;
    if (review.reviewType === 'property' && review.property) {
      const property = await Property.findById(review.property);
      isHost = property && property.host.toString() === req.user.id;
    } else if (review.reviewType === 'experience' && review.experience) {
      const experience = await Experience.findById(review.experience);
      isHost = experience && experience.host.toString() === req.user.id;
    } else if (review.reviewType === 'host') {
      isHost = review.host.toString() === req.user.id;
    }
    
    if (!isHost && req.user.role !== 'admin') {
      return res.status(403).json({ message: 'Bu işlemi yapmaya yetkiniz yok' });
    }
    
    // Add response
    review.response = {
      comment,
      date: new Date()
    };
    
    await review.save();
    
    res.json({ 
      review,
      message: 'Yanıtınız başarıyla eklendi' 
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Sunucu hatası' });
  }
};

/**
 * Update review visibility (admin only)
 * @route PUT /api/reviews/:id/visibility
 * @access Private (Admin)
 */
exports.updateReviewVisibility = async (req, res) => {
  try {
    const { isPublic } = req.body;
    
    if (isPublic === undefined) {
      return res.status(400).json({ message: 'Görünürlük belirtilmelidir' });
    }
    
    const review = await Review.findByIdAndUpdate(
      req.params.id,
      { $set: { isPublic } },
      { new: true }
    );
    
    if (!review) {
      return res.status(404).json({ message: 'Yorum bulunamadı' });
    }
    
    res.json({ 
      review,
      message: `Yorum ${isPublic ? 'görünür' : 'gizli'} olarak ayarlandı` 
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Sunucu hatası' });
  }
};

/**
 * Delete review
 * @route DELETE /api/reviews/:id
 * @access Private (Admin or review author)
 */
exports.deleteReview = async (req, res) => {
  try {
    const review = await Review.findById(req.params.id);
    
    if (!review) {
      return res.status(404).json({ message: 'Yorum bulunamadı' });
    }
    
    // Check if user is authorized to delete
    if (review.user.toString() !== req.user.id && req.user.role !== 'admin') {
      return res.status(403).json({ message: 'Bu işlemi yapmaya yetkiniz yok' });
    }
    
    // Remove reference from property or experience
    if (review.reviewType === 'property' && review.property) {
      await Property.findByIdAndUpdate(review.property, {
        $pull: { reviews: review._id }
      });
    } else if (review.reviewType === 'experience' && review.experience) {
      await Experience.findByIdAndUpdate(review.experience, {
        $pull: { reviews: review._id }
      });
    }
    
    await Review.findByIdAndDelete(req.params.id);
    
    res.json({ message: 'Yorum başarıyla silindi' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Sunucu hatası' });
  }
}; 