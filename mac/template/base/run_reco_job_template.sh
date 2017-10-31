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

# Get job id
let "proc_line=${SLURM_PROCID}+1"
let jobid=`sed -n ${proc_line}p ${jobid_list}`
echo "JOBID ${jobid}"

# make path to input list
inputlist=`printf ${inputlist_dir}/inputlist_%04d.txt ${jobid}`

# get input files
input_ssnet_file=`sed -n 1p ${inputlist}`

slurm_folder=`printf slurm_vertex_job%04d ${jobid}`
mkdir -p ${slurm_folder}

# Make log file
logfile=`printf ${slurm_folder}/log_vertex_%04d.txt ${jobid}`

# echo into it
echo "RUNNING VERTEX JOB ${jobid}" > $logfile
echo "ssnet file: ${input_ssnet_file}" >> $logfile

# temp output files
outfile_ana_temp=`printf ${slurm_folder}/vertexana_%04d ${jobid}`
outfile_out_temp=`printf ${slurm_folder}/vertexout_%04d ${jobid}`

echo "temporary ana file: ${outfile_ana_temp}" >> $logfile
echo "temporary out file: ${outfile_out_temp}" >> $logfile

# define output
outfile_vertex=`printf ${output_dir}/vertexout_larcv_%04d.root ${jobid}`
anafile_vertex=`printf ${output_dir}/vertexana_larcv_%04d.root ${jobid}`
echo "final output location: ${outfile_vertex}" >> $logfile
echo "final ana location: ${anafile_vertex}" >> $logfile

# define cfg file
cfg_file=${jobdir}/XXX
cat $cfg_file >> $logfile

vtx_reco_dir=${LARCV_BASEDIR}/app/LArOpenCVHandle/cfg/mac/

# command
echo "RUNNING: python ${LARCV_BASEDIR}/app/LArOpenCVHandle/cfg/mac/run.py ${cfg_file} ${outfile_ana_temp} ${outfile_out_temp} ${input_ssnet_file}" >> $logfile

# RUN
python ${vtx_reco_dir}/run_reco.py ${cfg_file} ${outfile_ana_temp} ${outfile_out_temp} ${input_ssnet_file} . >> $logfile 2>&1 || exit

# COPY DATA
rsync -av ${outfile_ana_temp}.root $anafile_vertex
rsync -av ${outfile_out_temp}.root $outfile_vertex


# clean up
#rm -r $slurm_folder
