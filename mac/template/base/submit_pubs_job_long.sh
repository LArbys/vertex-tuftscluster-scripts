#!/bin/bash
#
#SBATCH --job-name=AAA
#SBATCH --output=BBB
#
#SBATCH --ntasks=CCC
#SBATCH --time=12:00:00
#SBATCH --mem-per-cpu=4000
#SBATCH --exclude=pcomp26

CONTAINER=DDD
WORKDIR=EEE
INPUTLISTDIR=${WORKDIR}/inputlists
JOBIDLIST=${WORKDIR}/rerunlist.txt

OUTPUTDIR1=FFF
OUTPUTDIR2=HHH

mkdir -p ${OUTPUTDIR1}

module load singularity
srun singularity exec ${CONTAINER} bash -c "cd ${WORKDIR} && printenv | grep SLURM_JOBID > job.id && source GGG ${WORKDIR} ${INPUTLISTDIR} ${OUTPUTDIR2} ${JOBIDLIST} 1>/dev/null 2>/dev/null"
