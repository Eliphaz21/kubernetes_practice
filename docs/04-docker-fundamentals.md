# Module 04: Docker Fundamentals

## Organization: CSEC ASTU – Development Division
### Project: CSEC Welcome – Cloud-Native Kubernetes & DevOps Training Curriculum

---

### Step 1 – What are we learning?
In this module, you are learning containerization principles using **Docker**. We cover the fundamental architecture of the Docker engine, the difference between an image and a container, image layers, the container lifecycle, and essential Docker CLI commands.

### Step 2 – Why do we need it?
The classic developer dilemma is: *"It works on my machine, why doesn't it work in production?"* Differences in operating systems, Node.js versions, installed libraries, and system paths cause software to break when transferred between developer laptops and cloud servers.
Docker solves this by packaging the code, runtime, system tools, and dependencies into a lightweight, standalone, executable package called a **Container**. A container runs identically anywhere Docker is installed.

### Step 3 – What are we going to create?
We will inspect, run, monitor, and troubleshoot standalone Docker containers using core Docker CLI commands on our workstation.

### Step 4 – Where do we create it?
Documented at `c:\devops\docs\04-docker-fundamentals.md`.

### Step 5 – Complete Command Workflow
```powershell
# 1. Verify Docker Engine status
docker version

# 2. Pull and run a test container
docker run --rm hello-world

# 3. List local images
docker images

# 4. List running containers
docker ps

# 5. List all containers (active and stopped)
docker ps -a

# 6. Inspect container metadata
docker inspect hello-world

# 7. View network bridges
docker network ls
```

### Step 6 – Code / Command Explanation
- `docker run`: Creates a writeable container layer over the specified image and starts it.
  - `--rm`: Automatically removes the container file system when it terminates.
  - `-d`: Detached mode (runs the container in the background).
  - `-p hostPort:containerPort`: Binds a port on the host machine to the container port.
- **Image vs. Container**:
  - An **Image** is a read-only blueprint (like a Class in OOP).
  - A **Container** is an active, running instance of an image (like an Object in OOP).
- **Union File System (Image Layers)**: Each instruction in a Dockerfile adds a read-only layer. Layers are cached and reused across images, drastically saving disk space and download time.

### Step 7 – Execute
Open PowerShell and run:
```powershell
docker run -d --name alpine-test -p 8000:80 nginx:alpine
docker ps
```

### Step 8 – Expected Result
```
CONTAINER ID   IMAGE          COMMAND                  CREATED         STATUS         PORTS                  NAMES
a1b2c3d4e5f6   nginx:alpine   "/docker-entrypoint.…"   3 seconds ago   Up 2 seconds   0.0.0.0:8000->80/tcp   alpine-test
```

### Step 9 – Verify
Test connectivity using `curl`:
```powershell
curl.exe http://localhost:8000
```
*Expected Output*: HTML content including `<title>Welcome to nginx!</title>`.

### Step 10 – Troubleshoot
- **Problem**: `error during connect: This error may indicate that the docker daemon is not running.`
  - **Solution**: Open Docker Desktop from your Start menu and wait for the status icon to turn green.
- **Problem**: `Bind for 0.0.0.0:8000 failed: port is already allocated`
  - **Solution**: Another service is using port 8000. Use a different host port: `-p 8001:80`.

### Step 11 – Practice
1. Execute an interactive shell inside your running container:
   ```powershell
   docker exec -it alpine-test sh
   ```
2. Inside the container, check the Alpine Linux version:
   ```sh
   cat /etc/os-release
   exit
   ```

### Step 12 – Cleanup
Stop and remove the practice container:
```powershell
docker stop alpine-test
docker rm alpine-test
```

### Step 13 – Production Connection
In cloud orchestration systems like AWS ECS and Kubernetes, Docker container images serve as the fundamental unit of deployment. Everything deployed to production begins as a Docker image.

