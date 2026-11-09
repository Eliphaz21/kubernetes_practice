# Module 02: Development Environment Installation

## Organization: CSEC ASTU – Development Division
### Project: CSEC Welcome – Cloud-Native Kubernetes & DevOps Training Curriculum

---

### Step 1 – What are we learning?
In this module, you will set up a complete, professional, cross-platform local development environment. You will install and configure **Node.js**, **npm**, **Git**, and **Visual Studio Code**, ensuring your machine has the necessary CLI tools and runtime dependencies for modern full-stack TypeScript development.

### Step 2 – Why do we need it?
Enterprise software development requires repeatable, deterministic developer environments:
- **Node.js**: The JavaScript/TypeScript server runtime executing our backend API and build tooling.
- **npm**: The package manager orchestrating open-source libraries and scripts.
- **Git**: Distributed version control system tracking every architectural change.
- **VS Code**: Professional editor with language server protocol support for TypeScript auto-completion and syntax error detection.

### Step 3 – What are we going to create?
A verified local development workstation running on Windows 11 PowerShell (with macOS and Linux support noted).

### Step 4 – Where do we create it?
Documented at `c:\devops\docs\02-development-environment-installation.md`.

### Step 5 – Complete Installation Commands

#### Primary: Windows 11 (PowerShell Administrator)
```powershell
# 1. Install Node.js LTS (includes npm)
winget install --id OpenJS.NodeJS.LTS -e --source winget

# 2. Install Git for Windows
winget install --id Git.Git -e --source winget

# 3. Install Visual Studio Code
winget install --id Microsoft.VisualStudioCode -e --source winget
```

#### Alternative: macOS (Homebrew)
```bash
brew install node git --cask visual-studio-code
```

#### Alternative: Linux (Ubuntu / Debian)
```bash
sudo apt update
sudo apt install -y curl git
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install -y nodejs
```

### Step 6 – Code / Configuration Explanation
- `winget`: Windows Package Manager CLI ensuring clean PATH registration and uninstaller hooks.
- Node.js LTS (Long Term Support): Guaranteed stability and enterprise security patches for production parity.
- Recommended VS Code Extensions:
  - `dbaeumer.vscode-eslint`: Real-time linting.
  - `ms-vscode.vscode-typescript-next`: Modern TypeScript support.
  - `ms-azuretools.vscode-docker`: Syntax highlighting for Dockerfile and docker-compose.
  - `ms-kubernetes-tools.vscode-kubernetes-tools`: Kubernetes manifest validation.

### Step 7 – Execute
Restart your PowerShell terminal to reload your PATH environment variables, then run:
```powershell
node --version
npm --version
git --version
```

### Step 8 – Expected Result
```
v20.x.x (or newer, e.g. v24.x.x)
10.x.x (or newer)
git version 2.x.x.windows.1
```

### Step 9 – Verify
Run a quick Node evaluation test in PowerShell:
```powershell
node -e "console.log('Node.js runtime active for CSEC ASTU Training!')"
```
*Expected output*: `Node.js runtime active for CSEC ASTU Training!`

### Step 10 – Troubleshoot
- **Problem**: `Execution of scripts is disabled on this system` (PowerShell ExecutionPolicy error).
  - **Fix**: Open PowerShell as Administrator and run:
    ```powershell
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
    ```
- **Problem**: `node is not recognized as an internal or external command`.
  - **Fix**: Your system PATH was not updated. Close all terminal instances and reopen, or manually check `sysdm.cpl` -> Environment Variables.

### Step 11 – Practice
Configure your global Git identity:
```powershell
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
git config --list
```

### Step 12 – Cleanup
No temporary resources need cleanup.

### Step 13 – Production Connection
In cloud CI/CD pipelines (e.g., GitHub Actions runners, AWS CodeBuild), these exact tools run inside ephemeral Linux containers to execute unit test suites and compile TypeScript before container packaging.

