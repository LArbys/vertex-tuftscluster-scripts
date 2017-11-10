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
reco_inputlist=`printf ${inputlist_dir}/reco_inputlist_%04d.txt ${jobid}`
ll_inputlist=`printf ${inputlist_dir}/ll_inputlist_%04d.txt ${jobid}`

#
# get input files
#
input_ssnet_file=`sed -n 1p ${reco_inputlist}`
input_ll_files=`sed -n 1p ${ll_inputlist}`

slurm_folder=`printf slurm_vertex_job%04d ${jobid}`
mkdir -p ${slurm_folder}
cd ${slurm_folder}

#
# make log file
#
logfile=`printf log_vertex_%04d.txt ${jobid}`
touch ${logfile}

#
# echo into it
#
echo "RUNNING VERTEX JOB ${jobid}" > $logfile
echo "ssnet file: ${input_ssnet_file}" >> $logfile

#
# go to work directory
#
vtx_reco_dir=${LARCV_BASEDIR}/app/LArOpenCVHandle/cfg/mac/
nue_dir=${LARCV_BASEDIR}/app/LArOpenCVHandle/ana/likelihood/nue/
shower_dir=${LARLITECV_BASEDIR}/app/LLCVProcessor/DLHandshake/mac/
tracker_dir=${LARCV_BASEDIR}/app/Reco3D/mac/
final_file_dir=${LARCV_BASEDIR}/app/LArOpenCVHandle/ana/final_file/
#
# temp output files
#
outfile_reco_ana=`printf vertexana_%04d.root ${jobid}`
outfile_reco_out=`printf vertexout_%04d.root ${jobid}`

outfile_nue_ana=`printf vertexana_nue_filter_%04d.root ${jobid}`
outfile_nue_out=`printf vertexout_nue_filter_%04d.root ${jobid}`

# define cfg files
reco_cfg_file=${jobdir}/XXX
cat $reco_cfg_file >> $logfile

tracker_cfg_file=${jobdir}/YYY
cat $tracker_cfg_file >> $logfile

#
# RUN reco
#
echo " "
echo " "
echo " "
echo " "
echo "run reco..." >> $logfile
python ${vtx_reco_dir}/run_reco.py ${reco_cfg_file} ${outfile_reco_ana} ${outfile_reco_out} ${input_ssnet_file} . >> $logfile 2>&1 || exit
echo "...reco complete" >> $logfile
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
echo "run nue..." >> $logfile
python ${nue_dir}/filter_nue.py ${outfile_reco_ana} ${outfile_reco_out} . >> $logfile 2>&1 || exit
echo "... nue complete" >> $logfile
echo " "
echo " "
echo " "
echo " "

#
# RUN shower reco
#
echo " "
echo " "
echo " "
echo " "
echo "run shower..." >> $logfile
python ${shower_dir}/reco_shower.py ${outfile_nue_out} ${input_ll_files} . >> $logfile 2>&1 || exit
echo "...shower complete" >> $logfile
echo "analyze shower..." >> $logfile
python ${shower_dir}/run_ShowerQuality_nueshowers.py shower_reco_out_${jobid}.root . >> $logfile 2>&1 || exit
echo "...shower analyzed" >> $logfile
echo " "
echo " "
echo " "
echo " "

#
# RUN track reco
#
echo " "
echo " "
echo " "
echo " "
echo "run track..." >> $logfile
python ${tracker_dir}/run_reco3d.py ${tracker_cfg_file} ${input_ssnet_file} ${outfile_nue_out} . >> $logfile 2>&1 || exit
echo "...track complete" >> $logfile
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
