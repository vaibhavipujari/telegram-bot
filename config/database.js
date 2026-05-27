const mongoose = require('mongoose');
const Grid = require('gridfs-stream');

class DatabaseConnection {
  constructor() {
    this.connection = null;
    this.gfs = null;
    this.gridfsBucket = null;
  }

  async connect() {
    try {
      const mongoUri = process.env.MONGODB_URI || 'mongodb+srv://brighthex28_db_user:paxb1lgQ9oT4Wrob@cluster0.lzhww6m.mongodb.net/linkserver?retryWrites=true&w=majority&appName=Cluster0';
      
      console.log('🔗 Connecting to MongoDB...');
      
      this.connection = await mongoose.connect(mongoUri, {
        maxPoolSize: 10,
        serverSelectionTimeoutMS: 5000,
        socketTimeoutMS: 45000,
      });

      console.log('✅ MongoDB connected successfully');

      // Initialize GridFS for file storage
      this.gridfsBucket = new mongoose.mongo.GridFSBucket(this.connection.connection.db, {
        bucketName: 'apkFiles'
      });

      // Initialize GridFS Stream (legacy support)
      this.gfs = Grid(this.connection.connection.db, mongoose.mongo);
      this.gfs.collection('apkFiles');

      console.log('✅ GridFS initialized for APK file storage');

      // Handle connection events
      this.connection.connection.on('error', (error) => {
        console.error('❌ MongoDB connection error:', error);
      });

      this.connection.connection.on('disconnected', () => {
        console.log('⚠️  MongoDB disconnected');
      });

      this.connection.connection.on('reconnected', () => {
        console.log('🔄 MongoDB reconnected');
      });

      return this.connection;
    } catch (error) {
      console.error('❌ MongoDB connection failed:', error);
      throw error;
    }
  }

  async disconnect() {
    try {
      if (this.connection) {
        await mongoose.disconnect();
        console.log('🔌 MongoDB disconnected');
      }
    } catch (error) {
      console.error('❌ Error disconnecting from MongoDB:', error);
      throw error;
    }
  }

  getGridFSBucket() {
    return this.gridfsBucket;
  }

  getGridFS() {
    return this.gfs;
  }

  isConnected() {
    return mongoose.connection.readyState === 1;
  }

  // Health check for database
  async healthCheck() {
    try {
      if (!this.isConnected()) {
        return { status: 'disconnected', message: 'Database not connected' };
      }

      // Ping the database
      await mongoose.connection.db.admin().ping();
      
      return { 
        status: 'healthy', 
        message: 'Database connection is healthy',
        readyState: mongoose.connection.readyState,
        host: mongoose.connection.host,
        port: mongoose.connection.port,
        name: mongoose.connection.name
      };
    } catch (error) {
      return { 
        status: 'error', 
        message: error.message,
        readyState: mongoose.connection.readyState
      };
    }
  }
}

// Create singleton instance
const dbConnection = new DatabaseConnection();

module.exports = dbConnection;
