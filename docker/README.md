# Docker and Containerization Guide

## CSEC ASTU – Development Division
### Project: CSEC Welcome – Cloud-Native Kubernetes & DevOps Training Curriculum

---

## 1. Containerization Architecture

Containerization packages our application source code, runtime environment (Node.js/Nginx), and system dependencies into portable, isolated immutable artifacts called **Docker Images**.

```
[ Developer Workstation ]
        │
        ▼ (docker build)
┌─────────────────────────────────────────────────────────────────┐
│ Multi-Stage Dockerfile                                          │
│  Stage 1 (builder): node:20-alpine -> transpile TypeScript     │
│  Stage 2 (runner):  minimal production image (non-root)         │
└───────────────────────────────┬─────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────┐
│ Docker Images                                                   │
│  • csec-welcome-backend:latest (~180MB)                         │
│  • csec-welcome-frontend:latest (~25MB)                         │
└───────────────────────────────┬─────────────────────────────────┘
                                │
                                ▼ (docker compose up)
┌─────────────────────────────────────────────────────────────────┐
│ Isolated Bridge Network: 'csec-network'                         │
│                                                                 │
│  ┌───────────────────────┐             ┌─────────────────────┐  │
│  │   csec-frontend       │  /api/*     │   csec-backend      │  │
│  │   (Nginx :80)         ├────────────►│   (Node.js :5000)   │  │
│  │   Host Port: 8080     │  HTTP proxy │   Host Port: 5000   │  │
│  └───────────────────────┘             └─────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

---

## 2. Essential Docker CLI Commands

### Image Management
```powershell
# Build image manually
docker build -t csec-welcome-backend:v1.0.0 ./backend

# List local images
docker images

# Remove an image
docker rmi csec-welcome-backend:v1.0.0
```

### Container Execution
```powershell
# Run backend container in background
docker run -d --name csec-backend -p 5000:5000 csec-welcome-backend:v1.0.0

# List running containers
docker ps

# List all containers (including stopped)
docker ps -a

# View container logs
docker logs csec-backend
docker logs -f csec-backend # Follow logs

# Execute shell command inside running container
docker exec -it csec-backend sh

# Inspect container low-level JSON details (IP, mounts, state)
docker inspect csec-backend

# Stop and remove container
docker stop csec-backend
docker rm csec-backend
```

### Docker Compose Multi-Container
```powershell
# Build images and start all services in foreground
docker compose up --build

# Start in detached background mode
docker compose up -d

# Check service health and port mappings
docker compose ps

# View unified service logs
docker compose logs -f

# Gracefully terminate and remove containers & networks
docker compose down
```

---

## 3. Security Best Practices Enforced
1. **Pinned Base Images**: Uses `node:20-alpine` and `nginx:1.27-alpine` instead of mutable `latest` tags.
2. **Multi-Stage Builds**: Development tools (`typescript`, `tsx`, `@types/*`) never enter the production runtime image.
3. **Non-Root Execution**: Backend container runs as user `node` (`UID 1000`) rather than root.
4. **No Hardcoded Secrets**: Configuration is passed via environment variables at runtime.
5. **Built-in Health Checks**: Uses `HEALTHCHECK` with `wget` spider queries to verify container readiness.
