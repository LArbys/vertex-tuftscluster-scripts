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
ssnet_inputlist=`printf ${inputlist_dir}/ssnet_inputlist_%05d.txt ${jobid}`
vertex_inputlist=`printf ${inputlist_dir}/vertex_inputlist_%05d.txt ${jobid}`
reco2d_inputlist=`printf ${inputlist_dir}/reco2d_inputlist_%05d.txt ${jobid}`
mcinfo_inputlist=`printf ${inputlist_dir}/mcinfo_inputlist_%05d.txt ${jobid}`

#
# get input files
#
input_ssnet_file=`sed -n 1p ${ssnet_inputlist}`
input_vertex_file=`sed -n 1p ${vertex_inputlist}`
input_reco2d_file=`sed -n 1p ${reco2d_inputlist}`
input_mcinfo_file=`sed -n 1p ${mcinfo_inputlist}`

slurm_folder=`printf slurm_inter_job%05d ${jobid}`
mkdir -p ${slurm_folder}
cd ${slurm_folder}

#
# make log file
#
logfile=`printf log_inter_%05d.txt ${jobid}`
touch ${logfile}

#
# echo into it
#
echo "RUNNING LL JOB ${jobid}" > $logfile


#
# go to work directory
#
tracker_dir=${LARCV_BASEDIR}/app/Reco3D/mac/
tracker_ana_dir=${LARLITE_USERDEVDIR}/RecoTool/TrackReco3D/mac
match_dir=${LARLITECV_BASEDIR}/app/LLCVProcessor/RecoTruthMatch/mac/

#
# define cfg files
#
tracker_cfg_file=${jobdir}/YYY
cat $tracker_cfg_file >> $logfile

tracker_ana_cfg_file=${jobdir}/ZZZ
cat $tracker_ana_cfg_file >> $logfile

#
# Permissions
#
chmod -R 777 ${output_dir}
chmod -R 777 `pwd -P`/
chmod -R 777 `pwd -P`/../

#
# RUN tracker with nueid output
#
echo " "
echo " "
echo " "
echo " "

echo "run track..." >> $logfile
echo "python ${tracker_dir}/run_reco3d.py ${tracker_cfg_file} ${input_ssnet_file} ${input_vertex_file} ." >> $logfile
python ${tracker_dir}/run_reco3d.py ${tracker_cfg_file} ${input_ssnet_file} ${input_vertex_file} . >> $logfile 2>&1
rc=$?; 
chmod 777 *
if [[ $rc != 0 ]]; then exit $rc; fi
echo "...track complete" >> $logfile

echo "analyze track..." >> $logfile
echo "python ${tracker_ana_dir}/run_TrackQuality.py tracker_reco_${jobid}.root ${input_reco2d_file} ${input_mcinfo_file} . >> $logfile 2>&1"
python ${tracker_ana_dir}/run_TrackQuality.py tracker_reco_${jobid}.root ${input_reco2d_file} ${input_mcinfo_file} . >> $logfile 2>&1
rc=$?;
chmod 777 *
if [[ $rc != 0 ]]; then exit $rc; fi
echo "... analyze complete" >> $logfile

echo "truth match track..." >> $logfile
echo "python ${match_dir}/ana_truth_match.py ${tracker_ana_cfg_file} track ${input_ssnet_file} tracker_reco_${jobid}.root ." >> $logfile
python ${match_dir}/ana_truth_match.py ${tracker_ana_cfg_file} track ${input_ssnet_file} tracker_reco_${jobid}.root . >> $logfile 2>&1
rc=$?;
chmod 777 *
if [[ $rc != 0 ]]; then exit $rc; fi
echo "...truth match complete" >> $logfile

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
rsync -av *.png ${output_dir}
chmod -R 777 ${output_dir}
chmod -R 777 `pwd -P`/
chmod -R 777 `pwd -P`/.pylardcache
chmod -R 777 `pwd -P`/../
rm -rf *.root
rm -rf *.pkl
rm -rf *.png
rm -rf .pylardcache
echo "...copied" >> $logfile
