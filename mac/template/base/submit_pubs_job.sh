#!/bin/bash
#
#SBATCH --job-name=AAA
#SBATCH --output=BBB
#
#SBATCH --ntasks=CCC
#SBATCH --time=4:00:00
#SBATCH --mem-per-cpu=2000

CONTAINER=DDD
WORKDIR=EEE
INPUTLISTDIR=${WORKDIR}/inputlists
JOBIDLIST=${WORKDIR}/rerunlist.txt

OUTPUTDIR=FFF

mkdir -p ${OUTPUTDIR}
module load singularity
srun singularity exec ${CONTAINER} bash -c "cd ${WORKDIR} && source GGG ${WORKDIR} ${INPUTLISTDIR} ${OUTPUTDIR} ${JOBIDLIST}"
