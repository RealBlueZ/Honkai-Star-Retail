const express = require('express');
const db = require('../config/db');
const multer = require('multer');
const path = require('path');
const fs = require('fs');
const { verifyToken, isAdmin } = require('../middlewares/authMiddleware');

const router = express.Router();

const uploadDir = path.join(__dirname, '../public/images');
if (!fs.existsSync(uploadDir)) {
    fs.mkdirSync(uploadDir, { recursive: true });
}

const storage = multer.diskStorage({
    destination: (req, file, cb) => {
        cb(null, uploadDir); // Menyimpan ke folder public/uploads
    },
    filename: (req, file, cb) => {
        // Mengubah nama file menjadi unik: timestamp + extension
        const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
        cb(null, uniqueSuffix + path.extname(file.originalname));
    }
});

const fileFilter = (req, file, cb) => {
    cb(null, true);
};

const upload = multer({ storage: storage, fileFilter: fileFilter });

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
    // 1. Ambil data dari req.body. Pastikan membaca 'image_url' sesuai kiriman Flutter terbaru!
    const { name, type, description, stock, image_url, price } = req.body;

    // 2. Validasi Keamanan: Pastikan field penting tidak kosong
    if (!name || !type || stock === undefined || !image_url || price === undefined) {
        return res.status(400).json({ message: 'Fields name, type, stock, image_url, and price are required.' });
    }

    const finalDescription = description || "No description provided";

    try {
        const [result] = await db.execute(
            'INSERT INTO resources (name, type, description, stock, image_url, price) VALUES (?, ?, ?, ?, ?, ?)',
            [name, type, finalDescription, stock, image_url, price]
        );
        
        res.status(201).json({ success: true, message: 'Resource added successfully!', id: result.insertId });
    } catch (error) {

        console.error("DATABASE CRASH LOG:", error.message); 
        
        res.status(500).json({ 
            message: 'Server Database Error', 
            error: error.message
        });
    }
});

// 4. [PUT] UPDATE BARANG (Hanya Admin)
router.put('/resources/:id', verifyToken, isAdmin, async (req, res) => {
    const { id } = req.params;
    const { name, type, description, stock, image, price } = req.body;

    try {
        const desc = description || "No description provided";
        await db.execute(
            'UPDATE resources SET name=?, type=?, description=?, stock=?, image_url=?, price=? WHERE id=?',
            [name, type, description, stock, image, price, id]
        );
        res.status(200).json({ success: true, message: 'Resource updated successfully!' });
    } catch (error) {
        res.status(500).json({ message: 'Server error', error: error.message });
    }
});

// 5. [DELETE] HAPUS BARANG (Hanya Admin)
router.delete('/resources/:id', verifyToken, isAdmin, async (req, res) => {
    const { id } = req.params;
    try {
        await db.execute('DELETE FROM resources WHERE id = ?', [id]);
        res.status(200).json({ success: true, message: 'Resource deleted successfully!' });
    } catch (error) {
        res.status(500).json({ message: 'Server error', error: error.message });
    }
});

router.post('/transactions', verifyToken, async (req, res) => {
    const { total_price, items } = req.body;

    if (!items || !Array.isArray(items) || items.length === 0) {
        return res.status(400).json({ success: false, message: 'Keranjang belanja kosong.' });
    }

    try {
        // VALIDASI
        for (const item of items) {
            const resource_id = item.resource_id ?? item.resourceId ?? item.id;
            const quantity = item.quantity ?? item.qty ?? item.count;

            if (resource_id === undefined || quantity === undefined) {
                console.error("Validasi Gagal: Item transaksi kekurangan properti id/quantity!", item);
                return res.status(400).json({ 
                    success: false, 
                    message: 'Format data transaksi dari aplikasi salah (resource_id atau quantity bernilai undefined).' 
                });
            }

            const [rows] = await db.execute('SELECT stock, name FROM resources WHERE id = ?', [resource_id]);
            
            if (rows.length === 0) {
                return res.status(444).json({ success: false, message: `Barang dengan ID ${resource_id} tidak ditemukan.` });
            }

            const product = rows[0];

            // Jika stok di DB kurang dari jumlah yang dibeli user, gagalkan transaksi secara aman
            if (product.stock < quantity) {
                return res.status(400).json({ 
                    success: false, 
                    message: `Checkout Gagal! Stok ${product.name} tidak mencukupi (Tersisa: ${product.stock}).` 
                });
            }
        }

        // EKSEKUSI DATA MUTATION
        for (const item of items) {
            const { resource_id, quantity } = item;
            await db.execute('UPDATE resources SET stock = stock - ? WHERE id = ?', [quantity, resource_id]);
        }

        // Catatan Kelompok: Jika kamu memiliki tabel `transactions` di DB, buka komentar di bawah ini:
        // await db.execute('INSERT INTO transactions (user_id, total_price) VALUES (?, ?)', [req.user.id, total_price]);

        res.status(201).json({ 
            success: true, 
            message: 'Transaction processing successful! Database stock updated.' 
        });

    } catch (error) {
        console.error("TRANSACTION CRASH LOG:", error.message);
        res.status(500).json({ message: 'Server failed to process transaction', error: error.message });
    }
});

router.post('/checkout', verifyToken, async (req, res) => {
    try {
        const { total_price, items } = req.body;

        if (!items || items.length === 0) {
            return res.status(400).json({ message: 'Cart is empty' });
        }

        // Ambil user_id dari token yang terverifikasi (req.user dikirim dari verifyToken)
        const userId = req.user.id; 

        // Jalankan transaksi database (Looping item untuk update stock dan catat transaksi)
        for (const item of items) {
            const { resource_id, quantity } = item;
            
            // 1. Kurangi stok barang di database
            await db.execute(
                'UPDATE resources SET stock = stock - ? WHERE id = ?', 
                [quantity, resource_id]
            );

            // 2. Masukkan ke tabel transactions sesuai struktur kolom databasemu
            // Kolom id (auto increment) dan transaction_date (DEFAULT CURRENT_TIMESTAMP / NOW())
            await db.execute(
                'INSERT INTO transactions (user_id, resource_id, quantity, total_price) VALUES (?, ?, ?, ?)',
                [userId, resource_id, quantity, total_price]
            );
        }

        res.status(201).json({ 
            success: true, 
            message: 'Transaction processing successful! Database stock & history updated.' 
        });

    } catch (error) {
        console.error("TRANSACTION CRASH LOG:", error.message);
        res.status(500).json({ message: 'Server failed to process transaction', error: error.message });
    }
});

router.get('/transactions', verifyToken, async (req, res) => {
    try {
        const userId = req.user.id;

        // Kita gunakan JOIN agar bisa mengambil nama barang dari tabel resources sekaligus
        const [rows] = await db.execute(`
            SELECT t.*, r.name AS resource_name 
            FROM transactions t
            JOIN resources r ON t.resource_id = r.id
            WHERE t.user_id = ?
            ORDER BY t.id DESC
        `, [userId]);

        res.status(200).json({
            success: true,
            data: rows
        });
    } catch (error) {
        console.error("GET TRANSACTIONS ERROR:", error.message);
        res.status(500).json({ message: 'Server failed to fetch transaction history', error: error.message });
    }
});

router.post('/upload-image', verifyToken, isAdmin, upload.single('image'), (req, res) => {
    try {
        if (!req.file) {
            return res.status(400).json({ message: 'No file uploaded.' });
        }
        
        // Kembalikan nama file yang tersimpan ke Flutter
        res.status(200).json({
            success: true,
            message: 'Image uploaded successfully!',
            filename: req.file.filename, // Nama file unik untuk disimpan di MySQL
            url: `http://10.0.2.2:3000/uploads/${req.file.filename}` // URL lengkap untuk testing
        });
    } catch (error) {
        res.status(500).json({ message: 'Upload failed', error: error.message });
    }
});

module.exports = router;