#!/bin/bash

cd /workspace
git clone https://github.com/RedSummit1/AmberTools.git
cd AmberTools/data
source /opt/miniforge/etc/profile.d/conda.sh
conda activate AmberTools25

# Run the test workflow
echo "Running test workflow..."
bash test_workflow.sh

## Start JupyterLab
#cd /workspace/AmberTools
#jupyter lab --ip=0.0.0.0 --port=8888 --no-browser --allow-root --NotebookApp.token='' --NotebookApp.password=$(python3 -c "from jupyter_server.auth import passwd; print(passwd('YOUR_PASSWORD'))")
