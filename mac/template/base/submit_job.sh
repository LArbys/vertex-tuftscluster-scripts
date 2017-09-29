#!/bin/bash
#
#SBATCH --job-name=ZZZ_vertex_XXX
#SBATCH --output=log/ZZZ_vertex_log_XXX.txt
#
#SBATCH --ntasks=YYY
#SBATCH --time=4:00:00
#SBATCH --mem-per-cpu=2000

CONTAINER=AAA/image/BBB
WORKDIR=AAA/XXX/work
INPUTLISTDIR=${WORKDIR}/inputlists
JOBIDLIST=${WORKDIR}/rerunlist.txt

OUTPUTDIR=AAA/XXX/out

mkdir -p ${OUTPUTDIR}
module load singularity
srun singularity exec ${CONTAINER} bash -c "cd ${WORKDIR} && source run_ZZZ_job.sh ${WORKDIR} ${INPUTLISTDIR} ${OUTPUTDIR} ${JOBIDLIST}"
