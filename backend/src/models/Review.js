const mongoose = require('mongoose');

const reviewSchema = new mongoose.Schema(
  {
    user: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: [true, 'User is required'],
    },
    reviewType: {
      type: String,
      enum: ['property', 'experience', 'host', 'guest'],
      required: [true, 'Review type is required'],
    },
    property: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Property',
    },
    experience: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Experience',
    },
    booking: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Booking',
    },
    host: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
    },
    guest: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
    },
    rating: {
      type: Number,
      required: [true, 'Rating is required'],
      min: [1, 'Rating must be at least 1'],
      max: [5, 'Rating cannot exceed 5'],
    },
    comment: {
      type: String,
      required: [true, 'Comment is required'],
      trim: true,
      minlength: [3, 'Comment must be at least 3 characters long'],
    },
    response: {
      comment: {
        type: String,
        trim: true,
      },
      date: {
        type: Date,
      },
    },
    isPublic: {
      type: Boolean,
      default: true,
    },
  },
  {
    timestamps: true,
  }
);

// Validate that the appropriate reference is provided based on reviewType
reviewSchema.pre('validate', function(next) {
  const reviewType = this.reviewType;
  
  if (reviewType === 'property' && !this.property) {
    this.invalidate('property', 'Property is required for property reviews');
  } else if (reviewType === 'experience' && !this.experience) {
    this.invalidate('experience', 'Experience is required for experience reviews');
  } else if (reviewType === 'host' && !this.host) {
    this.invalidate('host', 'Host is required for host reviews');
  } else if (reviewType === 'guest' && !this.guest) {
    this.invalidate('guest', 'Guest is required for guest reviews');
  }
  
  next();
});

// Hook to update average rating on property
reviewSchema.post('save', async function() {
  if (this.reviewType === 'property' && this.property) {
    const Property = mongoose.model('Property');
    const property = await Property.findById(this.property);
    
    if (property) {
      const reviews = await this.constructor.find({ property: this.property, isPublic: true });
      const totalRatings = reviews.reduce((sum, review) => sum + review.rating, 0);
      const avgRating = totalRatings / reviews.length;
      
      await Property.findByIdAndUpdate(this.property, {
        rating: avgRating.toFixed(1),
        reviewCount: reviews.length
      });
    }
  } else if (this.reviewType === 'experience' && this.experience) {
    const Experience = mongoose.model('Experience');
    const experience = await Experience.findById(this.experience);
    
    if (experience) {
      const reviews = await this.constructor.find({ experience: this.experience, isPublic: true });
      const totalRatings = reviews.reduce((sum, review) => sum + review.rating, 0);
      const avgRating = totalRatings / reviews.length;
      
      await Experience.findByIdAndUpdate(this.experience, {
        rating: avgRating.toFixed(1),
        reviewCount: reviews.length
      });
    }
  }
});

const Review = mongoose.model('Review', reviewSchema);

module.exports = Review; 