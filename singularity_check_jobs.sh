#!/bin/bash

CONTAINER=/cluster/kappa/90-days-archive/wongjiradlab/larbys/images/dllee_unified/singularity-dllee-unified-071017.img
WORKDIR=/cluster/kappa/90-days-archive/wongjiradlab/grid_jobs/vertex-tuftscluster-scripts

module load singularity

singularity exec ${CONTAINER} bash -c "source /usr/local/bin/thisroot.sh && cd ${WORKDIR} && python check_jobs.py"

