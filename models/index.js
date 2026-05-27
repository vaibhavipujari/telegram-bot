const mongoose = require('mongoose');

// APK Data Schema
const apkDataSchema = new mongoose.Schema({
  name: { type: String, required: true },
  version: { type: String, required: true },
  totalDownloads: { type: Number, default: 0 },
  uploadDate: { type: Date, default: Date.now },
  filePath: { type: String },
  fileId: { type: mongoose.Schema.Types.ObjectId }, // GridFS file ID
  fileSize: { type: Number },
  checksum: { type: String },
  platform: { type: String, enum: ['android', 'ios', 'both'], default: 'android' },
  isActive: { type: Boolean, default: true }
}, {
  timestamps: true
});

// Download Link Schema
const downloadLinkSchema = new mongoose.Schema({
  token: { type: String, required: true, unique: true },
  channelId: { type: String, required: true },
  channelName: { type: String, required: true },
  channelUsername: { type: String },
  downloadCount: { type: Number, default: 0 },
  isActive: { type: Boolean, default: true },
  createdAt: { type: Date, default: Date.now },
  lastAccessedAt: { type: Date }
}, {
  timestamps: true
});

// Device Registration Schema
const deviceRegistrationSchema = new mongoose.Schema({
  deviceId: { type: String, required: true, unique: true },
  platform: { type: String, required: true, enum: ['android', 'ios'] },
  appVersion: { type: String, default: 'unknown' },
  osVersion: { type: String, default: 'unknown' },
  deviceModel: { type: String, default: 'unknown' },
  registeredAt: { type: Date, default: Date.now },
  lastCheckAt: { type: Date, default: Date.now },
  updateCount: { type: Number, default: 0 },
  isActive: { type: Boolean, default: true },
  metadata: {
    userAgent: String,
    ipAddress: String,
    country: String,
    language: String
  }
}, {
  timestamps: true
});

// Update Analytics Schema
const updateAnalyticsSchema = new mongoose.Schema({
  eventId: { type: String, required: true, unique: true },
  eventType: { 
    type: String, 
    required: true,
    enum: ['version_check', 'download_start', 'download_complete', 'download_error', 
           'update_complete', 'device_register', 'notification_sent', 'metadata_request']
  },
  deviceId: { type: String, required: true },
  version: { type: String },
  platform: { type: String, enum: ['android', 'ios'] },
  timestamp: { type: Date, default: Date.now },
  userAgent: { type: String },
  ipAddress: { type: String },
  metadata: {
    type: mongoose.Schema.Types.Mixed,
    default: {}
  }
}, {
  timestamps: true
});

// Rate Limit Schema
const rateLimitSchema = new mongoose.Schema({
  ipAddress: { type: String, required: true, unique: true },
  requests: [{ type: Date }],
  lastCleanup: { type: Date, default: Date.now }
}, {
  timestamps: true
});

// App Version Schema
const appVersionSchema = new mongoose.Schema({
  version: { type: String, required: true, unique: true },
  platform: { type: String, required: true, enum: ['android', 'ios', 'both'] },
  releaseNotes: { type: String },
  isForced: { type: Boolean, default: false },
  minimumOsVersion: { type: String },
  supportedArchitectures: [{ type: String }],
  downloadUrl: { type: String },
  storeUrl: { type: String },
  fileSize: { type: Number },
  checksum: { type: String },
  releaseDate: { type: Date, default: Date.now },
  isActive: { type: Boolean, default: true }
}, {
  timestamps: true
});

// Create Models
const ApkData = mongoose.model('ApkData', apkDataSchema);
const DownloadLink = mongoose.model('DownloadLink', downloadLinkSchema);
const DeviceRegistration = mongoose.model('DeviceRegistration', deviceRegistrationSchema);
const UpdateAnalytics = mongoose.model('UpdateAnalytics', updateAnalyticsSchema);
const RateLimit = mongoose.model('RateLimit', rateLimitSchema);
const AppVersion = mongoose.model('AppVersion', appVersionSchema);

module.exports = {
  ApkData,
  DownloadLink,
  DeviceRegistration,
  UpdateAnalytics,
  RateLimit,
  AppVersion
};
