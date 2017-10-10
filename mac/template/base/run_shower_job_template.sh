#!/bin/sh

# REMEMBER, WE ARE IN THE CONTAINER RIGHT NOW
# This means we access the next work drives through some mounted folders
# The submit command also moved us to right local folder

# expect to be in cloned repo of vertex-tuftcluster-scripts
# example, for taritree this is in: ~/grid_jobs/vertex-tuftcluster-scripts


# Get arguments
jobdir=$1
inputlist_dir=$2
output_dir=$3
jobid_list=$4

# setup the container software
# ----------------------------

# ROOT6
source /usr/local/bin/thisroot.sh

# SSNet Example Software
cd /usr/local/share/dllee_unified
echo $PWD
source ./configure.sh

# go to job dir
# -------------
cd $jobdir

echo "CURRENT DIR: "$PWD

# check that the process number is greater than the number of job ids
let NUM_PROCS=`cat ${jobid_list} | wc -l`
echo "number of processes: $NUM_PROCS"
if [ "$NUM_PROCS" -lt "${SLURM_PROCID}" ]; then
    echo "No Procces ID to run."
    return
fi

# get job id
let "proc_line=${SLURM_PROCID}+1"
let jobid=`sed -n ${proc_line}p ${jobid_list}`
echo "JOBID ${jobid}"

# make path to input list
inputlist=`printf ${inputlist_dir}/inputlist_%04d.txt ${jobid}`

# get input files
input_files=`sed -n 1p ${inputlist}`

slurm_folder=`printf slurm_vertex_job%04d ${jobid}`
mkdir -p ${slurm_folder}

cd ${slurm_folder}

# make log file
logfile=`printf log_vertex_%04d.txt ${jobid}`

# echo into it
echo "RUNNING FILTER JOB ${jobid}" > $logfile

shower_dir=${LARLITECV_BASEDIR}/app/LLCVProcessor/DLHandshake/mac

# run 0
# command
echo "python ${shower_dir}/reco_shower.py ${input_files} ." >> $logfile

python ${shower_dir}/reco_shower.py ${input_files} . >> $logfile 2>&1 || exit

# run 1
# command
echo "python ${shower_dir}/run_ShowerQuality_nueshowers.py shower_reco_out_${jobid}.root ." >> $logfile

python ${shower_dir}/run_ShowerQuality_nueshowers.py shower_reco_out_${jobid}.root . >> $logfile 2>&1 || exit

# copy output
rsync -av shower*.root ${output_dir}

cd $jobdir

