import mysql from 'mysql2/promise';
import 'dotenv/config';

const db = mysql.createPool({
  host: process.env.DB_HOST || 'localhost',
  user: process.env.DB_USER || 'root',
  password: process.env.DB_PASSWORD || '',
  database: process.env.DB_NAME || 'drape_glow',
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0,
});

const connectDB = async () => {
  try {
    const connection = await db.getConnection();
    console.log('MySQL connected successfully.');
    connection.release();
  } catch (error) {
    console.error('MySQL connection failed:', error.message);
  }
};

connectDB();

export default db;