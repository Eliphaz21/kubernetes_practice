# Module 05: Dockerfiles and Multi-Stage Containerization

## Organization: CSEC ASTU – Development Division
### Project: CSEC Welcome – Cloud-Native Kubernetes & DevOps Training Curriculum

---

### Step 1 – What are we learning?
In this module, you will learn how to write production-grade **Dockerfiles** using **multi-stage builds** for both the frontend (React + Vite + Nginx) and backend (Node.js + Express + TypeScript). You will learn why single-stage Dockerfiles produce bloated, insecure images and how multi-stage builds reduce image sizes by over 80%.

### Step 2 – Why do we need it?
A single-stage build that includes compilers, TypeScript, package managers, and development source files has three severe problems:
1. **Bloated Image Sizes**: Storing `node_modules` with devDependencies results in 800MB+ images, slowing down network transfer and scaling speed.
2. **Security Vulnerabilities**: Tools like compilers (`tsc`, `gcc`) and package installers leave an unnecessarily large attack surface if a container is compromised.
3. **Privilege Escalation**: Running containers as the default `root` user allows container breakout attacks to compromise the host kernel.

Multi-stage builds solve this by separating the **build environment** from the **runtime environment**.

### Step 3 – What are we going to create?
- `backend/Dockerfile`: Multi-stage build compiling TypeScript and running as non-root user `node`.
- `frontend/Dockerfile`: Multi-stage build producing static React assets and serving them via Nginx.
- `frontend/nginx.conf`: Nginx server configuration with `/api` reverse proxying.
- `scripts/build-images.ps1`: Automated PowerShell image build script.

### Step 4 – Where do we create it?
- `c:\devops\backend\Dockerfile`
- `c:\devops\frontend\Dockerfile`
- `c:\devops\frontend\nginx.conf`
- `c:\devops\scripts\build-images.ps1`

### Step 5 – Complete Code

#### Backend Multi-Stage Dockerfile (`backend/Dockerfile`)
```dockerfile
# Stage 1: Build
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY tsconfig.json ./
COPY src/ ./src/
RUN npm run build

# Stage 2: Runtime
FROM node:20-alpine AS runner
WORKDIR /app
ENV NODE_ENV=production PORT=5000 HOST=0.0.0.0
COPY package*.json ./
RUN npm ci --only=production && npm cache clean --force
COPY --from=builder /app/dist ./dist
USER node
EXPOSE 5000
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://127.0.0.1:5000/api/health || exit 1
CMD ["node", "dist/server.js"]
```

#### Frontend Multi-Stage Dockerfile (`frontend/Dockerfile`)
```dockerfile
# Stage 1: Build
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY tsconfig*.json ./
COPY vite.config.ts ./
COPY index.html ./
COPY src/ ./src/
RUN npm run build

# Stage 2: Runtime
FROM nginx:1.27-alpine AS runner
RUN rm -rf /etc/nginx/conf.d/* /usr/share/nginx/html/*
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=builder /app/dist /usr/share/nginx/html
EXPOSE 80
HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://127.0.0.1:80/healthz || exit 1
CMD ["nginx", "-g", "daemon off;"]
```

### Step 6 – Code Explanation
1. `AS builder`: Names the initial stage. The temporary files, intermediate build cache, and devDependencies created here are discarded when the stage ends.
2. `COPY --from=builder /app/dist ./dist`: Extracts **only** the compiled JavaScript output from the builder into the pristine runner stage.
3. `USER node`: Drops root privileges. `node` is a pre-existing non-privileged user (UID 1000) built into the official Alpine image.
4. `HEALTHCHECK`: Enables the Docker daemon to monitor container liveness without external probing tools.
5. `nginx.conf` Reverse Proxy:
   ```nginx
   location /api/ {
       proxy_pass http://backend:5000;
   }
   ```
   When the browser requests `/api/welcome`, Nginx intercepts it and transparently forwards it to the backend container over internal DNS.

### Step 7 – Execute
Run the automated image build script from PowerShell:
```powershell
Set-Location -Path "c:\devops"
.\scripts\build-images.ps1 -Tag "v1.0.0"
```

### Step 8 – Expected Result
```
====================================================
 CSEC ASTU Container Image Builder
 Tag:      v1.0.0
 Registry: csec-astu
====================================================

[1/2] Building Backend Docker Image...
...
[2/2] Building Frontend Docker Image...
...
====================================================
 Build Complete! Image Summary:
====================================================
REPOSITORY                        TAG       SIZE
csec-astu/csec-welcome-frontend   latest    25.4MB
csec-astu/csec-welcome-frontend   v1.0.0    25.4MB
csec-astu/csec-welcome-backend    latest    184MB
csec-astu/csec-welcome-backend    v1.0.0    184MB
```

### Step 9 – Verify
Run a standalone test of the backend image:
```powershell
docker run -d --name test-backend -p 5000:5000 csec-astu/csec-welcome-backend:v1.0.0
Start-Sleep -Seconds 2
curl.exe http://localhost:5000/api/health
```
*Expected Output*: `{"status":"healthy","service":"csec-welcome-backend",...}`

### Step 10 – Troubleshoot
- **Problem**: `npm ci can only install packages when your package.json and package-lock.json are in sync.`
  - **Solution**: Run `npm install` locally in the directory first to regenerate `package-lock.json`, then rebuild the Docker image.
- **Problem**: `COPY failed: file not found in build context`
  - **Solution**: Verify your `.dockerignore` file is not accidentally ignoring `tsconfig.json` or `src/`.

### Step 11 – Practice
Inspect the layers of the generated frontend image:
```powershell
docker history csec-astu/csec-welcome-frontend:v1.0.0
```
Notice how the top layer containing your React build is only a few hundred kilobytes!

### Step 12 – Cleanup
```powershell
docker stop test-backend
docker rm test-backend
```

### Step 13 – Production Connection
Cloud container registries (like AWS ECR and GitHub Packages GHCR) charge for image storage and network egress. Multi-stage builds keep images slim, saving costs, speeding up Kubernetes auto-scaling, and adhering to the Center for Internet Security (CIS) Docker Benchmark.

