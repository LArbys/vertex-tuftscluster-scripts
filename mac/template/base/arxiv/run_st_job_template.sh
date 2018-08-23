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
reco_inputlist=`printf ${inputlist_dir}/reco_inputlist_%05d.txt ${jobid}`
vertex_inputlist=`printf ${inputlist_dir}/vertex_inputlist_%05d.txt ${jobid}`
pkl_inputlist=`printf ${inputlist_dir}/pkl_inputlist_%05d.txt ${jobid}`
ll_inputlist=`printf ${inputlist_dir}/ll_inputlist_%05d.txt ${jobid}`

#
# get input files
#
input_ssnet_file=`sed -n 1p ${reco_inputlist}`
input_reco_file=`sed -n 1p ${vertex_inputlist}`
input_pkl_file=`sed -n 1p ${pkl_inputlist}`
input_ll_files=`sed -n 1p ${ll_inputlist}`

slurm_folder=`printf slurm_st_job%05d ${jobid}`
mkdir -p ${slurm_folder}
cd ${slurm_folder}

#
# make log file
#
logfile=`printf log_st_%05d.txt ${jobid}`
touch ${logfile}

#
# echo into it
#
echo "RUNNING VERTEX JOB ${jobid}" > $logfile
echo "ssnet file: ${input_ssnet_file}" >> $logfile

#
# go to work directory
#
shower_dir=${LARLITECV_BASEDIR}/app/LLCVProcessor/DLHandshake/mac/

tracker_dir=${LARCV_BASEDIR}/app/Reco3D/mac/
match_dir=${LARLITECV_BASEDIR}/app/LLCVProcessor/RecoTruthMatch/mac

tracker_ana_dir=${LARLITE_USERDEVDIR}/RecoTool/TrackReco3D/mac

nue_ll_dir=${LARCV_BASEDIR}/app/LArOpenCVHandle/ana/likelihood/nue/

# define cfg files
tracker_cfg_file=${jobdir}/YYY
cat $tracker_cfg_file >> $logfile

tracker_ana_cfg_file=${jobdir}/ZZZ
cat $tracker_ana_cfg_file >> $logfile

shower_ana_cfg_file=${jobdir}/RRR
cat $shower_ana_cfg_file >> $logfile

#
# RUN shower reco
#
echo " "
echo " "
echo " "
echo " "

echo "run shower..." >> $logfile
echo "python ${shower_dir}/reco_recluster_shower.py ${input_reco_file} ${input_ll_files} . 0 AAA" >> $logfile
python ${shower_dir}/reco_recluster_shower.py ${input_reco_file} ${input_ll_files} . 0 AAA >> $logfile 2>&1 || exit
echo "...shower complete" >> $logfile

echo "analyze shower..." >> $logfile
echo "python ${shower_dir}/run_ShowerQuality.py shower_reco_out_${jobid}.root ." >> $logfile
python ${shower_dir}/run_ShowerQuality.py shower_reco_out_${jobid}.root . >> $logfile 2>&1 || exit
echo "...shower analyzed" >> $logfile

echo "match shower..." >> $logfile
echo "python ${match_dir}/ana_truth_match.py ${shower_ana_cfg_file} shower ${input_ssnet_file} shower_reco_out_${jobid}.root" >> $logfile
python ${match_dir}/ana_truth_match.py ${shower_ana_cfg_file} shower ${input_ssnet_file} shower_reco_out_${jobid}.root . >> $logfile 2>&1 || exit
echo "... match complete" >> $logfile

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
echo "python ${tracker_dir}/run_reco3d.py ${tracker_cfg_file} ${input_ssnet_file} ${input_reco_file} ." >> $logfile
python ${tracker_dir}/run_reco3d.py ${tracker_cfg_file} ${input_ssnet_file} ${input_reco_file} . >> $logfile 2>&1 || exit
echo "...track complete" >> $logfile

echo "analyze track..." >> $logfile
echo "python ${tracker_ana_dir}/run_TrackQuality.py tracker_reco_${jobid}.root ${input_ll_files} . >> $logfile 2>&1 || exit"
python ${tracker_ana_dir}/run_TrackQuality.py tracker_reco_${jobid}.root ${input_ll_files} . >> $logfile 2>&1 || exit
echo "... analyze complete" >> $logfile

echo "reco match track..." >> $logfile
echo "python ${match_dir}/ana_reco_match.py ${tracker_ana_cfg_file} ${input_ssnet_file} ${input_reco_file} tracker_reco_${jobid}.root" >> $logfile
python ${match_dir}/ana_reco_match.py ${tracker_ana_cfg_file} ${input_ssnet_file} ${input_reco_file} tracker_reco_${jobid}.root . >> $logfile 2>&1 || exit
echo "...reco match complete" >> $logfile

echo "truth match track..." >> $logfile
echo "python ${match_dir}/ana_truth_match.py ${tracker_ana_cfg_file} track ${input_ssnet_file} tracker_reco_${jobid}.root" >> $logfile
python ${match_dir}/ana_truth_match.py ${tracker_ana_cfg_file} track ${input_ssnet_file} tracker_reco_${jobid}.root . >> $logfile 2>&1 || exit
echo "...truth match complete" >> $logfile

echo " "
echo " "
echo " "
echo " "

#
# RUN track+shower combine
#
echo " "
echo " "
echo " "
echo " "
echo "python ${nue_ll_dir}/combine_st.py showerqualsingle_${jobid}.root shower_truth_match_${jobid}.root trackqualsingle_${jobid}.root tracker_anaout_${jobid}.root track_truth_match_${jobid}.root track_pgraph_match_${jobid}.root ." >> $logfile
python ${nue_ll_dir}/combine_st.py showerqualsingle_${jobid}.root shower_truth_match_${jobid}.root trackqualsingle_${jobid}.root tracker_anaout_${jobid}.root track_truth_match_${jobid}.root track_pgraph_match_${jobid}.root . >> $logfile 2>&1 || exit
echo " "
echo " "
echo " "
echo " "


#
# RUN vertex+track+shower combine
#
echo " "
echo " "
echo " "
echo " "
echo "python ${nue_ll_dir}/combine_rst.py ${input_pkl_file} st_comb_df_${jobid} ." >> $logfile
python ${nue_ll_dir}/combine_rst.py ${input_pkl_file} st_comb_df_${jobid}.pkl . >> $logfile 2>&1 || exit
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
