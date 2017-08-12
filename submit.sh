#!/bin/bash
#
#SBATCH --job-name=vertex
#SBATCH --output=vertex_log.txt
#
#SBATCH --ntasks=100
#SBATCH --time=4:00:00
#SBATCH --mem-per-cpu=2000

CONTAINER=/cluster/kappa/90-days-archive/wongjiradlab/larbys/images/dllee_unified/singularity-dllee-unified-080717.img
WORKDIR=/cluster/kappa/90-days-archive/wongjiradlab/grid_jobs/vertex-tuftscluster-scripts
INPUTLISTDIR=${WORKDIR}/inputlists
JOBIDLIST=${WORKDIR}/rerunlist.txt

#OUTPUTDIR=/cluster/kappa/90-days-archive/wongjiradlab/larbys/data/mcc8.1/numu_1muNpfiltered/out_week071017/vertex_cosmictags
#OUTPUTDIR=/cluster/kappa/90-days-archive/wongjiradlab/larbys/data/mcc8.1/nue_1eNpfiltered/out_week072517/vertex_ssnetmcc8_cosmictags
OUTPUTDIR=/cluster/kappa/90-days-archive/wongjiradlab/larbys/data/comparison_samples/1e1p/out_week080717/vertex_ssnetmcc8_cosmictags

mkdir -p ${OUTPUTDIR}
module load singularity
srun singularity exec ${CONTAINER} bash -c "cd ${WORKDIR} && source run_job.sh ${WORKDIR} ${INPUTLISTDIR} ${OUTPUTDIR} ${JOBIDLIST}"

# USE THE FOLLOWING COMMAND TO RUN A TEST INTERACTIVELY
# (but do this from an interactive slurm job)
# (to start such an interactive job, run: srun --pty -p interactive bash)
#singularity exec ${CONTAINER} bash -c "export SLURM_PROCID=1 && cd ${WORKDIR} && source run_job.sh ${WORKDIR} ${INPUTLISTDIR} ${OUTPUTDIR} ${JOBIDLIST}"
