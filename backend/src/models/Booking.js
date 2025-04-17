const mongoose = require('mongoose');

const bookingSchema = new mongoose.Schema(
  {
    user: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: [true, 'User is required'],
    },
    bookingType: {
      type: String,
      enum: ['property', 'experience'],
      required: [true, 'Booking type is required'],
    },
    property: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Property',
    },
    experience: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Experience',
    },
    startDate: {
      type: Date,
      required: [true, 'Start date is required'],
    },
    endDate: {
      type: Date,
      required: function() {
        return this.bookingType === 'property';
      },
    },
    timeSlot: {
      startTime: {
        type: String,
        required: function() {
          return this.bookingType === 'experience';
        },
      },
      endTime: {
        type: String,
        required: function() {
          return this.bookingType === 'experience';
        },
      },
    },
    guestCount: {
      type: Number,
      required: [true, 'Guest count is required'],
      min: [1, 'Guest count must be at least 1'],
    },
    totalPrice: {
      type: Number,
      required: [true, 'Total price is required'],
    },
    currency: {
      type: String,
      enum: ['₺', '$', '€', '£'],
      default: '₺',
    },
    status: {
      type: String,
      enum: ['pending', 'confirmed', 'completed', 'cancelled'],
      default: 'pending',
    },
    paymentStatus: {
      type: String,
      enum: ['pending', 'paid', 'refunded', 'failed'],
      default: 'pending',
    },
    paymentMethod: {
      type: String,
      enum: ['credit_card', 'paypal', 'bank_transfer'],
    },
    notes: {
      type: String,
      trim: true,
    },
    cancellationReason: {
      type: String,
      trim: true,
    },
    cancellationDate: {
      type: Date,
    },
    hasReview: {
      type: Boolean,
      default: false,
    },
  },
  {
    timestamps: true,
  }
);

// Validate that either property or experience is provided, based on bookingType
bookingSchema.pre('validate', function(next) {
  if (this.bookingType === 'property' && !this.property) {
    this.invalidate('property', 'Property is required for property bookings');
  } else if (this.bookingType === 'experience' && !this.experience) {
    this.invalidate('experience', 'Experience is required for experience bookings');
  }
  next();
});

// Virtual to get booking item (property or experience)
bookingSchema.virtual('bookingItem').get(function() {
  return this.bookingType === 'property' ? this.property : this.experience;
});

const Booking = mongoose.model('Booking', bookingSchema);

module.exports = Booking; 