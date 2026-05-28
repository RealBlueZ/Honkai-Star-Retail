const express = require('express');
const db = require('../config/db');
const { verifyToken } = require('../middlewares/authMiddleware');

const router = express.Router();

// 1. [GET] AMBIL SEMUA DATA BARANG (Bisa diakses siapa saja - User & Admin)
router.get('/resources', async (req, res) => {
    try {
        const [resources] = await db.execute('SELECT * FROM resources');
        res.status(200).json({ success: true, data: resources });
    } catch (error) {
        res.status(500).json({ message: 'Failed to fetch resources', error: error.message });
    }
});

// 2. [GET] AMBIL SATU DATA BARANG DETAIL BERDASARKAN ID
router.get('/resources/:id', async (req, res) => {
    const { id } = req.params;
    try {
        const [resources] = await db.execute('SELECT * FROM resources WHERE id = ?', [id]);
        if (resources.length === 0) {
            return res.status(404).json({ message: 'Resource not found' });
        }
        res.status(200).json({ success: true, data: resources[0] });
    } catch (error) {
        res.status(500).json({ message: 'Server error', error: error.message });
    }
});

// 3. [POST] TAMBAH BARANG BARU (Hanya Admin & Wajib Verifikasi Token)
router.post('/resources', verifyToken, isAdmin, async (req, res) => {
    const { name, type, description, stock, image, price } = req.body;

    // Validasi input backend
    if (!name || !type || !description || !stock || !image || !price) {
        return res.status(400).json({ message: 'All fields are required.' });
    }

    try {
        const [result] = await db.execute(
            'INSERT INTO resources (name, type, description, stock, image, price) VALUES (?, ?, ?, ?, ?, ?)',
            [name, type, description, stock, image, price]
        );
        res.status(201).json({ success: true, message: 'Resource added successfully!', id: result.insertId });
    } catch (error) {
        res.status(500).json({ message: 'Server error', error: error.message });
    }
});

// 4. [PUT] UPDATE BARANG (Hanya Admin)
router.put('/resources/:id', verifyAdminToken, async (req, res) => {
    const { id } = req.params;
    const { name, type, description, stock, image, price } = req.body;

    try {
        await db.execute(
            'UPDATE resources SET name=?, type=?, description=?, stock=?, image=?, price=? WHERE id=?',
            [name, type, description, stock, image, price, id]
        );
        res.status(200).json({ success: true, message: 'Resource updated successfully!' });
    } catch (error) {
        res.status(500).json({ message: 'Server error', error: error.message });
    }
});

// 5. [DELETE] HAPUS BARANG (Hanya Admin)
router.delete('/resources/:id', verifyAdminToken, async (req, res) => {
    const { id } = req.params;
    try {
        await db.execute('DELETE FROM resources WHERE id = ?', [id]);
        res.status(200).json({ success: true, message: 'Resource deleted successfully!' });
    } catch (error) {
        res.status(500).json({ message: 'Server error', error: error.message });
    }
});

module.exports = router;