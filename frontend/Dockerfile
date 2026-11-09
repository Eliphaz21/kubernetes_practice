# ==============================================================================
# CSEC Welcome Frontend - Multi-Stage Production Dockerfile
# Stage 1: Build React + Vite Single Page Application (SPA)
# Stage 2: High-performance Nginx web server and reverse proxy
# ==============================================================================

# ----------------- Stage 1: Build -----------------
FROM node:20-alpine AS builder

WORKDIR /app

# Copy dependency manifests
COPY package*.json ./

# Install dependencies
RUN npm ci

# Copy source code, templates, and configs
COPY tsconfig*.json ./
COPY vite.config.ts ./
COPY index.html ./
COPY src/ ./src/

# Build static production bundle into /app/dist
RUN npm run build

# ----------------- Stage 2: Runtime -----------------
FROM nginx:1.27-alpine AS runner

# Remove default Nginx welcome page and configuration
RUN rm -rf /etc/nginx/conf.d/* /usr/share/nginx/html/*

# Copy custom Nginx configuration with reverse proxy for /api
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy compiled static files from builder stage
COPY --from=builder /app/dist /usr/share/nginx/html

# Expose HTTP port
EXPOSE 80

# Container healthcheck querying the /healthz endpoint
HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://127.0.0.1:80/healthz || exit 1

# Start Nginx in foreground
CMD ["nginx", "-g", "daemon off;"]

