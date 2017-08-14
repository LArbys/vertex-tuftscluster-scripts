#!/bin/bash

let numjobs=$1
echo "Spawning ${numjobs} jobs"

SINGULARITY_IMG=/mnt/raid0/taritree/containers/singularity-dllee-unified/singularity-dllee-unified-081017.img
WORKDIR=/home/taritree/dllee_integration/vertex-tuftscluster-scripts
INPUTLISTS=${WORKDIR}/inputlists
JOBIDLIST=${WORKDIR}/rerunlist.txt

#OUTDIR=/mnt/sdb/larbys/data/comparison_samples/inclusive_elec/out_week080717/vertex_ssnetmcc8_cosmictags
OUTDIR=/home/taritree/dllee_integration/vertex-tuftscluster-scripts/test

mkdir -p $OUTDIR

rm -f log_nudot_job.txt
for (( i=0; i<$numjobs; i++ ))
do
    #SLURM_PROCID=$i ./mccaffe_test.sh &
    #echo "launching job=$i" && singularity exec -B /mnt/raid0:/mnt/raid0 $SINGULARITY_IMG bash -c "export SLURM_PROCID=$i && cd ${WORKDIR} && source run_job.sh ${WORKDIR} ${INPUTLISTS} ${OUTDIR} ${JOBIDLIST}" >> log_mccaffery_job.txt 2>&1 &
    export SLURM_PROCID=$i && cd ${WORKDIR} && source run_job.sh ${WORKDIR} ${INPUTLISTS} ${OUTDIR} ${JOBIDLIST} >> log_nudot_job.txt 2>&1 &
    
done
