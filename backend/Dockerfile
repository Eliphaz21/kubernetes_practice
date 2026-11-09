# ==============================================================================
# CSEC Welcome Backend - Multi-Stage Production Dockerfile
# Stage 1: Build TypeScript into JavaScript
# Stage 2: Minimal, secure Alpine runtime with non-root execution
# ==============================================================================

# ----------------- Stage 1: Build -----------------
FROM node:20-alpine AS builder

WORKDIR /app

# Copy dependency manifests
COPY package*.json ./

# Install all dependencies (including devDependencies needed for build)
RUN npm ci

# Copy source code and TypeScript config
COPY tsconfig.json ./
COPY src/ ./src/

# Transpile TypeScript to JavaScript in /app/dist
RUN npm run build

# ----------------- Stage 2: Runtime -----------------
FROM node:20-alpine AS runner

WORKDIR /app

# Set production environment
ENV NODE_ENV=production \
    PORT=5000 \
    HOST=0.0.0.0

# Copy dependency manifests and install production-only dependencies
COPY package*.json ./
RUN npm ci --only=production && npm cache clean --force

# Copy compiled JavaScript output from builder stage
COPY --from=builder /app/dist ./dist

# Create and switch to non-root user for security hardening
USER node

# Expose backend port
EXPOSE 5000

# Container healthcheck querying the liveness endpoint
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://127.0.0.1:5000/api/health || exit 1

# Start production server
CMD ["node", "dist/server.js"]

