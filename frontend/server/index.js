import express from 'express';
import 'dotenv/config';
import path from 'path';
import { fileURLToPath } from 'url';
import db from './config/db.js';
import authRoutes from './routes/authRoutes.js';
import uploadRoutes from './routes/uploadRoutes.js';
import authenticateToken from './middleware/authMiddleware.js';
import { profile } from './controllers/authController.js';

const app = express();
const PORT = process.env.PORT || 5000;
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const uploadsPath = path.resolve(__dirname, 'uploads');

// Middleware
app.use(express.json());
app.use('/uploads', express.static(uploadsPath));

// Routes
app.use('/auth', authRoutes);
app.use('/', uploadRoutes);
app.get('/profile', authenticateToken, profile);

// Health check
app.get('/health', (req, res) => {
  res.json({ message: 'Server is running.' });
});

// Start server
app.listen(PORT, () => {
  console.log(`Server running on http://localhost:${PORT}`);
});
