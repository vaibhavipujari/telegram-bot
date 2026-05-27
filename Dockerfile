# Multi-stage build for optimized production image
FROM node:18-alpine AS base

# Set working directory
WORKDIR /app

# Install dumb-init for proper signal handling
RUN apk add --no-cache dumb-init

# Copy package files
COPY package*.json ./

# Development stage
FROM base AS development
ENV NODE_ENV=development
# Install all dependencies (including dev dependencies)
RUN npm ci
# Copy application code
COPY . .
# Explicitly ensure HTML files are copied (for development)
COPY *.html ./
# Create uploads directory
RUN mkdir -p uploads
# Expose port
EXPOSE 3000
# Start with nodemon for development
CMD ["npm", "run", "dev"]

# Production dependencies stage
FROM base AS production-deps
ENV NODE_ENV=production
# Install only production dependencies
RUN npm ci --only=production && npm cache clean --force

# Production stage
FROM base AS production
ENV NODE_ENV=production

# Copy production dependencies
COPY --from=production-deps /app/node_modules ./node_modules

# Copy application code
COPY . .

# Explicitly ensure HTML files are copied (for Render deployment)
COPY *.html ./

# Create uploads directory with proper permissions
RUN mkdir -p uploads

# Create non-root user for security
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001

# Change ownership of app directory
RUN chown -R nodejs:nodejs /app

# Switch to non-root user
USER nodejs

# Expose port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
  CMD node -e "require('http').get('http://localhost:3000/health', (res) => { process.exit(res.statusCode === 200 ? 0 : 1) })" || exit 1

# Use dumb-init to handle signals properly
ENTRYPOINT ["dumb-init", "--"]

# Start the application
CMD ["npm", "start"]
