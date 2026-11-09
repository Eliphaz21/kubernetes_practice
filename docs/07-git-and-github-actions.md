# Module 07: Git Workflow & GitHub Actions CI/CD

## Organization: CSEC ASTU – Development Division
### Project: CSEC Welcome – Cloud-Native Kubernetes & DevOps Training Curriculum

---

### Step 1 – What are we learning?
In this module, you are learning **Continuous Integration & Continuous Delivery (CI/CD)** using **Git** and **GitHub Actions**. You will understand how automated pipelines test TypeScript code, build multi-stage Docker images, scan them for security vulnerabilities with **Trivy**, and publish immutable container packages to the **GitHub Container Registry (GHCR)**.

### Step 2 – Why do we need it?
In enterprise software development:
1. **Human Error Prevention**: Manual testing and building on developer laptops is error-prone. CI automatically verifies every git push and pull request before code reaches `main`.
2. **Immutable Artifacts**: Production deployments must reference exact, traceable artifacts tagged with the git commit SHA (`sha-abc1234`), rather than mutable tags like `latest`.
3. **Automated Security Scanning**: Containers often contain vulnerable system packages. Automated scanning with tools like Trivy flags CVEs before deployment.
4. **CI vs. CD**:
   - **Continuous Integration (CI)**: Automatically checks out, lints, tests, and builds code.
   - **Continuous Delivery (CD)**: Automatically packages and releases the artifact (e.g. to GHCR or staging), ready for deployment.
   - **Continuous Deployment**: Automatically deploys the tested artifact directly to production clusters (e.g. Kubernetes via GitOps).

### Step 3 – What are we going to create?
- `.github/workflows/ci.yaml`: Automated test, lint, and build pipeline for Frontend, Backend, and future Kubernetes manifests.
- `.github/workflows/build-and-push.yaml`: Production Docker buildx, Trivy vulnerability scan, and GHCR registry publishing pipeline.

### Step 4 – Where do we create it?
In the root directory under:
- `c:\devops\.github\workflows\ci.yaml`
- `c:\devops\.github\workflows\build-and-push.yaml`

### Step 5 – Complete Code
*(Refer to `.github/workflows/ci.yaml` and `.github/workflows/build-and-push.yaml`)*

Key Pipeline Architecture:
```
Git Push / PR to main
        │
        ├──► Job 1: Backend CI (npm test, lint, tsc build)
        ├──► Job 2: Frontend CI (npm lint, vite build)
        └──► Job 3: Kubernetes Manifest Validation (kubeconform)
                 │ (On main branch merge)
                 ▼
        Job 4: Docker Buildx -> Trivy Security Scan -> GHCR Push
               • ghcr.io/<org>/backend:sha-<commit>
               • ghcr.io/<org>/frontend:sha-<commit>
```

### Step 6 – Code Explanation
1. `permissions: contents: read`: Principle of Least Privilege. By default, workflows only have read access to source code. Only the release job is granted `packages: write` to publish to GHCR.
2. `secrets.GITHUB_TOKEN`: Built-in GitHub token automatically managed by the runner. No manual API keys or credentials needed.
3. `docker/setup-buildx-action`: Enables multi-platform container builds and GitHub Actions layer caching (`cache-from: type=gha`), reducing build times from minutes to seconds.
4. `aquasecurity/trivy-action`: Scans the resulting image filesystem for OS package and Node.js dependency vulnerabilities against the National Vulnerability Database (NVD).
5. **Image Tagging Strategy**:
   - We tag images with `sha-${{ github.sha }}` (immutable).
   - In Kubernetes, you should **never** deploy solely with `:latest` because `latest` does not change its name when code updates, preventing Kubernetes from triggering rolling updates.

### Step 7 – Execute
Push your committed repository to your GitHub account:
```powershell
# 1. Add your GitHub remote (replace with your personal GitHub repo URL)
git remote add origin https://github.com/YOUR_USERNAME/csec-kubernetes-learning.git

# 2. Push main branch
git branch -M main
git push -u origin main
```

### Step 8 – Expected Result
1. Open your repository on **GitHub.com** and click the **Actions** tab.
2. You will see both workflows running:
   - `CI - Code Quality & Tests` (All green checkmarks for Backend, Frontend, and K8s).
   - `Release - Docker Build, Security Scan & Publish`.
3. In the right sidebar under **Packages**, your two published container images appear:
   - `backend`
   - `frontend`

### Step 9 – Verify
Verify you can inspect or pull your published image from GHCR:
```powershell
# Test pulling your public container image
docker pull ghcr.io/YOUR_USERNAME/csec-kubernetes-learning/backend:latest
```

> 💡 **Local Minikube Note**: Hosted GitHub Actions runners cannot directly talk to your local laptop or Minikube cluster. In the next milestone, you will learn how to load images into Minikube locally using `minikube image load` or pull them from GHCR using Kubernetes secrets.

### Step 10 – Troubleshoot
- **Problem**: GHCR publish fails with `403 Forbidden`
  - **Solution**: In your GitHub repository:
    1. Go to **Settings** -> **Actions** -> **General**.
    2. Scroll to **Workflow permissions**.
    3. Select **Read and write permissions** and save.
- **Problem**: Trivy scan fails with rate limit errors
  - **Solution**: Trivy is configured with `exit-code: '0'` for learning mode, ensuring builds do not halt while students inspect CVE reports.

### Step 11 – Practice
1. Create a new git branch:
   ```powershell
   git checkout -b feature/test-ci
   ```
2. Introduce a deliberate syntax or test failure in `backend/src/controllers/welcome.controller.ts`.
3. Commit and push the branch, then open a Pull Request on GitHub.
4. Observe how GitHub Actions blocks the PR from merging because the automated tests caught the error!

### Step 12 – Cleanup
Switch back to your `main` branch and delete the test branch:
```powershell
git checkout main
git branch -D feature/test-ci
```

### Step 13 – Production Connection
In cloud-native production (AWS, Azure, GCP), CI/CD pipelines automate everything from unit testing and CVE scanning to triggering GitOps controllers (such as Argo CD or Flux) to safely roll out changes across multi-region Kubernetes clusters.
