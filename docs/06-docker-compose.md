# Module 06: Docker Compose Multi-Container Orchestration

## Organization: CSEC ASTU – Development Division
### Project: CSEC Welcome – Cloud-Native Kubernetes & DevOps Training Curriculum

---

### Step 1 – What are we learning?
In this module, you are learning multi-container orchestration using **Docker Compose**. You will learn how to define, coordinate, network, and manage multi-tier applications (frontend web server and backend API) using a single declarative configuration file: `docker-compose.yaml`.

### Step 2 – Why do we need it?
Running distributed applications manually using separate `docker run` commands is cumbersome and error-prone:
- You must manually create networks, configure IP bindings, inject environment variables, and manage container startup order.
- If one container crashes or restarts, manual commands do not provide unified health monitoring.
Docker Compose allows you to define your entire multi-container architecture declaratively in version-controlled code. A single command (`docker compose up`) provisions the network, builds the images, starts the containers in the correct sequence, and tracks their logs.

### Step 3 – What are we going to create?
We will create and analyze the root multi-container configuration:
- `docker-compose.yaml` orchestrating `csec-frontend` (Nginx + React on port 8080) and `csec-backend` (Express API on port 5000) over an isolated bridge network (`csec-network`).

### Step 4 – Where do we create it?
At the root of the project: `c:\devops\docker-compose.yaml`.

### Step 5 – Complete Code
```yaml
services:
  backend:
    build:
      context: ./backend
      dockerfile: Dockerfile
    container_name: csec-backend
    restart: unless-stopped
    ports:
      - "5000:5000"
    environment:
      - PORT=5000
      - HOST=0.0.0.0
      - NODE_ENV=production
      - CORS_ORIGIN=*
    networks:
      - csec-network
    healthcheck:
      test: ["CMD-SHELL", "wget --no-verbose --tries=1 --spider http://127.0.0.1:5000/api/health || exit 1"]
      interval: 10s
      timeout: 5s
      retries: 3
      start_period: 5s

  frontend:
    build:
      context: ./frontend
      dockerfile: Dockerfile
    container_name: csec-frontend
    restart: unless-stopped
    ports:
      - "8080:80"
    depends_on:
      backend:
        condition: service_healthy
    networks:
      - csec-network
    healthcheck:
      test: ["CMD-SHELL", "wget --no-verbose --tries=1 --spider http://127.0.0.1:80/healthz || exit 1"]
      interval: 10s
      timeout: 5s
      retries: 3
      start_period: 5s

networks:
  csec-network:
    name: csec-network
    driver: bridge
```

### Step 6 – Code Explanation
1. **Service-Name DNS Resolution**:
   - Docker Compose creates an internal DNS server for `csec-network`.
   - The frontend Nginx container communicates with the backend using the service hostname `http://backend:5000`. You never need to hardcode dynamic private IP addresses!
2. **Conditional Dependency (`depends_on.condition: service_healthy`)**:
   - Traditional `depends_on` only waits for the container process to spawn, which often causes race conditions where the frontend starts before the backend is actually ready to answer HTTP requests.
   - Using `condition: service_healthy` guarantees that the backend's `/api/health` probe must return status `200` before the frontend container boots.
3. **Port Mapping**:
   - `8080:80`: Maps host port 8080 to container port 80.
   - `5000:5000`: Exposes the backend API port for direct inspection or debugging.

### Step 7 – Execute
Start Docker Desktop on your machine, then run in PowerShell:
```powershell
Set-Location -Path "c:\devops"
docker compose up --build
```
*(To run in background mode, use `docker compose up --build -d`)*

### Step 8 – Expected Result
```text
[+] Running 3/3
 ✔ Network csec-network    Created
 ✔ Container csec-backend  Healthy
 ✔ Container csec-frontend Started
```

### Step 9 – Verify
1. Verify container states and health checks:
   ```powershell
   docker compose ps
   ```
   *Expected Output*: Both containers show state `Up (healthy)`.

2. Test external browser access:
   - Visit: **[http://localhost:8080](http://localhost:8080)**
   - The React application displays with the CSEC ASTU welcome message, populated dynamically from the backend through the Nginx reverse proxy.

3. Verify API proxy routing:
   ```powershell
   curl.exe http://localhost:8080/api/health
   curl.exe http://localhost:8080/api/welcome
   ```

### Step 10 – Troubleshoot
- **Problem**: `Cannot connect to the Docker daemon at npipe:////./pipe/docker_engine`
  - **Solution**: Docker Desktop is not started. Launch Docker Desktop from the Windows Start menu.
- **Problem**: `Ports are not available: exposing port TCP 0.0.0.0:8080`
  - **Solution**: Port 8080 is used by another application. Edit `docker-compose.yaml` and change to `"8081:80"`.

### Step 11 – Practice
1. Inspect the internal Docker network created by Compose:
   ```powershell
   docker network inspect csec-network
   ```
2. Identify the assigned container IPv4 addresses in the output. Notice how Docker manages the internal subnet automatically.

### Step 12 – Cleanup
Gracefully stop and delete the running containers and internal network:
```powershell
docker compose down
```

### Step 13 – Production Connection
Docker Compose is the standard tool for local full-stack development, integration test runners, and ephemeral pull-request preview environments. The declarative concepts learned here (services, ports, healthchecks, networks, dependencies) translate directly into Kubernetes Pods, Services, and Deployments.
