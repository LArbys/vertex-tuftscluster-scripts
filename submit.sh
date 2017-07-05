#!/bin/bash
#
#SBATCH --job-name=vertex
#SBATCH --output=vertex_log.txt
#
#SBATCH --ntasks=3
#SBATCH --time=24:00:00
#SBATCH --mem-per-cpu=4000

module load singularity

srun singularity exec /cluster/kappa/90-days-archive/wongjiradlab/larbys/images/dllee_unified/singularity-dllee-unified-062517.img bash -c "cd /cluster/home/twongj01/grid_jobs/vertex-tuftscluster-scripts && source run_job.sh /cluster/home/twongj01/grid_jobs/vertex-tuftscluster-scripts /cluster/home/twongj01/grid_jobs/vertex-tuftscluster-scripts/inputlists /cluster/kappa/90-days-archive/wongjiradlab/larbys/data/mcc8.1/nue_1eNpfiltered/out_week0626/vertex /cluster/home/twongj01/grid_jobs/vertex-tuftscluster-scripts/rerunlist.txt"
