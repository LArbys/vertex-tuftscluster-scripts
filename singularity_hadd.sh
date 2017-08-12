#!/bin/bash

CONTAINER=/cluster/kappa/90-days-archive/wongjiradlab/larbys/images/dllee_unified/singularity-dllee-unified-072517.img

OUTPUTDIR=/cluster/kappa/90-days-archive/wongjiradlab/larbys/data/mcc8.1/nue_1eNpfiltered/out_week072517/vertex_ssnetmcc8_cosmictags
MERGEDFILE=/cluster/kappa/90-days-archive/wongjiradlab/larbys/data/mcc8.1/nue_1eNpfiltered/out_week072517/vertexana_nue_ssnetmcc8_merged_cosmictags.root

#OUTPUTDIR=/cluster/kappa/90-days-archive/wongjiradlab/larbys/data/mcc8.1/numu_1muNpfiltered/out_week071017/vertex_cosmictags
#MERGEDFILE=/cluster/kappa/90-days-archive/wongjiradlab/larbys/data/mcc8.1/numu_1muNpfiltered/out_week071017/vertexana_merged_cosmictags.root

module load singularity
singularity exec ${CONTAINER} bash -c "source /usr/local/bin/thisroot.sh && hadd -f ${MERGEDFILE} ${OUTPUTDIR}/*vertexana*.root"

