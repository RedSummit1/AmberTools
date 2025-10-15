#!/bin/bash

cd /workspace
git clone https://github.com/RedSummit1/AmberTools.git
cd AmberTools/data
source /opt/miniforge/etc/profile.d/conda.sh
conda activate AmberTools25

# Run the test workflow
echo "Running test workflow..."
bash test_workflow.sh
