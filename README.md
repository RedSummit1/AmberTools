# AmberTools Docker Environment

Molecular modeling and simulation environment with AmberTools, JupyterLab, and GPU support.

---

## Quick Start

### 1. Start the Environment
```bash
cd ~/Documents/Amber
docker compose up -d
```

### 2. Access JupyterLab
```bash
docker compose exec ambertools jupyter lab --ip=0.0.0.0 --port=8888 --no-browser --allow-root
```

Copy the token from the output and open in your browser:
- **Same computer**: `http://localhost:8888`
- **Remote computer**: `http://YOUR_IP:8888`

### 3. Stop the Environment
```bash
docker compose down
```

---

## What's Included

- ✅ **AmberTools 25** - Complete molecular modeling suite
- ✅ **JupyterLab** - Browser-based IDE with terminal
- ✅ **Python 3.12** with py3Dmol for 3D visualization
- ✅ **GPU Support** - NVIDIA CUDA enabled
- ✅ **Text Editors** - vim and nano

---

## Example Workflow: Ethane Molecule

Complete workflow from molecule creation to energy minimization.

### Method 1: Run the Test Script

In JupyterLab terminal:
```bash
cd /workspace
bash test_workflow.sh
```

This automatically creates, parameterizes, and minimizes an ethane molecule.

### Method 2: Step-by-Step (Learn the Process)

#### Step 1: Create the Molecule
```bash
cat > ethane.pdb << 'PDBEOF'
ATOM      1  C1  ETH     1      -0.762   0.013  -0.001  1.00  0.00           C
ATOM      2  C2  ETH     1       0.762  -0.013   0.001  1.00  0.00           C
ATOM      3  H1  ETH     1      -1.132   1.041  -0.001  1.00  0.00           H
ATOM      4  H2  ETH     1      -1.156  -0.488   0.895  1.00  0.00           H
ATOM      5  H3  ETH     1      -1.156  -0.512  -0.883  1.00  0.00           H
ATOM      6  H4  ETH     1       1.156   0.512   0.883  1.00  0.00           H
ATOM      7  H5  ETH     1       1.156   0.488  -0.895  1.00  0.00           H
ATOM      8  H6  ETH     1       1.132  -1.041   0.001  1.00  0.00           H
END
PDBEOF
```

#### Step 2: Parameterize with Antechamber
```bash
antechamber -i ethane.pdb -fi pdb -o ethane.mol2 -fo mol2 -c bcc -nc 0 -s 2
```

**Parameters explained:**
- `-i ethane.pdb` - Input file
- `-fi pdb` - Input format (PDB)
- `-o ethane.mol2` - Output file
- `-fo mol2` - Output format (MOL2 with charges)
- `-c bcc` - Charge method (AM1-BCC, good for organics)
- `-nc 0` - Net charge (neutral molecule)
- `-s 2` - Status information level

#### Step 3: Build System with tleap
```bash
cat > build_ethane.in << 'TLEAPEOF'
source leaprc.gaff2
ethane = loadmol2 ethane.mol2
check ethane
saveamberparm ethane ethane.prmtop ethane.inpcrd
savepdb ethane ethane_final.pdb
quit
TLEAPEOF

tleap -f build_ethane.in
```

**Creates:**
- `ethane.prmtop` - Topology file (atom types, bonds, parameters)
- `ethane.inpcrd` - Initial coordinates
- `ethane_final.pdb` - PDB for visualization

#### Step 4: Energy Minimization
```bash
cat > minimize.in << 'MINEOF'
Ethane minimization
 &cntrl
  imin=1,           ! Perform minimization
  maxcyc=200,       ! Maximum cycles
  ncyc=100,         ! Steepest descent cycles
  ntb=0,            ! No periodic boundary (gas phase)
  cut=999.0         ! Non-bonded cutoff
 /
MINEOF

sander -O -i minimize.in -o ethane_min.out -p ethane.prmtop -c ethane.inpcrd -r ethane_min.rst7
```

#### Step 5: Check Results
```bash
grep "FINAL" ethane_min.out
```

---

## Visualization in JupyterLab

Create a new Python 3 notebook and run:

### Basic Visualization
```python
import py3Dmol

# Load and visualize the molecule
view = py3Dmol.view(width=800, height=600)
view.addModel(open('ethane_final.pdb').read(), 'pdb')
view.setStyle({'stick': {'radius': 0.2}, 'sphere': {'radius': 0.4}})
view.setBackgroundColor('white')
view.zoomTo()
view.show()
```

### Show Atomic Charges
```python
# Read and display charges from MOL2 file
print("Atomic Charges in Ethane:\n")
print(f"{'Atom':<8} {'Type':<8} {'Charge':>10}")
print("-" * 30)

with open('ethane.mol2', 'r') as f:
    in_atoms = False
    total_charge = 0
    
    for line in f:
        if '@<TRIPOS>ATOM' in line:
            in_atoms = True
            continue
        if '@<TRIPOS>BOND' in line:
            break
        if in_atoms and line.strip():
            parts = line.split()
            if len(parts) >= 9:
                atom_name = parts[1]
                atom_type = parts[5]
                charge = float(parts[8])
                total_charge += charge
                print(f"{atom_name:<8} {atom_type:<8} {charge:>10.4f}")

print("-" * 30)
print(f"{'Total':<17} {total_charge:>10.4f}")
```

### Plot Minimization Progress
```python
import matplotlib.pyplot as plt

# Extract energies from minimization output
steps = []
energies = []

with open('ethane_min.out', 'r') as f:
    for line in f:
        if line.strip().startswith(tuple('0123456789')):
            parts = line.split()
            if len(parts) >= 2:
                try:
                    steps.append(int(parts[0]))
                    energies.append(float(parts[1]))
                except:
                    pass

# Plot
plt.figure(figsize=(10, 6))
plt.plot(steps, energies, 'b-', linewidth=2)
plt.xlabel('Step')
plt.ylabel('Energy (kcal/mol)')
plt.title('Energy Minimization Progress')
plt.grid(True, alpha=0.3)
plt.tight_layout()
plt.show()

print(f"Initial energy: {energies[0]:.2f} kcal/mol")
print(f"Final energy: {energies[-1]:.2f} kcal/mol")
print(f"Energy change: {energies[-1] - energies[0]:.2f} kcal/mol")
```

### Rotating 3D View
```python
import py3Dmol

view = py3Dmol.view(width=800, height=600)
view.addModel(open('ethane_final.pdb').read(), 'pdb')
view.setStyle({'stick': {'radius': 0.2}, 'sphere': {'radius': 0.4}})
view.zoomTo()
view.spin(True)  # Auto-rotate!
view.show()
```

---

## Main AmberTools Programs

| Program | Purpose | Example |
|---------|---------|---------|
| **antechamber** | Parameterize small molecules | `antechamber -i mol.pdb -fi pdb -o mol.mol2 -fo mol2 -c bcc` |
| **tleap** | Build molecular systems | `tleap -f script.in` |
| **sander** | Run MD simulations (CPU) | `sander -i md.in -o md.out -p sys.prmtop -c sys.inpcrd` |
| **cpptraj** | Analyze trajectories | `cpptraj -p sys.prmtop -i analysis.in` |
| **parmed** | Edit topology files | `parmed sys.prmtop` |

---

## File Locations

All your work is synchronized between host and container:

- **Host machine**: `~/Documents/Amber/data/`
- **Inside container**: `/workspace/`

Files created in either location appear in both.

---

## JupyterLab Features

### Terminal Access
- Click **Terminal** icon in launcher, or
- **File** → **New** → **Terminal**
- Full bash shell with AmberTools pre-activated

### File Browser
- Left sidebar shows all files
- Drag and drop to upload
- Right-click for options

### Text Editor
- Built-in editor for scripts
- Syntax highlighting
- Multiple tabs

### Notebooks
- Interactive Python with 3D visualization
- Markdown for documentation
- Code + results in one place

---

## GPU Support

Your NVIDIA GPU is available in the container:
```bash
nvidia-smi
```

Use GPU-accelerated programs when available (requires full Amber license for pmemd.cuda).

---

## Useful Host Machine Aliases

Add these to `~/.bashrc` on your host machine for easier access:
```bash
# Add to ~/.bashrc
alias amber-up='cd ~/Documents/Amber && docker compose up -d'
alias amber-down='cd ~/Documents/Amber && docker compose down'
alias amber-enter='cd ~/Documents/Amber && docker compose exec ambertools bash'
alias jupyter-start='cd ~/Documents/Amber && docker compose exec -d ambertools jupyter lab --ip=0.0.0.0 --port=8888 --no-browser --allow-root'
alias jupyter-token='docker logs ambertools 2>&1 | grep token | tail -1'
```

Then use:
```bash
amber-up          # Start container
jupyter-start     # Start JupyterLab
jupyter-token     # Get access token
amber-enter       # Terminal access
amber-down        # Stop everything
```

---

## Common Workflows

### Small Molecule Parameterization
```bash
# 1. Get or create PDB file
# 2. Run antechamber
antechamber -i molecule.pdb -fi pdb -o molecule.mol2 -fo mol2 -c bcc -nc 0

# 3. Generate additional parameters if needed
parmchk2 -i molecule.mol2 -f mol2 -o molecule.frcmod

# 4. Build system with tleap
tleap -f build_script.in
```

### Protein-Ligand System
```bash
# 1. Prepare protein (remove waters, add hydrogens)
# 2. Parameterize ligand with antechamber
# 3. Combine in tleap
# 4. Add solvent box and ions
# 5. Minimize, heat, equilibrate, production MD
```

### Trajectory Analysis
```bash
# Use cpptraj for analysis
cpptraj -p system.prmtop << EOF
trajin trajectory.nc
rms first @CA
distance :1@CA :100@CA
run
EOF
```

---

## Troubleshooting

### Can't Connect to JupyterLab from Remote Computer

On the host machine:
```bash
# Allow port through firewall
sudo ufw allow 8888

# Or use iptables
sudo iptables -A INPUT -p tcp --dport 8888 -j ACCEPT
```

### Need to Rebuild Container
```bash
cd ~/Documents/Amber
docker compose down
docker compose build --no-cache
docker compose up -d
```

### Container Won't Start
```bash
# Check logs
docker compose logs

# Check if port is in use
sudo netstat -tulpn | grep 8888
```

### AmberTools Commands Not Found

Make sure you're in the container and the environment is activated:
```bash
# Check environment
echo $AMBERHOME
conda env list

# If needed, activate manually
conda activate AmberTools25
source $CONDA_PREFIX/amber.sh
```

### Clear All Generated Files
```bash
cd /workspace

# Keep only your input files and scripts
rm -f ANTECHAMBER_* ATOMTYPE.INF sqm.* leap.log mdinfo
```

---

## Learning Resources

### Inside the Container
```bash
# AmberTools manual
ls $AMBERHOME/doc/

# Example files
ls $AMBERHOME/AmberTools/examples/

# Tutorials
ls $AMBERHOME/AmberTools/examples/tutorial/
```

### Online Resources

- **Official Amber site**: http://ambermd.org
- **AmberTools manual**: http://ambermd.org/doc12/Amber25.pdf
- **Tutorials**: http://ambermd.org/tutorials/
- **Mailing list**: http://archive.ambermd.org/

---

## System Information

- **Base OS**: Ubuntu 22.04
- **Python**: 3.12
- **AmberTools**: Version 25
- **Force Fields**: GAFF, GAFF2, ff14SB, and more
- **Container Runtime**: Docker with NVIDIA GPU support

---

## File Structure
```
~/Documents/Amber/
├── Dockerfile              # Container definition
├── docker-compose.yml      # Service configuration
├── README.md              # This file
└── data/                  # Your workspace
    ├── test_workflow.sh   # Example script
    └── (your files here)
```

---

## Tips

1. **Use the test script first** to verify everything works
2. **Keep your work in `/workspace`** - it persists between container restarts
3. **Use JupyterLab notebooks** for interactive work and documentation
4. **Use the terminal** for batch processing and running AmberTools commands
5. **Visualize in notebooks** with py3Dmol for immediate feedback
6. **Check the manual** at `$AMBERHOME/doc/` for detailed documentation

---

## License

AmberTools is free and open source software. See http://ambermd.org for license details.

---

## Getting Help

1. Check the **AmberTools manual**: `$AMBERHOME/doc/Amber25.pdf`
2. Search the **mailing list archives**: http://archive.ambermd.org/
3. Ask on the **Amber mailing list**: http://ambermd.org/MailingLists.php
4. Check **online tutorials**: http://ambermd.org/tutorials/

---

**Ready to get started?** Run `bash test_workflow.sh` to see AmberTools in action!
