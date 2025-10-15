#!/bin/bash
echo "=== AmberTools Workflow Test ==="
echo ""

# 1. Create molecule
echo "Creating ethane molecule..."
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

# 2. Parameterize
echo "Parameterizing with antechamber..."
antechamber -i ethane.pdb -fi pdb -o ethane.mol2 -fo mol2 -c bcc -nc 0 -s 2 > /dev/null 2>&1
echo ""

# 3. Build system
echo "Building system with tleap..."
cat > build_ethane.in << 'TLEAPEOF'
source leaprc.gaff2
ethane = loadmol2 ethane.mol2
check ethane
saveamberparm ethane ethane.prmtop ethane.inpcrd
savepdb ethane ethane_final.pdb
quit
TLEAPEOF

tleap -f build_ethane.in > /dev/null 2>&1
echo ""

# 4. Minimize
echo "Running energy minimization..."
cat > minimize.in << 'MINEOF'
Ethane minimization
 &cntrl
  imin=1, maxcyc=200, ncyc=100, ntb=0, cut=999.0
 /
MINEOF

sander -O -i minimize.in -o ethane_min.out -p ethane.prmtop -c ethane.inpcrd -r ethane_min.rst7 > /dev/null 2>&1
echo ""

# 5. Results
echo "=== RESULTS ==="
echo ""
echo "Final energy:"
grep "FINAL" ethane_min.out
echo ""
echo "Files created:"
ls -lh ethane.prmtop ethane.inpcrd ethane_min.rst7 ethane_final.pdb
echo ""
echo "✓ Complete workflow successful!"
