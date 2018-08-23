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
inputlist=`printf ${inputlist_dir}/inputlist_%05d.txt ${jobid}`

# get input files
input_ssnet_file=`sed -n 1p ${inputlist}`

slurm_folder=`printf slurm_vertex_job%05d ${jobid}`

mkdir -p ${slurm_folder}

cd $slurm_folder

# Make log file
logfile=`printf log_vertex_%05d.txt ${jobid}`

# echo into it
echo "RUNNING VERTEX JOB ${jobid}" > $logfile
echo "ssnet file: ${input_ssnet_file}" >> $logfile

# temp output files
outfile_ana_temp=`printf vertexana_%05d.root ${jobid}`
outfile_out_temp=`printf vertexout_%05d.root ${jobid}`

echo "temporary ana file: ${outfile_ana_temp}" >> $logfile
echo "temporary out file: ${outfile_out_temp}" >> $logfile


# define cfg file
cfg_file=${jobdir}/XXX
cat $cfg_file >> $logfile

vtx_reco_dir=${LARCV_BASEDIR}/app/LArOpenCVHandle/cfg/mac/
stage2_ana_dir=${LARCV_BASEDIR}/app/LArOpenCVHandle/ana/likelihood/nue/

#
# Permissions
#
chmod -R a+rwx ${output_dir}
chmod -R a+rwx `pwd -P`/*
chmod -R a+rwx `pwd -P`/../*

# RECO
echo " "
echo " "
echo " "
echo " "
echo "reco..." >> $logfile
echo "python ${vtx_reco_dir}/run_reco.py ${cfg_file} ${outfile_ana_temp} ${outfile_out_temp} ${input_ssnet_file} . " >> $logfile
python ${vtx_reco_dir}/run_reco.py ${cfg_file} ${outfile_ana_temp} ${outfile_out_temp} ${input_ssnet_file} . >> $logfile 2>&1
chmod -R a+rwx ${output_dir}
rc=$?; if [[ $rc != 0 ]]; then exit $rc; fi
echo "..recoed" >> $logfile
echo " "
echo " "
echo " "
echo " "

# PKL
echo " "
echo " "
echo " "
echo " "
echo "pickle..." >> $logfile
echo "python ${stage2_ana_dir}/make_vertex_pickle.py ${outfile_ana_temp} . " >> $logfile
python ${stage2_ana_dir}/make_vertex_pickle.py ${outfile_ana_temp} . >> $logfile 2>&1
chmod -R a+rwx ${output_dir}
rc=$?; if [[ $rc != 0 ]]; then exit $rc; fi
echo "..pickled" >> $logfile
echo " "
echo " "
echo " "
echo " "


# COPY DATA
echo "copying..." >> $logfile
rsync -av *.root ${output_dir}
rsync -av *.pkl ${output_dir}
chmod -R +t,a+rwx ${output_dir}
chmod -R +t,a+rwx `pwd -P`/
chmod -R +t,a+rwx `pwd -P`/.pylardcache
chmod -R +t,a+rwx `pwd -P`/../
rm -rf *.root
rm -rf *.pkl
rm -rf .pylardcache
echo "...copied" >> $logfile
