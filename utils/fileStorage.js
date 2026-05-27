const fs = require('fs');
const crypto = require('crypto');
const path = require('path');
const dbConnection = require('../config/database');
const { ApkData } = require('../models');

class FileStorageManager {
  constructor() {
    this.gridfsBucket = null;
  }

  initialize() {
    this.gridfsBucket = dbConnection.getGridFSBucket();
  }

  // Store APK file in GridFS
  async storeApkFile(filePath, metadata = {}) {
    return new Promise((resolve, reject) => {
      if (!this.gridfsBucket) {
        return reject(new Error('GridFS not initialized'));
      }

      if (!fs.existsSync(filePath)) {
        return reject(new Error('File not found'));
      }

      const filename = metadata.originalName || path.basename(filePath);
      const fileStats = fs.statSync(filePath);
      
      // Generate checksum
      const hash = crypto.createHash('md5');
      const readStream = fs.createReadStream(filePath);
      
      readStream.on('data', (chunk) => {
        hash.update(chunk);
      });

      readStream.on('end', () => {
        const checksum = hash.digest('hex');
        
        // Create upload stream to GridFS
        const uploadStream = this.gridfsBucket.openUploadStream(filename, {
          metadata: {
            ...metadata,
            originalPath: filePath,
            uploadDate: new Date(),
            checksum: checksum,
            size: fileStats.size,
            contentType: 'application/vnd.android.package-archive'
          }
        });

        // Pipe file to GridFS
        const fileReadStream = fs.createReadStream(filePath);
        fileReadStream.pipe(uploadStream);

        uploadStream.on('finish', () => {
          console.log(`📁 APK file stored in GridFS: ${filename} (ID: ${uploadStream.id})`);
          resolve({
            fileId: uploadStream.id,
            filename: filename,
            size: fileStats.size,
            checksum: checksum,
            uploadDate: new Date()
          });
        });

        uploadStream.on('error', (error) => {
          console.error('❌ GridFS upload error:', error);
          reject(error);
        });
      });

      readStream.on('error', (error) => {
        reject(error);
      });
    });
  }

  // Retrieve APK file from GridFS
  async getApkFile(fileId) {
    return new Promise((resolve, reject) => {
      if (!this.gridfsBucket) {
        return reject(new Error('GridFS not initialized'));
      }

      const downloadStream = this.gridfsBucket.openDownloadStream(fileId);
      const chunks = [];

      downloadStream.on('data', (chunk) => {
        chunks.push(chunk);
      });

      downloadStream.on('end', () => {
        const fileBuffer = Buffer.concat(chunks);
        resolve(fileBuffer);
      });

      downloadStream.on('error', (error) => {
        reject(error);
      });
    });
  }

  // Stream APK file from GridFS
  getApkFileStream(fileId) {
    if (!this.gridfsBucket) {
      throw new Error('GridFS not initialized');
    }

    return this.gridfsBucket.openDownloadStream(fileId);
  }

  // Delete APK file from GridFS
  async deleteApkFile(fileId) {
    try {
      if (!this.gridfsBucket) {
        throw new Error('GridFS not initialized');
      }

      await this.gridfsBucket.delete(fileId);
      console.log(`🗑️  APK file deleted from GridFS: ${fileId}`);
      return true;
    } catch (error) {
      console.error('❌ Error deleting APK file:', error);
      throw error;
    }
  }

  // Get file metadata from GridFS
  async getFileMetadata(fileId) {
    try {
      if (!this.gridfsBucket) {
        throw new Error('GridFS not initialized');
      }

      const files = await this.gridfsBucket.find({ _id: fileId }).toArray();
      
      if (files.length === 0) {
        throw new Error('File not found');
      }

      return files[0];
    } catch (error) {
      console.error('❌ Error getting file metadata:', error);
      throw error;
    }
  }

  // List all APK files
  async listApkFiles(limit = 50) {
    try {
      if (!this.gridfsBucket) {
        throw new Error('GridFS not initialized');
      }

      const files = await this.gridfsBucket.find({}).limit(limit).toArray();
      return files;
    } catch (error) {
      console.error('❌ Error listing APK files:', error);
      throw error;
    }
  }

  // Clean up old APK files
  async cleanupOldFiles(daysOld = 30) {
    try {
      if (!this.gridfsBucket) {
        throw new Error('GridFS not initialized');
      }

      const cutoffDate = new Date();
      cutoffDate.setDate(cutoffDate.getDate() - daysOld);

      const oldFiles = await this.gridfsBucket.find({
        uploadDate: { $lt: cutoffDate }
      }).toArray();

      let deletedCount = 0;
      for (const file of oldFiles) {
        await this.gridfsBucket.delete(file._id);
        deletedCount++;
      }

      console.log(`🧹 Cleaned up ${deletedCount} old APK files`);
      return deletedCount;
    } catch (error) {
      console.error('❌ Error cleaning up old files:', error);
      throw error;
    }
  }

  // Get storage statistics
  async getStorageStats() {
    try {
      if (!this.gridfsBucket) {
        throw new Error('GridFS not initialized');
      }

      const files = await this.gridfsBucket.find({}).toArray();
      
      const stats = {
        totalFiles: files.length,
        totalSize: files.reduce((sum, file) => sum + (file.length || 0), 0),
        averageSize: 0,
        oldestFile: null,
        newestFile: null
      };

      if (files.length > 0) {
        stats.averageSize = stats.totalSize / files.length;
        stats.oldestFile = files.reduce((oldest, file) => 
          (!oldest || file.uploadDate < oldest.uploadDate) ? file : oldest
        );
        stats.newestFile = files.reduce((newest, file) => 
          (!newest || file.uploadDate > newest.uploadDate) ? file : newest
        );
      }

      return stats;
    } catch (error) {
      console.error('❌ Error getting storage stats:', error);
      throw error;
    }
  }
}

// Create singleton instance
const fileStorage = new FileStorageManager();

module.exports = fileStorage;
