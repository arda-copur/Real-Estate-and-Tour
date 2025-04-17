const mongoose = require('mongoose');

const experienceSchema = new mongoose.Schema(
  {
    title: {
      type: String,
      required: [true, 'Experience title is required'],
      trim: true,
      maxlength: [100, 'Title cannot be more than 100 characters'],
    },
    subtitle: {
      type: String,
      required: [true, 'Experience subtitle is required'],
      trim: true,
      maxlength: [200, 'Subtitle cannot be more than 200 characters'],
    },
    category: {
      type: String,
      required: [true, 'Experience category is required'],
      enum: ['Yemek', 'Sanat', 'Doğa', 'Spor', 'Tarih', 'Müzik', 'Dans', 'Fotoğrafçılık'],
    },
    description: {
      type: String,
      required: [true, 'Experience description is required'],
      trim: true,
    },
    price: {
      type: Number,
      required: [true, 'Experience price is required'],
      min: [1, 'Price must be greater than 0'],
    },
    currency: {
      type: String,
      default: '₺',
      enum: ['₺', '$', '€', '£'],
    },
    location: {
      type: String,
      required: [true, 'Experience location is required'],
      trim: true,
    },
    coordinates: {
      lat: {
        type: Number,
      },
      lng: {
        type: Number,
      }
    },
    image: {
      type: String,
      required: [true, 'Experience image is required'],
    },
    duration: {
      type: Number,
      required: [true, 'Experience duration is required'],
      min: [1, 'Duration must be at least 1 hour'],
    },
    maxGuests: {
      type: Number,
      required: [true, 'Maximum guests count is required'],
      min: [1, 'Max guests must be at least 1'],
    },
    host: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: [true, 'Host is required'],
    },
    hostName: {
      type: String,
      required: [true, 'Host name is required'],
    },
    hostImage: {
      type: String,
    },
    included: [{
      type: String,
    }],
    tags: [{
      type: String,
    }],
    rating: {
      type: Number,
      default: 0,
      min: 0,
      max: 5,
    },
    reviewCount: {
      type: Number,
      default: 0,
    },
    reviews: [{
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Review',
    }],
    bookings: [{
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Booking',
    }],
    availability: [{
      date: {
        type: Date,
        required: true,
      },
      timeSlots: [{
        startTime: {
          type: String,
          required: true,
        },
        endTime: {
          type: String,
          required: true,
        },
        available: {
          type: Boolean,
          default: true,
        },
      }],
    }],
    isActive: {
      type: Boolean,
      default: true,
    },
  },
  {
    timestamps: true,
    toJSON: { virtuals: true },
    toObject: { virtuals: true },
  }
);

// Format price as string with currency
experienceSchema.virtual('formattedPrice').get(function() {
  return `${this.currency}${this.price}`;
});

// Index for location-based searches
experienceSchema.index({ location: 'text', title: 'text', description: 'text', category: 'text', tags: 'text' });

const Experience = mongoose.model('Experience', experienceSchema);

module.exports = Experience; 