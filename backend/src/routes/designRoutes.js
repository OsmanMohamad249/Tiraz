const express = require('express');
const router = express.Router();

/**
 * @route   GET /api/v1/design/categories
 * @desc    Get available garment categories (MVP: Thobes & Shirts)
 * @access  Public
 */
router.get('/categories', async (req, res) => {
  try {
    const categories = [
      {
        id: 'thobes',
        name: "Men's Thobes",
        description: 'Traditional and modern thobe designs',
        image: '/images/categories/thobes.jpg',
      },
      {
        id: 'shirts',
        name: "Men's Shirts",
        description: 'Custom tailored shirts',
        image: '/images/categories/shirts.jpg',
      },
    ];

    res.json({
      status: 'success',
      data: { categories },
    });
  } catch (error) {
    res.status(500).json({
      status: 'error',
      message: error.message,
    });
  }
});

/**
 * @route   GET /api/v1/design/fabrics/:category
 * @desc    Get available fabrics for a category
 * @access  Public
 */
router.get('/fabrics/:category', async (req, res) => {
  try {
    const { category } = req.params;

    // TODO: Fetch from database
    const fabrics = [
      {
        id: '1',
        name: 'Premium Cotton',
        description: 'Soft, breathable cotton',
        price: 30,
        color: '#E8F4F8',
        image: '/images/fabrics/cotton.jpg',
      },
      {
        id: '2',
        name: 'Linen Blend',
        description: 'Natural linen blend',
        price: 35,
        color: '#F5E6D3',
        image: '/images/fabrics/linen.jpg',
      },
      {
        id: '3',
        name: 'Silk Touch',
        description: 'Luxurious silk finish',
        price: 50,
        color: '#FFF8DC',
        image: '/images/fabrics/silk.jpg',
      },
      {
        id: '4',
        name: 'Twill Fabric',
        description: 'Durable twill weave',
        price: 40,
        color: '#E0E0E0',
        image: '/images/fabrics/twill.jpg',
      },
    ];

    res.json({
      status: 'success',
      data: { fabrics, category },
    });
  } catch (error) {
    res.status(500).json({
      status: 'error',
      message: error.message,
    });
  }
});

/**
 * @route   POST /api/v1/design/save
 * @desc    Save a design
 * @access  Protected
 */
router.post('/save', async (req, res) => {
  try {
    const { userId, category, fabric, customization } = req.body;

    // TODO: Save to database
    const design = {
      id: Date.now().toString(),
      userId,
      category,
      fabric,
      customization,
      createdAt: new Date().toISOString(),
    };

    res.status(201).json({
      status: 'success',
      message: 'Design saved successfully',
      data: { design },
    });
  } catch (error) {
    res.status(500).json({
      status: 'error',
      message: error.message,
    });
  }
});

/**
 * @route   GET /api/v1/design/user/:userId
 * @desc    Get user's saved designs
 * @access  Protected
 */
router.get('/user/:userId', async (req, res) => {
  try {
    const { userId } = req.params;

    // TODO: Fetch from database
    const designs = [
      {
        id: '1',
        userId,
        category: 'thobes',
        fabric: 'Premium Cotton',
        customization: {
          collar: 'classic',
          sleeves: 'full',
        },
        createdAt: new Date().toISOString(),
      },
    ];

    res.json({
      status: 'success',
      data: { designs },
    });
  } catch (error) {
    res.status(500).json({
      status: 'error',
      message: error.message,
    });
  }
});

module.exports = router;
