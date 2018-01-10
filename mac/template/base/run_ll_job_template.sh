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
vertex_inputlist=`printf ${inputlist_dir}/vertex_inputlist_%04d.txt ${jobid}`
pkl_inputlist=`printf ${inputlist_dir}/pkl_inputlist_%04d.txt ${jobid}`

#
# get input files
#
input_vertex_file=`sed -n 1p ${vertex_inputlist}`
input_pkl_file=`sed -n 1p ${pkl_inputlist}`

slurm_folder=`printf slurm_ll_job%04d ${jobid}`
mkdir -p ${slurm_folder}
cd ${slurm_folder}

#
# make log file
#
logfile=`printf log_ll_%04d.txt ${jobid}`
touch ${logfile}

#
# echo into it
#
echo "RUNNING LL JOB ${jobid}" > $logfile

#
# go to work directory
#

nue_ll_dir=${LARCV_BASEDIR}/app/LArOpenCVHandle/ana/likelihood/nue/
final_file_dir=${LARCV_BASEDIR}/app/LArOpenCVHandle/ana/final_file/
filter_dir=${LARCV_BASEDIR}/app/LArOpenCVHandle/ana/pgraph_filter/

#
# RUN LL 
#
echo " "
echo " "
echo " "
echo " "

pdf_file=${LARCV_BASEDIR}/app/LArOpenCVHandle/ana/likelihood/nue/bin/nue_pdfs.root
line_file=${LARCV_BASEDIR}/app/LArOpenCVHandle/ana/likelihood/nue/bin/nue_line_file.root

echo "run LL..." >> $logfile
echo "python ${nue_ll_dir}/run_likelihood.py ${input_pkl_file} ${pdf_file} ${line_file} AAA ." >> $logfile
python ${nue_ll_dir}/run_likelihood.py ${input_pkl_file} ${pdf_file} ${line_file} AAA . >> $logfile 2>&1 || exit
echo "... LL complete" >> $logfile

echo " "
echo " "
echo " "
echo " "

#
# RUN final file
#
echo " "
echo " "
echo " "
echo " "

echo "run final file..." >> $logfile
echo "python ${final_file_dir}/make_ttree.py rst_LL_comb_df_${jobid}.pkl AAA ." >> $logfile
python ${final_file_dir}/make_ttree.py rst_LL_comb_df_${jobid}.pkl AAA . >> $logfile 2>&1 || exit
echo "...final file complete" >> $logfile

echo " "
echo " "
echo " "
echo " "

#
# RUN filter
#
echo " "
echo " "
echo " "
echo " "

echo "run pgraph filter..." >> $logfile
echo "python ${filter_dir}/filter.py ${input_vertex_file} nue_analysis_${jobid}.root ." >> $logfile
python ${filter_dir}/filter.py ${input_vertex_file} nue_analysis_${jobid}.root . >> $logfile 2>&1 || exit
echo "...final file complete" >> $logfile

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
