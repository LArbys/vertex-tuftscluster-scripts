#!/bin/bash
#
#SBATCH --job-name=ZZZ_CCC
#SBATCH --output=AAA/mac/log/ZZZ_log_CCC.txt
#
#SBATCH --ntasks=YYY
#SBATCH --time=00:30:00
#SBATCH --mem-per-cpu=2000

CONTAINER=AAA/image/BBB
WORKDIR=XXX/work
INPUTLISTDIR=${WORKDIR}/inputlists
JOBIDLIST=${WORKDIR}/rerunlist.txt

OUTPUTDIR=XXX/out

mkdir -p ${OUTPUTDIR}
module load singularity
srun -p interactive singularity exec ${CONTAINER} bash -c "cd ${WORKDIR} && source run_ZZZ_job.sh ${WORKDIR} ${INPUTLISTDIR} ${OUTPUTDIR} ${JOBIDLIST}"
