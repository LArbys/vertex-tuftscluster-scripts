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

#
# get job id
#
let "proc_line=${SLURM_PROCID}+1"
let jobid=`sed -n ${proc_line}p ${jobid_list}`
echo "JOBID ${jobid}"

#
# make path to input lists
#
ssnet_inputlist=`printf ${inputlist_dir}/ssnet_inputlist_%04d.txt ${jobid}`
vertex_inputlist=`printf ${inputlist_dir}/vertex_inputlist_%04d.txt ${jobid}`
shower_inputlist=`printf ${inputlist_dir}/shower_inputlist_%04d.txt ${jobid}`
tracker_inputlist=`printf ${inputlist_dir}/tracker_inputlist_%04d.txt ${jobid}`
opreco_inputlist=`printf ${inputlist_dir}/opreco_inputlist_%04d.txt ${jobid}`
inter_inputlist=`printf ${inputlist_dir}/inter_inputlist_%04d.txt ${jobid}`

#
# get input files
#
input_ssnet_file=`sed -n 1p ${ssnet_inputlist}`
input_vertex_file=`sed -n 1p ${vertex_inputlist}`
input_shower_file=`sed -n 1p ${shower_inputlist}`
input_tracker_file=`sed -n 1p ${tracker_inputlist}`
input_opreco_file=`sed -n 1p ${opreco_inputlist}`
input_inter_file=`sed -n 1p ${inter_inputlist}`

slurm_folder=`printf slurm_inter_job%04d ${jobid}`
mkdir -p ${slurm_folder}
cd ${slurm_folder}

#
# make log file
#
logfile=`printf log_inter_%04d.txt ${jobid}`
touch ${logfile}

#
# echo into it
#
echo "RUNNING LL JOB ${jobid}" > $logfile

#
# go to work directory
#

inter_dir=${LARLITECV_BASEDIR}/app/LLCVProcessor/InterTool/Sel/

#
# RUN InterTool script
#
echo " "
echo " "
echo " "
echo " "

echo "run inter tool script..." >> $logfile
echo "python ${inter_dir}/AAA ${input_ssnet_file} ${input_vertex_file} ${input_opreco_file} ${input_shower_file} ${input_tracker_file} ${input_inter_file} BBB ." >> $logfile
python ${inter_dir}/AAA ${input_ssnet_file} ${input_vertex_file} ${input_opreco_file} ${input_shower_file} ${input_tracker_file} ${input_inter_file} BBB . >> $logfile 2>&1 || exit
echo "... inter tool script run" >> $logfile

echo " "
echo " "
echo " "
echo " "


#
# Copy to output
#
echo "copying..." >> $logfile
rsync -av *.root ${output_dir}
rsync -av *.pkl ${output_dir}
echo "...copied" >> $logfile
