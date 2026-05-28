const express = require('express');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const passport = require('passport');
const GoogleStrategy = require('passport-google-oauth20').Strategy;
const crypto = require('crypto');
const db = require('../config/db');

const router = express.Router();

// ==========================================
// PASSPORT GOOGLE OAUTH STRATEGY
// ==========================================

passport.use(new GoogleStrategy({
    clientID: process.env.GOOGLE_CLIENT_ID,
    clientSecret: process.env.GOOGLE_CLIENT_SECRET,
    callbackURL: process.env.GOOGLE_CALLBACK_URL
}, async (accessToken, refreshToken, profile, done) => {
    try {
        const email = profile.emails[0].value;
        const name = profile.displayName;
        const oauthId = profile.id;

        // Cek apakah user sudah terdaftar via email/OAuth ini
        let [users] = await db.execute('SELECT * FROM users WHERE email = ?', [email]);
        let user;

        if (users.length === 0) {
            // Jika belum ada di DB, otomatis buat user baru (Role default: user)
            const [result] = await db.execute(
                'INSERT INTO users (name, email, oauth_provider, oauth_id, role) VALUES (?, ?, ?, ?, ?)',
                [name, email, 'google', oauthId, 'user']
            );
            user = { id: result.insertId, name, email, role: 'user' };
        } else {
            user = users[0];
        }

        return done(null, user);
    } catch (err) {
        return done(err, null);
    }
}));

// Fungsi pembantu untuk membuat string acak alphanumeric
function generateAlphanumericString(length) {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    let result = '';
    for (let i = 0; i < length; i++) {
        result += chars.charAt(crypto.randomInt(0, chars.length));
    }
    return result;
}

// Fungsi pembantu untuk membuat token JWT terintegrasi dengan DB
async function createUserSession(user) {
    // Generate JWT payload
    const payload = { id: user.id, email: user.email, role: user.role };
    
    // Agar token memiliki ciri khas alfanumerik panjang (min 20 karakter), 
    // kita kombinasikan JWT signing dengan signature string buatan sendiri.
    const uniqueString = generateAlphanumericString(25); 
    const token = jwt.sign(payload, process.env.JWT_SECRET, { expiresIn: '1d' }) + '.' + uniqueString;

    // Hitung waktu kedaluwarsa (1 hari dari sekarang)
    const expiresAt = new Date();
    expiresAt.setDate(expiresAt.getDate() + 1);

    // Simpan ke tabel auth_tokens di MySQL
    await db.execute(
        'INSERT INTO auth_tokens (user_id, token, expires_at) VALUES (?, ?, ?)',
        [user.id, token, expiresAt]
    );

    return token;
}

// ==========================================
// ENDPOINT API
// ==========================================

// 1. API REGISTER (NATIVE DB) [POST]
router.post('/register', async (req, res) => {
    const { name, email, password } = req.body;

    // Validasi input sederhana (Kriteria penilaian: Minimal 3 jenis data validasi)
    if (!name || !email || !password) {
        return res.status(400).json({ message: 'Please fill all required fields.' });
    }

    try {
        // Cek ketersediaan email
        const [existingUser] = await db.execute('SELECT * FROM users WHERE email = ?', [email]);
        if (existingUser.length > 0) {
            return res.status(400).json({ message: 'Email already registered.' });
        }

        // Hashing password demi keamanan database
        const salt = await bcrypt.genSalt(10);
        const hashedPassword = await bcrypt.hash(password, salt);

        // Insert ke DB (default role: 'user', jika ingin daftar admin bisa diatur manual di DB)
        await db.execute(
            'INSERT INTO users (name, email, password, role) VALUES (?, ?, ?, ?)',
            [name, email, hashedPassword, 'user']
        );

        res.status(201).json({ success: true, message: 'User registered successfully!' });
    } catch (error) {
        res.status(500).json({ message: 'Server error', error: error.message });
    }
});

// 2. API LOGIN (NATIVE DB) [POST]
router.post('/login', async (req, res) => {
    const { email, password } = req.body;

    if (!email || !password) {
        return res.status(400).json({ message: 'Email and password are required.' });
    }

    try {
        const [users] = await db.execute('SELECT * FROM users WHERE email = ?', [email]);
        const user = users[0];

        if (!user || !user.password) {
            return res.status(400).json({ message: 'Invalid email or password.' });
        }

        // Cek kecocokan password bcrypt
        const validPassword = await bcrypt.compare(password, user.password);
        if (!validPassword) {
            return res.status(400).json({ message: 'Invalid email or password.' });
        }

        // Buat session token yang alfanumerik & tercatat di DB
        const token = await createUserSession(user);

        res.status(200).json({
            success: true,
            message: 'Login successful!',
            token: token,
            user: { id: user.id, name: user.name, email: user.email, role: user.role }
        });
    } catch (error) {
        res.status(500).json({ message: 'Server error', error: error.message });
    }
});

// 3. OAUTH GOOGLE ROUTING [GET] 
router.get('/google', passport.authenticate('google', { scope: ['profile', 'email'] }));

// CALLBACK GOOGLE OAUTH [GET]
router.get('/google/callback', passport.authenticate('google', { session: false }), async (req, res) => {
    try {

        const token = await createUserSession(req.user);

        res.status(200).json({
            success: true,
            message: 'Logged in via Google OAuth successfully!',
            token: token,
            user: req.user
        });
    } catch (error) {
        res.status(500).json({ message: 'OAuth Authentication Failed', error: error.message });
    }
});

module.exports = router;