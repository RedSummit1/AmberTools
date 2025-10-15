# AmberTools Docker Environment

Molecular modeling with AmberTools 25, JupyterLab, and GPU support.

---

## Deployment on Vast.ai

### 1. Create Custom Template

**Go to Vast.ai → Templates → Create New Template**

**Docker Image:**
```
ghcr.io/redsummit1/ambertools:latest
```

**On-start Script:**
```bash
#!/bin/bash
cd /workspace
git clone https://github.com/RedSummit1/AmberTools.git
cd AmberTools/data
source /opt/miniforge/etc/profile.d/conda.sh
conda activate AmberTools25

# Run the test workflow
echo "Running test workflow..."
bash test_workflow.sh

# Start JupyterLab
cd /workspace/AmberTools
jupyter lab --ip=0.0.0.0 --port=8888 --no-browser --allow-root --NotebookApp.token='' --NotebookApp.password=$(python3 -c "from jupyter_server.auth import passwd; print(passwd('YOUR_PASSWORD'))")
```

**Expose Ports:**
```
8888
```

### 2. Select GPU Instance

When searching for instances:
- Choose GPU: **NVIDIA RTX 3000 series or higher** (RTX 3090, RTX 4090, A100, etc.)
- Ensure instance has GPU enabled

### 3. Access JupyterLab

Once your instance is running:
- Click the **"JupyterLab"** button in your Vast.ai instance dashboard
- Enter your password from the on-start script
- Start working!

---

## Local Development

### Quick Commands
```bash
# Build and start (attached)
docker compose up

# Stop (Ctrl+C, then)
docker compose down
```

### Access JupyterLab Locally

After starting, you'll see the access URL and password in the terminal output.

Open the URL in your browser.

---

## Example Workflow

The `test_workflow.sh` script runs automatically on Vast.ai startup and demonstrates:
- Creating an ethane molecule
- Parameterization with Antechamber
- System building with tleap
- Energy minimization with sander

Results appear in `/workspace/AmberTools/data/`

---

## What's Included

- AmberTools 25
- JupyterLab with AmberTools25 kernel (default)
- py3Dmol for 3D visualization
- Python 3.12
- NVIDIA GPU support

---

## File Locations

- **Host**: `./data/`
- **Container**: `/workspace/`

Files sync automatically between both locations.

---

## Resources

- Manual: `$AMBERHOME/doc/Amber25.pdf` (inside container)
- Tutorials: http://ambermd.org/tutorials/
- Examples: `$AMBERHOME/AmberTools/examples/`

---

**Get started on Vast.ai**: Create template → Select GPU → Launch → Click JupyterLab button
