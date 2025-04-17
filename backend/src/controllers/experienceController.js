const Experience = require('../models/Experience');
const User = require('../models/User');
const fs = require('fs');
const path = require('path');

/**
 * Get all experiences
 * @route GET /api/experiences
 * @access Public
 */
exports.getAllExperiences = async (req, res) => {
  try {
    const { location, category, price_min, price_max, page = 1, limit = 10 } = req.query;
    
    // Build filter object
    const filter = {};
    if (location) filter.location = { $regex: location, $options: 'i' };
    if (category) filter.category = category;
    if (price_min || price_max) {
      filter.price = {};
      if (price_min) filter.price.$gte = parseInt(price_min);
      if (price_max) filter.price.$lte = parseInt(price_max);
    }
    
    // Only show active experiences
    filter.isActive = true;
    
    // Pagination
    const skip = (parseInt(page) - 1) * parseInt(limit);
    
    // Get experiences
    const experiences = await Experience.find(filter)
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(parseInt(limit));
    
    // Get total count
    const total = await Experience.countDocuments(filter);
    
    res.json({
      experiences,
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
 * Get experience by ID
 * @route GET /api/experiences/:id
 * @access Public
 */
exports.getExperienceById = async (req, res) => {
  try {
    const experience = await Experience.findById(req.params.id)
      .populate('reviews');
    
    if (!experience) {
      return res.status(404).json({ message: 'Deneyim bulunamadı' });
    }
    
    res.json(experience);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Sunucu hatası' });
  }
};

/**
 * Create new experience
 * @route POST /api/experiences
 * @access Private (Host/Admin)
 */
exports.createExperience = async (req, res) => {
  try {
    const {
      title,
      subtitle,
      description,
      price,
      currency,
      duration,
      location,
      coordinates,
      category,
      maxGuests,
      includes,
      languages,
      tags,
      schedule
    } = req.body;
    
    // Validate required fields
    if (!title || !subtitle || !description || !price || !location || 
        !category || !duration || !maxGuests) {
      return res.status(400).json({ message: 'Tüm zorunlu alanları doldurmalısınız' });
    }
    
    // Get experience image from request
    if (!req.file) {
      return res.status(400).json({ message: 'Bir resim yüklemelisiniz' });
    }
    
    // Format image path
    const imagePath = req.file.path.replace(/\\/g, '/');
    
    // Get host info
    const host = req.user;
    const hostName = `${host.firstName} ${host.lastName}`;
    const hostImage = host.profileImage;
    
    // Tüm istek gövdesini incelemek için log tut
    console.log('------------------------------');
    console.log('Experience Creation Request:');
    console.log('Form fields:', req.body);
    console.log('Form field keys:', Object.keys(req.body));
    console.log('------------------------------');
    
    // Prepare included items from various possible formats
    let includedItems = [];
    
    // Try to get included items from various formats sent by client
    if (Array.isArray(includes)) {
      console.log('Found includes as array:', includes);
      includedItems = includes;
    } else if (req.body.included && typeof req.body.included === 'string') {
      try {
        console.log('Found included as string, parsing:', req.body.included);
        includedItems = JSON.parse(req.body.included);
        console.log('Parsed included:', includedItems);
      } catch(e) {
        console.error('Failed to parse included JSON:', e);
      }
    } else if (req.body.included_csv) {
      console.log('Found included_csv:', req.body.included_csv);
      includedItems = req.body.included_csv.split(',').filter(item => item.trim());
      console.log('Parsed from CSV:', includedItems);
    } else if (req.body.includes && typeof req.body.includes === 'string') {
      try {
        console.log('Trying includes as string:', req.body.includes);
        includedItems = JSON.parse(req.body.includes);
        console.log('Parsed from includes:', includedItems);
      } catch(e) {
        console.error('Failed to parse includes JSON:', e);
      }
    }
    
    // Ayrı ayrı tanımlanmış includes[0], includes[1] gibi alanları dene
    const indexedIncludes = [];
    for (let i = 0; i < 10; i++) { // Makul bir aralık
      const key = `includes[${i}]`;
      if (req.body[key]) {
        console.log(`Found indexed include ${key}:`, req.body[key]);
        indexedIncludes.push(req.body[key]);
      }
    }
    
    if (indexedIncludes.length > 0) {
      console.log('Using indexed includes:', indexedIncludes);
      includedItems = indexedIncludes;
    }
    
    console.log('Final included items to be saved:', includedItems);
    
    // Create new experience
    const experience = new Experience({
      title,
      subtitle,
      description,
      price,
      currency: currency || '₺',
      duration,
      location,
      coordinates: coordinates || {},
      category,
      image: imagePath,
      maxGuests,
      included: includedItems, // "included" MongoDB modelinde tanımlı alan adı
      languages: languages || ['Türkçe'],
      host: host._id,
      hostName,
      hostImage,
      isSuperhost: false,
      tags: tags || [],
      schedule: schedule || []
    });
    
    await experience.save();
    
    // Kaydedilen deneyimi logla
    console.log('Saved experience included items:', experience.included);
    
    res.status(201).json({ 
      experience,
      message: 'Deneyim başarıyla oluşturuldu' 
    });
  } catch (error) {
    console.error('Experience creation error:', error);
    res.status(500).json({ message: 'Sunucu hatası' });
  }
};

/**
 * Update experience
 * @route PUT /api/experiences/:id
 * @access Private (Host/Admin)
 */
exports.updateExperience = async (req, res) => {
  try {
    const experienceId = req.params.id;
    
    // Check if experience exists and user is the owner
    const experience = await Experience.findById(experienceId);
    
    if (!experience) {
      return res.status(404).json({ message: 'Deneyim bulunamadı' });
    }
    
    // Only allow host or admin to update
    if (experience.host.toString() !== req.user.id && req.user.role !== 'admin') {
      return res.status(403).json({ message: 'Bu işlem için yetkiniz yok' });
    }
    
    // Extract fields to update
    const {
      title,
      subtitle,
      description,
      price,
      currency,
      duration,
      location,
      coordinates,
      category,
      maxGuests,
      includes,
      languages,
      tags,
      schedule,
      isActive
    } = req.body;
    
    // Build update object
    const updateData = {};
    if (title) updateData.title = title;
    if (subtitle) updateData.subtitle = subtitle;
    if (description) updateData.description = description;
    if (price) updateData.price = price;
    if (currency) updateData.currency = currency;
    if (duration) updateData.duration = duration;
    if (location) updateData.location = location;
    if (coordinates) updateData.coordinates = coordinates;
    if (category) updateData.category = category;
    if (maxGuests) updateData.maxGuests = maxGuests;
    if (includes) updateData.includes = includes;
    if (languages) updateData.languages = languages;
    if (tags) updateData.tags = tags;
    if (schedule) updateData.schedule = schedule;
    if (isActive !== undefined) updateData.isActive = isActive;
    
    // Update experience
    const updatedExperience = await Experience.findByIdAndUpdate(
      experienceId,
      { $set: updateData },
      { new: true, runValidators: true }
    );
    
    res.json({ 
      experience: updatedExperience,
      message: 'Deneyim başarıyla güncellendi' 
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Sunucu hatası' });
  }
};

/**
 * Upload experience image
 * @route POST /api/experiences/:id/image
 * @access Private (Host/Admin)
 */
exports.uploadExperienceImage = async (req, res) => {
  try {
    const experienceId = req.params.id;
    
    // Check if experience exists and user is the owner
    const experience = await Experience.findById(experienceId);
    
    if (!experience) {
      return res.status(404).json({ message: 'Deneyim bulunamadı' });
    }
    
    // Only allow host or admin to update
    if (experience.host.toString() !== req.user.id && req.user.role !== 'admin') {
      return res.status(403).json({ message: 'Bu işlem için yetkiniz yok' });
    }
    
    // Get experience image from request
    if (!req.file) {
      return res.status(400).json({ message: 'Bir resim yüklemelisiniz' });
    }
    
    // Delete old image if exists
    if (experience.image && fs.existsSync(experience.image)) {
      fs.unlinkSync(experience.image);
    }
    
    // Format image path
    const imagePath = req.file.path.replace(/\\/g, '/');
    
    // Update experience with new image
    const updatedExperience = await Experience.findByIdAndUpdate(
      experienceId,
      { $set: { image: imagePath } },
      { new: true }
    );
    
    res.json({ 
      experience: updatedExperience,
      message: 'Resim başarıyla güncellendi'
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Sunucu hatası' });
  }
};

/**
 * Delete experience
 * @route DELETE /api/experiences/:id
 * @access Private (Host/Admin)
 */
exports.deleteExperience = async (req, res) => {
  try {
    const experienceId = req.params.id;
    
    // Check if experience exists and user is the owner
    const experience = await Experience.findById(experienceId);
    
    if (!experience) {
      return res.status(404).json({ message: 'Deneyim bulunamadı' });
    }
    
    // Only allow host or admin to delete
    if (experience.host.toString() !== req.user.id && req.user.role !== 'admin') {
      return res.status(403).json({ message: 'Bu işlem için yetkiniz yok' });
    }
    
    // Check if experience has bookings
    if (experience.bookings && experience.bookings.length > 0) {
      // Instead of deleting, set experience as inactive
      experience.isActive = false;
      await experience.save();
      
      return res.json({ 
        message: 'Deneyim rezervasyonları olduğu için devre dışı bırakıldı' 
      });
    }
    
    // Delete experience image from filesystem
    if (experience.image && fs.existsSync(experience.image)) {
      fs.unlinkSync(experience.image);
    }
    
    // Delete experience from database
    await Experience.findByIdAndDelete(experienceId);
    
    res.json({ message: 'Deneyim başarıyla silindi' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Sunucu hatası' });
  }
};

/**
 * Get user's experiences (as host)
 * @route GET /api/experiences/my-experiences
 * @access Private (Host)
 */
exports.getMyExperiences = async (req, res) => {
  try {
    const experiences = await Experience.find({ host: req.user.id })
      .sort({ createdAt: -1 });
    
    res.json(experiences);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Sunucu hatası' });
  }
};

/**
 * Get experiences by category
 * @route GET /api/experiences/categories/:category
 * @access Public
 */
exports.getExperiencesByCategory = async (req, res) => {
  try {
    const { category } = req.params;
    const { page = 1, limit = 10 } = req.query;
    
    // Pagination
    const skip = (parseInt(page) - 1) * parseInt(limit);
    
    // Get experiences by category
    const experiences = await Experience.find({ 
      category, 
      isActive: true 
    })
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(parseInt(limit));
    
    // Get total count
    const total = await Experience.countDocuments({ 
      category, 
      isActive: true 
    });
    
    res.json({
      experiences,
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
 * Add schedule time to experience
 * @route POST /api/experiences/:id/schedule
 * @access Private (Host)
 */
exports.addScheduleTime = async (req, res) => {
  try {
    const { date, startTime, endTime, maxGuests } = req.body;
    const experienceId = req.params.id;
    
    // Validate required fields
    if (!date || !startTime || !endTime) {
      return res.status(400).json({ message: 'Tarih ve saat bilgileri gereklidir' });
    }
    
    // Check if experience exists and user is the owner
    const experience = await Experience.findById(experienceId);
    
    if (!experience) {
      return res.status(404).json({ message: 'Deneyim bulunamadı' });
    }
    
    // Only allow host or admin to update
    if (experience.host.toString() !== req.user.id && req.user.role !== 'admin') {
      return res.status(403).json({ message: 'Bu işlem için yetkiniz yok' });
    }
    
    // Create new schedule item
    const scheduleItem = {
      date,
      startTime,
      endTime,
      maxGuests: maxGuests || experience.maxGuests,
      available: true
    };
    
    // Add to experience schedule
    const updatedExperience = await Experience.findByIdAndUpdate(
      experienceId,
      { $push: { schedule: scheduleItem } },
      { new: true }
    );
    
    res.json({
      experience: updatedExperience,
      message: 'Program başarıyla eklendi'
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Sunucu hatası' });
  }
};

/**
 * Remove schedule time from experience
 * @route DELETE /api/experiences/:id/schedule/:scheduleId
 * @access Private (Host)
 */
exports.removeScheduleTime = async (req, res) => {
  try {
    const { id, scheduleId } = req.params;
    
    // Check if experience exists and user is the owner
    const experience = await Experience.findById(id);
    
    if (!experience) {
      return res.status(404).json({ message: 'Deneyim bulunamadı' });
    }
    
    // Only allow host or admin to update
    if (experience.host.toString() !== req.user.id && req.user.role !== 'admin') {
      return res.status(403).json({ message: 'Bu işlem için yetkiniz yok' });
    }
    
    // Remove schedule item
    const updatedExperience = await Experience.findByIdAndUpdate(
      id,
      { $pull: { schedule: { _id: scheduleId } } },
      { new: true }
    );
    
    res.json({
      experience: updatedExperience,
      message: 'Program başarıyla kaldırıldı'
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Sunucu hatası' });
  }
}; 