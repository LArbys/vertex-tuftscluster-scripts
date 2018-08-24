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
tagger_lcv_inputlist=`printf ${inputlist_dir}/tagger_lcv_inputlist_%05d.txt ${jobid}`
tagger_ll_inputlist=`printf ${inputlist_dir}/tagger_ll_inputlist_%05d.txt ${jobid}`
vertex_ana_inputlist=`printf ${inputlist_dir}/vertex_ana_inputlist_%05d.txt ${jobid}`
tracker_ana_inputlist=`printf ${inputlist_dir}/tracker_ana_inputlist_%05d.txt ${jobid}`
tracker_truth_inputlist=`printf ${inputlist_dir}/tracker_truth_inputlist_%05d.txt ${jobid}`
mcinfo_inputlist=`printf ${inputlist_dir}/mcinfo_inputlist_%05d.txt ${jobid}`
opreco_inputlist=`printf ${inputlist_dir}/opreco_inputlist_%05d.txt ${jobid}`

#
# get input files
#
input_tagger_lcv_file=`sed -n 1p ${tagger_lcv_inputlist}`
input_tagger_ll_file=`sed -n 1p ${tagger_ll_inputlist}`
input_vertex_ana_file=`sed -n 1p ${vertex_ana_inputlist}`
input_tracker_ana_file=`sed -n 1p ${tracker_ana_inputlist}`
input_tracker_truth_file=`sed -n 1p ${tracker_truth_inputlist}`
input_mcinfo_file=`sed -n 1p ${mcinfo_inputlist}`
input_opreco_file=`sed -n 1p ${opreco_inputlist}`

slurm_folder=`printf slurm_ll_job%05d ${jobid}`
mkdir -p ${slurm_folder}
cd ${slurm_folder}

#
# make log file
#
logfile=`printf log_ll_%05d.txt ${jobid}`
touch ${logfile}

#
# echo into it
#
echo "RUNNING LL JOB ${jobid}" > $logfile

#
# go to work directory
#
numu_ll_dir=${LARCV_BASEDIR}/app/LArOpenCVHandle/ana/likelihood/numu/
mcdump_dir=${LARLITECV_BASEDIR}/app/LLCVProcessor/DLHandshake/mac/
xing_dir=${LARCV_BASEDIR}/app/LArOpenCVHandle/ana/cosmic_xing/
pot_dir=${LARCV_BASEDIR}/app/LArOpenCVHandle/ana/pot/
flux_dir=${LARLITE_USERDEVDIR}/SelectionTool/FluxRW_test/mac/

#
# Permissions
#
chmod -R a+rwx ${output_dir}
chmod -R a+rwx `pwd -P`
chmod -R a+rwx `pwd -P`/../

#
# RUN NuMu LL 
#
echo " "
echo " "
echo " "
echo " "

numu_pkl1=${numu_ll_dir}/3DLLPdfs_1mu1p_vs_cosmic_HIGHSTAT.pickle
numu_pkl2=${numu_ll_dir}/3DLLPdfs_1mu1p_vs_nubkg_HIGHSTAT.pickle
numu_pkl3=${numu_ll_dir}/3DLLPdfs_CCpi0_vs_cosmic_HIGHSTAT.pickle

echo "run numu LL..." >> $logfile
echo "python ${numu_ll_dir}/MakeNuMuSelectionFiles.py ${input_tracker_ana_file} ${input_vertex_ana_file} ${numu_pkl1} ${numu_pkl2} ${numu_pkl3} ." >> $logfile
python ${numu_ll_dir}/MakeNuMuSelectionFiles.py ${input_tracker_ana_file} ${input_vertex_ana_file} ${numu_pkl1} ${numu_pkl2} ${numu_pkl3} . >> $logfile 2>&1
rc=$?;
chmod a+rwx *
if [[ $rc != 0 ]]; then exit $rc; fi
echo "... numu LL complete" >> $logfile

echo " "
echo " "
echo " "
echo " "

#
# RUN mcinfo_dump
#
echo " "
echo " "
echo " "
echo " "

echo "run mcinfo dump..." >> $logfile
echo "python ${mcdump_dir}/run_MCDump.py ${input_mcinfo_file} ${jobid} ." >> $logfile
python ${mcdump_dir}/run_MCDump.py ${input_mcinfo_file} ${jobid} . >> $logfile 2>&1
rc=$?;
chmod -R a+rwx *
if [[ $rc != 0 ]]; then exit $rc; fi
echo "... mcinfo dump complete" >> $logfile

echo " "
echo " "
echo " "
echo " "

#
# RUN tagger dump
#
echo " "
echo " "
echo " "
echo " "

echo "run tagger dump..." >> $logfile
echo "python ${mcdump_dir}/run_TaggerDump.py ${input_tagger_ll_file} ${jobid} ." >> $logfile
python ${mcdump_dir}/run_TaggerDump.py ${input_tagger_ll_file} ${jobid} . >> $logfile 2>&1
rc=$?;
chmod a+rwx *
if [[ $rc != 0 ]]; then exit $rc; fi
echo "... tagger dump complete" >> $logfile

echo " "
echo " "
echo " "
echo " "

#
# tagger PMT precuts dump
#
echo " "
echo " "
echo " "
echo " "

echo "run pmt precut dump..." >> $logfile
echo "python ${mcdump_dir}/run_PMTPrecuts.py ${input_opreco_file} YYY ${jobid} ." >> $logfile
python ${mcdump_dir}/run_PMTPrecuts.py ${input_opreco_file} YYY ${jobid} . >> $logfile 2>&1
rc=$?;
chmod a+rwx *
if [[ $rc != 0 ]]; then exit $rc; fi
echo "... pmt precut dump complete" >> $logfile

echo " "
echo " "
echo " "
echo " "


#
# tagger xing dump
#
echo " "
echo " "
echo " "
echo " "

echo "run tagger xing dump..." >> $logfile
echo "python ${xing_dir}/run_cosmic.py ${xing_dir}/cosmic_ana.cfg ${input_tagger_lcv_file} ${jobid} ." >> $logfile
python ${xing_dir}/run_cosmic.py ${xing_dir}/cosmic_ana.cfg ${input_tagger_lcv_file} ${jobid} . >> $logfile 2>&1
rc=$?;
chmod a+rwx *
if [[ $rc != 0 ]]; then exit $rc; fi
echo "... tagger xing dump complete" >> $logfile

echo " "
echo " "
echo " "
echo " "

#
# POT dump
#
echo " "
echo " "
echo " "
echo " "

echo "run pot dump..." >> $logfile
echo "python ${pot_dir}/pot_scrape_ll.py ${input_mcinfo_file} pot_scrape_${jobid} ." >> $logfile
python ${pot_dir}/pot_scrape_ll.py ${input_mcinfo_file} pot_scrape_${jobid} . >> $logfile 2>&1
rc=$?;
chmod a+rwx *
if [[ $rc != 0 ]]; then exit $rc; fi
echo "... pot dump complete" >> $logfile

echo " "
echo " "
echo " "
echo " "

#
# fluxRW dump
#
echo " "
echo " "
echo " "
echo " "

echo "run fluxrw dump..." >> $logfile
echo "python ${flux_dir}/run_fluxRW.py ${input_mcinfo_file} ${jobid} ." >> $logfile
python ${flux_dir}/run_fluxRW.py ${input_mcinfo_file} ${jobid} . >> $logfile 2>&1
rc=$?;
chmod a+rwx *
if [[ $rc != 0 ]]; then exit $rc; fi
echo "... fluxrw dump complete" >> $logfile

echo " "
echo " "
echo " "
echo " "

#
# RUN hadd
#
echo " "
echo " "
echo " "
echo " "

echo "run hadd..." >> $logfile
export LD_LIBRARY_PATH=/.singularity.d/libs:/usr/local/lib
echo "hadd dllee_vertex_${jobid}.root FinalVertexVariables_${jobid}.root ${input_vertex_ana_file} ${input_tracker_ana_file} ${input_tracker_truth_file}"
hadd dllee_vertex_${jobid}.root FinalVertexVariables_${jobid}.root ${input_vertex_ana_file} ${input_tracker_ana_file} ${input_tracker_truth_file}
rc=$?;
chmod a+rwx *
if [[ $rc != 0 ]]; then exit $rc; fi
echo "... hadd complete" >> $logfile

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
chmod -R a+rwx ${output_dir}
chmod -R a+rwx `pwd -P`
chmod -R a+rwx `pwd -P`/.pylardcache
chmod -R a+rwx `pwd -P`/../
rm -rf *.root
rm -rf *.pkl
rm -rf .pylardcache
echo "...copied" >> $logfile
