const mongoose = require('mongoose');

const destinationSchema = new mongoose.Schema(
  {
    name: {
      type: String,
      required: [true, 'Destination name is required'],
      trim: true,
      unique: true,
    },
    image: {
      type: String,
      required: [true, 'Destination image is required'],
    },
    description: {
      type: String,
      required: [true, 'Destination description is required'],
      trim: true,
    },
    country: {
      type: String,
      required: [true, 'Country is required'],
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
    popularAttractions: [{
      type: String,
      trim: true,
    }],
    isPopular: {
      type: Boolean,
      default: false,
    },
    isFeatured: {
      type: Boolean,
      default: false,
    },
  },
  {
    timestamps: true,
  }
);

// Index for search
destinationSchema.index({ name: 'text', description: 'text', country: 'text' });

const Destination = mongoose.model('Destination', destinationSchema);

module.exports = Destination; 