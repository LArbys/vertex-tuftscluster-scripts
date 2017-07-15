#!/bin/bash
#
#SBATCH --job-name=vertex
#SBATCH --output=vertex_log.txt
#
#SBATCH --ntasks=10
#SBATCH --time=2:00:00
#SBATCH --mem-per-cpu=4000

CONTAINER=/cluster/kappa/90-days-archive/wongjiradlab/larbys/images/dllee_unified/singularity-dllee-unified-071017.img
WORKDIR=/cluster/kappa/90-days-archive/wongjiradlab/grid_jobs/vertex-tuftscluster-scripts
INPUTLISTDIR=${WORKDIR}/inputlists
JOBIDLIST=${WORKDIR}/rerunlist.txt

OUTPUTDIR=/cluster/kappa/90-days-archive/wongjiradlab/larbys/data/mcc8.1/numu_1muNpfiltered/out_week071017/vertex
#OUTPUTDIR=/cluster/kappa/90-days-archive/wongjiradlab/larbys/data/mcc8.1/nue_1eNpfiltered/out_week071017/vertex

mkdir -p ${OUTPUTDIR}
module load singularity
srun singularity exec ${CONTAINER} bash -c "cd ${WORKDIR} && source run_job.sh ${WORKDIR} ${INPUTLISTDIR} ${OUTPUTDIR} ${JOBIDLIST}"

# USE THE FOLLOWING COMMAND TO RUN A TEST INTERACTIVELY
# (but do this from an interactive slurm job)
# (to start such an interactive job, run: srun --pty -p interactive bash)
#singularity exec ${CONTAINER} bash -c "export SLURM_PROCID=0 && cd ${WORKDIR} && source run_job.sh ${WORKDIR} ${INPUTLISTDIR} ${OUTPUTDIR} ${JOBIDLIST}"
