const Property = require('../models/Property');
const User = require('../models/User');
const fs = require('fs');
const path = require('path');

/**
 * Get all properties
 * @route GET /api/properties
 * @access Public
 */
exports.getAllProperties = async (req, res) => {
  try {
    const { location, guests, price_min, price_max, type, page = 1, limit = 10 } = req.query;
    
    // Build filter object
    const filter = {};
    if (location) filter.location = { $regex: location, $options: 'i' };
    if (guests) filter.maxGuests = { $gte: parseInt(guests) };
    if (price_min || price_max) {
      filter.price = {};
      if (price_min) filter.price.$gte = parseInt(price_min);
      if (price_max) filter.price.$lte = parseInt(price_max);
    }
    if (type) filter.propertyType = type;
    
    // Only show active properties
    filter.isActive = true;
    
    // Pagination
    const skip = (parseInt(page) - 1) * parseInt(limit);
    
    // Get properties
    const properties = await Property.find(filter)
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(parseInt(limit));
    
    // Get total count of properties matching the filter
    const total = await Property.countDocuments(filter);
    
    res.json({
      properties,
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
 * Get property by ID
 * @route GET /api/properties/:id
 * @access Public
 */
exports.getPropertyById = async (req, res) => {
  try {
    const property = await Property.findById(req.params.id)
      .populate('reviews');
    
    if (!property) {
      return res.status(404).json({ message: 'Mülk bulunamadı' });
    }
    
    res.json(property);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Sunucu hatası' });
  }
};

/**
 * Create new property
 * @route POST /api/properties
 * @access Private (Host/Admin)
 */
exports.createProperty = async (req, res) => {
  try {
    const {
      title,
      subtitle,
      description,
      price,
      currency,
      perNight,
      location,
      coordinates,
      propertyType,
      amenities,
      bedroomCount,
      bathroomCount,
      maxGuests,
      tags,
      availability
    } = req.body;
    
    // Validate required fields
    if (!title || !subtitle || !description || !price || !location || 
        !propertyType || !bedroomCount || !bathroomCount || !maxGuests) {
      return res.status(400).json({ message: 'Tüm zorunlu alanları doldurmalısınız' });
    }
    
    // Get property images from request
    if (!req.files || req.files.length === 0) {
      return res.status(400).json({ message: 'En az bir resim yüklemelisiniz' });
    }
    
    // Format image paths
    const images = req.files.map(file => file.path.replace(/\\/g, '/'));
    
    // Get host info
    const host = req.user;
    const hostName = `${host.firstName} ${host.lastName}`;
    const hostImage = host.profileImage;
    
    // Create new property
    const property = new Property({
      title,
      subtitle,
      description,
      price,
      currency: currency || '₺',
      perNight: perNight !== undefined ? perNight : true,
      location,
      coordinates: coordinates || {},
      propertyType,
      images,
      amenities: amenities || [],
      bedroomCount,
      bathroomCount,
      maxGuests,
      host: host._id,
      hostName,
      hostImage,
      isSuperhost: false,
      tags: tags || [],
      availability: availability || []
    });
    
    await property.save();
    
    res.status(201).json({ 
      property,
      message: 'Mülk başarıyla oluşturuldu' 
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Sunucu hatası' });
  }
};

/**
 * Update property
 * @route PUT /api/properties/:id
 * @access Private (Host/Admin)
 */
exports.updateProperty = async (req, res) => {
  try {
    const propertyId = req.params.id;
    
    // Check if property exists and user is the owner
    const property = await Property.findById(propertyId);
    
    if (!property) {
      return res.status(404).json({ message: 'Mülk bulunamadı' });
    }
    
    // Only allow host or admin to update
    if (property.host.toString() !== req.user.id && req.user.role !== 'admin') {
      return res.status(403).json({ message: 'Bu işlem için yetkiniz yok' });
    }
    
    // Extract fields to update
    const {
      title,
      subtitle,
      description,
      price,
      currency,
      perNight,
      location,
      coordinates,
      propertyType,
      amenities,
      bedroomCount,
      bathroomCount,
      maxGuests,
      tags,
      availability,
      isActive
    } = req.body;
    
    // Build update object
    const updateData = {};
    if (title) updateData.title = title;
    if (subtitle) updateData.subtitle = subtitle;
    if (description) updateData.description = description;
    if (price) updateData.price = price;
    if (currency) updateData.currency = currency;
    if (perNight !== undefined) updateData.perNight = perNight;
    if (location) updateData.location = location;
    if (coordinates) updateData.coordinates = coordinates;
    if (propertyType) updateData.propertyType = propertyType;
    if (amenities) updateData.amenities = amenities;
    if (bedroomCount) updateData.bedroomCount = bedroomCount;
    if (bathroomCount) updateData.bathroomCount = bathroomCount;
    if (maxGuests) updateData.maxGuests = maxGuests;
    if (tags) updateData.tags = tags;
    if (availability) updateData.availability = availability;
    if (isActive !== undefined) updateData.isActive = isActive;
    
    // Update property
    const updatedProperty = await Property.findByIdAndUpdate(
      propertyId,
      { $set: updateData },
      { new: true, runValidators: true }
    );
    
    res.json({ 
      property: updatedProperty,
      message: 'Mülk başarıyla güncellendi' 
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Sunucu hatası' });
  }
};

/**
 * Upload property images
 * @route POST /api/properties/:id/images
 * @access Private (Host/Admin)
 */
exports.uploadPropertyImages = async (req, res) => {
  try {
    const propertyId = req.params.id;
    
    // Check if property exists and user is the owner
    const property = await Property.findById(propertyId);
    
    if (!property) {
      return res.status(404).json({ message: 'Mülk bulunamadı' });
    }
    
    // Only allow host or admin to update
    if (property.host.toString() !== req.user.id && req.user.role !== 'admin') {
      return res.status(403).json({ message: 'Bu işlem için yetkiniz yok' });
    }
    
    // Get property images from request
    if (!req.files || req.files.length === 0) {
      return res.status(400).json({ message: 'En az bir resim yüklemelisiniz' });
    }
    
    // Format image paths
    const newImages = req.files.map(file => file.path.replace(/\\/g, '/'));
    
    // Add images to property
    const updatedProperty = await Property.findByIdAndUpdate(
      propertyId,
      { $push: { images: { $each: newImages } } },
      { new: true }
    );
    
    res.json({ 
      property: updatedProperty,
      message: 'Resimler başarıyla yüklendi' 
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Sunucu hatası' });
  }
};

/**
 * Delete property image
 * @route DELETE /api/properties/:id/images/:imageIndex
 * @access Private (Host/Admin)
 */
exports.deletePropertyImage = async (req, res) => {
  try {
    const { id, imageIndex } = req.params;
    
    // Check if property exists and user is the owner
    const property = await Property.findById(id);
    
    if (!property) {
      return res.status(404).json({ message: 'Mülk bulunamadı' });
    }
    
    // Only allow host or admin to update
    if (property.host.toString() !== req.user.id && req.user.role !== 'admin') {
      return res.status(403).json({ message: 'Bu işlem için yetkiniz yok' });
    }
    
    // Check if image exists
    if (!property.images[imageIndex]) {
      return res.status(404).json({ message: 'Resim bulunamadı' });
    }
    
    // Remove image from filesystem
    const imagePath = property.images[imageIndex];
    if (fs.existsSync(imagePath)) {
      fs.unlinkSync(imagePath);
    }
    
    // Remove image from property
    property.images.splice(imageIndex, 1);
    
    // Ensure at least one image remains
    if (property.images.length === 0) {
      return res.status(400).json({ message: 'En az bir resim kalmalıdır' });
    }
    
    await property.save();
    
    res.json({ 
      property,
      message: 'Resim başarıyla silindi' 
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Sunucu hatası' });
  }
};

/**
 * Delete property
 * @route DELETE /api/properties/:id
 * @access Private (Host/Admin)
 */
exports.deleteProperty = async (req, res) => {
  try {
    const propertyId = req.params.id;
    
    // Check if property exists and user is the owner
    const property = await Property.findById(propertyId);
    
    if (!property) {
      return res.status(404).json({ message: 'Mülk bulunamadı' });
    }
    
    // Only allow host or admin to delete
    if (property.host.toString() !== req.user.id && req.user.role !== 'admin') {
      return res.status(403).json({ message: 'Bu işlem için yetkiniz yok' });
    }
    
    // Check if property has bookings
    if (property.bookings && property.bookings.length > 0) {
      // Instead of deleting, set property as inactive
      property.isActive = false;
      await property.save();
      
      return res.json({ 
        message: 'Mülk rezervasyonları olduğu için devre dışı bırakıldı' 
      });
    }
    
    // Delete all property images from filesystem
    property.images.forEach(imagePath => {
      if (fs.existsSync(imagePath)) {
        fs.unlinkSync(imagePath);
      }
    });
    
    // Delete property from database
    await Property.findByIdAndDelete(propertyId);
    
    res.json({ message: 'Mülk başarıyla silindi' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Sunucu hatası' });
  }
};

/**
 * Get user's properties (as host)
 * @route GET /api/properties/my-properties
 * @access Private (Host)
 */
exports.getMyProperties = async (req, res) => {
  try {
    const properties = await Property.find({ host: req.user.id })
      .sort({ createdAt: -1 });
    
    res.json(properties);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Sunucu hatası' });
  }
}; 