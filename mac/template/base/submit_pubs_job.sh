#!/bin/bash
#
#SBATCH --job-name=AAA
#SBATCH --output=BBB
#
#SBATCH --ntasks=CCC
#SBATCH --time=00:45:00
#SBATCH --mem-per-cpu=2000

CONTAINER=DDD
WORKDIR=EEE
INPUTLISTDIR=${WORKDIR}/inputlists
JOBIDLIST=${WORKDIR}/rerunlist.txt

OUTPUTDIR=FFF

mkdir -p ${OUTPUTDIR}
module load singularity
srun singularity exec ${CONTAINER} bash -c "cd ${WORKDIR} && printenv | grep SLURM_JOBID > job.id && source GGG ${WORKDIR} ${INPUTLISTDIR} ${OUTPUTDIR} ${JOBIDLIST} 1>/dev/null 2>/dev/null"
