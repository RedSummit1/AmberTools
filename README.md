# AmberTools Docker Environment

Molecular modeling with AmberTools 25, JupyterLab, and GPU support.

---

## Quick Commands
```bash
# Build and start (attached)
docker compose up

# Stop (Ctrl+C, then)
docker compose down
```

---

## Access JupyterLab

After starting, you'll see the access URL and password in the terminal output.

Open the URL in your browser (local or remote).

---

## Example Workflow

See `test_workflow.sh` in the `/workspace` directory for a complete ethane molecule example.

Run it in JupyterLab terminal:
```bash
cd /workspace
bash test_workflow.sh
```

---

## What's Included

- AmberTools 25
- JupyterLab with py3Dmol
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

**Get started**: `docker compose up`
