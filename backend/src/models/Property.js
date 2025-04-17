const mongoose = require('mongoose');

const propertySchema = new mongoose.Schema(
  {
    title: {
      type: String,
      required: [true, 'Property title is required'],
      trim: true,
      maxlength: [100, 'Title cannot be more than 100 characters'],
    },
    subtitle: {
      type: String,
      required: [true, 'Property subtitle is required'],
      trim: true,
    },
    description: {
      type: String,
      required: [true, 'Property description is required'],
      trim: true,
    },
    price: {
      type: Number,
      required: [true, 'Property price is required'],
      min: [1, 'Price must be greater than 0'],
    },
    currency: {
      type: String,
      default: '₺',
      enum: ['₺', '$', '€', '£'],
    },
    perNight: {
      type: Boolean,
      default: true,
    },
    location: {
      type: String,
      required: [true, 'Property location is required'],
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
    propertyType: {
      type: String,
      required: [true, 'Property type is required'],
      enum: ['Ev', 'Daire', 'Villa', 'Özel Oda'],
    },
    images: [{
      type: String,
      required: [true, 'At least one image is required'],
    }],
    amenities: [{
      type: String,
    }],
    bedroomCount: {
      type: Number,
      required: [true, 'Bedroom count is required'],
      min: [1, 'Bedroom count must be at least 1'],
    },
    bathroomCount: {
      type: Number,
      required: [true, 'Bathroom count is required'],
      min: [1, 'Bathroom count must be at least 1'],
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
    isSuperhost: {
      type: Boolean,
      default: false,
    },
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
      startDate: {
        type: Date,
        required: true,
      },
      endDate: {
        type: Date,
        required: true,
      },
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
propertySchema.virtual('formattedPrice').get(function() {
  return `${this.currency}${this.price}`;
});

// Index for location-based searches
propertySchema.index({ location: 'text', title: 'text', description: 'text', tags: 'text' });

const Property = mongoose.model('Property', propertySchema);

module.exports = Property; 