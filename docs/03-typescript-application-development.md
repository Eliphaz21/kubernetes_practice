# Module 03: TypeScript Application Development (Frontend & Backend)

## Organization: CSEC ASTU – Development Division
### Project: CSEC Welcome – Cloud-Native Kubernetes & DevOps Training Curriculum

---

### Step 1 – What are we learning?
In this module, you will build and understand the complete source code of the **CSEC Welcome** application:
1. A **React 18** frontend created with **Vite** and **TypeScript** (`.tsx`), featuring a clean, responsive layout representing the CSEC ASTU community.
2. A lightweight **Express.js** backend built with **TypeScript** (`.ts`), exposing REST endpoints (`/api/welcome`, `/api/health`, `/api/ready`).
3. The role of **TypeScript strict mode**, compiler configurations (`tsconfig.json`), the critical difference between `.ts` and `.tsx` files, and automated testing with supertest.

### Step 2 – Why do we need it?
- **TypeScript Static Typing**: JavaScript is dynamically typed, meaning runtime type errors (e.g., `undefined is not a function`) can easily crash production services. TypeScript checks types during development and compilation, guaranteeing that API payload contracts between the frontend and backend are respected.
- **Difference between `.ts` and `.tsx`**:
  - `.ts`: Standard TypeScript file containing pure logic, interfaces, functions, classes, and backend routes. It cannot contain JSX tags (like `<div>` or `<Welcome />`).
  - `.tsx`: TypeScript file enabled with JSX syntax parsing, used exclusively for React component definitions.
- **Operational Health Endpoints**: In modern Kubernetes architectures, orchestrators do not guess if an application is running. They query `/api/health` (liveness probe) to detect crashes and `/api/ready` (readiness probe) before sending client traffic to the pod.

### Step 3 – What are we going to create?
- Backend:
  - `backend/package.json`
  - `backend/tsconfig.json`
  - `backend/src/types/welcome.types.ts`
  - `backend/src/controllers/welcome.controller.ts`
  - `backend/src/routes/welcome.routes.ts`
  - `backend/src/middleware/error.middleware.ts`
  - `backend/src/app.ts`
  - `backend/src/server.ts`
  - `backend/tests/health.test.ts`
- Frontend:
  - `frontend/package.json`
  - `frontend/tsconfig.json`
  - `frontend/vite.config.ts`
  - `frontend/index.html`
  - `frontend/src/types/welcome.ts`
  - `frontend/src/services/api.ts`
  - `frontend/src/components/Welcome.tsx`
  - `frontend/src/App.tsx`
  - `frontend/src/main.tsx`
  - `frontend/src/index.css`

### Step 4 – Where do we create it?
In their respective directories:
`c:\devops\backend\` and `c:\devops\frontend\`

### Step 5 – Complete Code
*(Refer to the repository files in `c:\devops\backend\` and `c:\devops\frontend\` created in Milestone 1)*

Key architectural highlights:

#### Backend Type Contract (`backend/src/types/welcome.types.ts`)
```typescript
export interface WelcomeResponse {
  organization: string;
  division: string;
  heading: string;
  subtitle: string;
  welcomeMessage: string;
  description: string;
  environment: string;
  timestamp: string;
}

export interface HealthResponse {
  status: 'healthy' | 'unhealthy';
  service: string;
  uptimeSeconds: number;
  timestamp: string;
}

export interface ReadinessResponse {
  status: 'ready' | 'not_ready';
  service: string;
  checks: {
    server: boolean;
    timestamp: string;
  };
  timestamp: string;
}
```

#### Frontend Typed API Client (`frontend/src/services/api.ts`)
```typescript
import { WelcomeData } from '../types/welcome';

export async function fetchWelcomeData(): Promise<WelcomeData> {
  const response = await fetch('/api/welcome', {
    headers: { 'Accept': 'application/json' },
  });
  if (!response.ok) {
    throw new Error(`API Error: ${response.status} ${response.statusText}`);
  }
  return await response.json();
}
```

### Step 6 – Code Explanation
1. **Compilation & `tsconfig.json`**:
   - `"strict": true`: Activates `noImplicitAny`, `strictNullChecks`, and `strictFunctionTypes`.
   - `"outDir": "./dist"`: The TypeScript compiler (`tsc`) transpiles TypeScript into plain JavaScript files inside `dist/` for production runtime.
2. **Graceful Shutdown in `backend/src/server.ts`**:
   - Traps `SIGTERM` and `SIGINT` signals sent by the host OS or Kubernetes pod evictions.
   - Halts receiving new HTTP connections and flushes existing requests before exiting cleanly with status code `0`.
3. **Frontend Component Architecture in `frontend/src/components/Welcome.tsx`**:
   - Manages an async state (`loading`, `data`, `error`).
   - Displays clean status cards if the backend is unreachable, allowing students to test error resiliency.

### Step 7 – Execute
Open two PowerShell terminals:

#### Terminal 1: Install & Launch Backend
```powershell
Set-Location -Path "c:\devops\backend"
npm install
npm test
npm run build
npm run dev
```

#### Terminal 2: Install & Launch Frontend
```powershell
Set-Location -Path "c:\devops\frontend"
npm install
npm run build
npm run dev
```

### Step 8 – Expected Result

#### Backend Terminal:
```
====================================================
 CSEC Welcome Backend API Server
 Organization: CSEC ASTU - Development Division
 Status: Running
 Listening: http://0.0.0.0:5000
 Health:    http://0.0.0.0:5000/api/health
 Ready:     http://0.0.0.0:5000/api/ready
 Welcome:   http://0.0.0.0:5000/api/welcome
====================================================
```

#### Frontend Terminal:
```
  VITE v6.0.7  ready in 250 ms

  ➜  Local:   http://localhost:5173/
  ➜  Network: http://192.168.x.x:5173/
```

### Step 9 – Verify
In a third terminal or your browser, test each backend endpoint:
```powershell
# 1. Test Health endpoint
curl.exe http://localhost:5000/api/health

# 2. Test Readiness endpoint
curl.exe http://localhost:5000/api/ready

# 3. Test Welcome endpoint
curl.exe http://localhost:5000/api/welcome

# 4. Open browser at http://localhost:5173
```

Verify that the browser renders:
- **Heading**: CSEC ASTU
- **Subtitle**: Development Division
- **Welcome Message**: "Welcome to the CSEC ASTU Development Division. We learn, build and collaborate to develop software engineering skills and create meaningful technology solutions."
- Dynamic timestamp matching the backend response.

### Step 10 – Troubleshoot
- **Problem**: `EADDRINUSE: address already in use :::5000`
  - **Solution**: Another process is occupying port 5000. Identify and terminate it:
    ```powershell
    Get-Process -Id (Get-NetTCPConnection -LocalPort 5000).OwningProcess | Stop-Process -Force
    ```
- **Problem**: Frontend shows "Failed to fetch welcome information"
  - **Solution**: Confirm backend is running in Terminal 1 on port 5000. Verify the Vite proxy config in `frontend/vite.config.ts`.

### Step 11 – Practice
1. Add an extra field to `backend/src/types/welcome.types.ts` called `author: string`.
2. Notice how TypeScript immediately raises a compile error in `welcome.controller.ts` until you supply `author: 'CSEC ASTU'`.
3. Update `frontend/src/types/welcome.ts` and `frontend/src/components/Welcome.tsx` to display this new field.

### Step 12 – Cleanup
Stop both local servers by pressing `Ctrl + C` in both PowerShell windows.

### Step 13 – Production Connection
In cloud production, frontend static files are compiled once into optimized HTML/CSS/JS (`npm run build`) and served by high-performance Nginx web servers or CDNs. The backend runs inside minimal container images, scaling horizontally based on CPU/memory load and HTTP request volume.

