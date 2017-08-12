#!/bin/bash

VERTEXANAFILE=$1

#CONTAINER=/cluster/kappa/90-days-archive/wongjiradlab/larbys/images/dllee_unified/singularity-dllee-unified-071017.img
#WORKDIR=/cluster/kappa/90-days-archive/wongjiradlab/grid_jobs/vertex-tuftscluster-scripts

CONTAINER=/home/taritree/larbys/images/dllee_unified/singularity-dllee-unified-071017.img
WORKDIR=/home/taritree/dllee_integration/vertex-tuftscluster-scripts

module load singularity

echo $VERTEXANAFILE
singularity exec ${CONTAINER} bash -c "source /usr/local/bin/thisroot.sh && cd /usr/local/share/dllee_unified && source configure.sh && cd ${WORKDIR} && python eff_cuts.py ${VERTEXANAFILE}"

