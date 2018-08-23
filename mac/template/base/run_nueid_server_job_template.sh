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
supera_inputlist=`printf ${inputlist_dir}/supera_inputlist_%05d.txt ${jobid}`
ssnet_inputlist=`printf ${inputlist_dir}/ssnet_inputlist_%05d.txt ${jobid}`
tagger_inputlist=`printf ${inputlist_dir}/tagger_inputlist_%05d.txt ${jobid}`
vertex_inputlist=`printf ${inputlist_dir}/vertex_inputlist_%05d.txt ${jobid}`
opreco_inputlist=`printf ${inputlist_dir}/opreco_inputlist_%05d.txt ${jobid}`

tracker_out_inputlist=`printf ${inputlist_dir}/tracker_out_inputlist_%05d.txt ${jobid}`
tracker_ana1_inputlist=`printf ${inputlist_dir}/tracker_ana1_inputlist_%05d.txt ${jobid}`
tracker_ana2_inputlist=`printf ${inputlist_dir}/tracker_ana2_inputlist_%05d.txt ${jobid}`
tracker_dir_inputlist=`printf ${inputlist_dir}/tracker_dir_inputlist_%05d.txt ${jobid}`
tracker_pgraph_inputlist=`printf ${inputlist_dir}/tracker_pgraph_inputlist_%05d.txt ${jobid}`
tracker_truth_inputlist=`printf ${inputlist_dir}/tracker_truth_inputlist_%05d.txt ${jobid}`

pkl_inputlist=`printf ${inputlist_dir}/pkl_inputlist_%05d.txt ${jobid}`
reco2d_inputlist=`printf ${inputlist_dir}/reco2d_inputlist_%05d.txt ${jobid}`

#
# get input files
#
input_supera_file=`sed -n 1p ${supera_inputlist}`
input_ssnet_file=`sed -n 1p ${ssnet_inputlist}`
input_tagger_file=`sed -n 1p ${tagger_inputlist}`
input_vertex_file=`sed -n 1p ${vertex_inputlist}`
input_opreco_file=`sed -n 1p ${opreco_inputlist}`

input_tracker_out_file=`sed -n 1p ${tracker_out_inputlist}`
input_tracker_ana1_file=`sed -n 1p ${tracker_ana1_inputlist}`
input_tracker_ana2_file=`sed -n 1p ${tracker_ana2_inputlist}`
input_tracker_dir_file=`sed -n 1p ${tracker_dir_inputlist}`
input_tracker_truth_file=`sed -n 1p ${tracker_truth_inputlist}`

input_pkl_file=`sed -n 1p ${pkl_inputlist}`
input_reco2d_file=`sed -n 1p ${reco2d_inputlist}`

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
shower_dir=${LARLITECV_BASEDIR}/app/LLCVProcessor/DLHandshake/mac/

match_dir=${LARLITECV_BASEDIR}/app/LLCVProcessor/RecoTruthMatch/mac/

pid_dir=${LARCV_BASEDIR}/../toymodel/simple_inference/

nueid_inter_dir=${LARLITECV_BASEDIR}/app/LLCVProcessor/InterTool/Sel/NueID/mac/

flashmatch_inter_dir=${LARLITECV_BASEDIR}/app/LLCVProcessor/InterTool/Sel/FlashMatch/mac/

stage2_ana_dir=${LARCV_BASEDIR}/app/LArOpenCVHandle/ana/stage2/

#
# define cfg files
#

tracker_ana_cfg_file=${jobdir}/ZZZ
cat $tracker_ana_cfg_file >> $logfile

shower_cfg_file=${jobdir}/KKK
cat $shower_cfg_file >> $logfile

shower_ana_cfg_file=${jobdir}/RRR
cat $shower_ana_cfg_file >> $logfile

inference_cfg_file=${jobdir}/EEE
cat $inference_cfg_file >> $logfile

nueid_cfg_file=${jobdir}/FFF
cat $nueid_cfg_file >> $logfile

flash_cfg_file=${jobdir}/GGG
cat $flash_cfg_file >> $logfile

#
# Permissions
#
chmod -R a+rwx ${output_dir}
chmod -R a+rwx `pwd -P`/
chmod -R a+rwx `pwd -P`/../

#
# RUN nueid InterTool script
#
echo " "
echo " "
echo " "
echo " "

echo "run nueid script..." >> $logfile
echo "python ${nueid_inter_dir}/inter_ana_nue_server.py ${input_supera_file} ${input_ssnet_file} ${input_tagger_file} ${input_vertex_file} ${input_reco2d_file} ${nueid_cfg_file} ${job_id} BBB ." >> $logfile
python ${nueid_inter_dir}/inter_ana_nue_server.py ${input_supera_file} ${input_ssnet_file} ${input_tagger_file} ${input_vertex_file} ${input_reco2d_file} ${nueid_cfg_file} ${job_id} BBB . >> $logfile 2>&1 || exit
echo "... inter nueid script run" >> $logfile

echo " "
echo " "
echo " "
echo " "


#
# RUN shower reco with no reclustering
#
echo " "
echo " "
echo " "
echo " "

echo "run shower..." >> $logfile
echo "python ${shower_dir}/reco_recluster_shower.py nueid_lcv_out_${jobid}.root ${input_reco2d_file} INVALID . 0 0 BBB ${shower_cfg_file}" >> $logfile
python ${shower_dir}/reco_recluster_shower.py nueid_lcv_out_${jobid}.root ${input_reco2d_file} INVALID . 0 0 BBB ${shower_cfg_file} >> $logfile 2>&1 || exit
echo "...shower complete" >> $logfile

echo "analyze shower..." >> $logfile
echo "python ${shower_dir}/run_ShowerQuality.py shower_reco_out_${jobid}.root ${input_reco2d_file} INVALID ." >> $logfile
python ${shower_dir}/run_ShowerQuality.py shower_reco_out_${jobid}.root ${input_reco2d_file} INVALID . >> $logfile 2>&1 || exit
echo "...shower analyzed" >> $logfile

echo "match shower..." >> $logfile
echo "python ${match_dir}/ana_truth_match_server.py ${shower_ana_cfg_file} shower ${input_supera_file} ${input_ssnet_file} shower_reco_out_${jobid}.root" >> $logfile
python ${match_dir}/ana_truth_match_server.py ${shower_ana_cfg_file} shower ${input_supera_file} ${input_ssnet_file} shower_reco_out_${jobid}.root . >> $logfile 2>&1 || exit
echo "... match complete" >> $logfile

echo " "
echo " "
echo " "
echo " "

#
# RUN tracker with nueid output
#
echo " "
echo " "
echo " "
echo " "

echo "reco match track..." >> $logfile
echo "python ${match_dir}/ana_reco_match_server.py ${tracker_ana_cfg_file} ${input_supera_file} ${input_ssnet_file} nueid_lcv_out_${jobid}.root ${input_tracker_out_file} ." >> $logfile
python ${match_dir}/ana_reco_match_server.py ${tracker_ana_cfg_file} ${input_supera_file} ${input_ssnet_file} nueid_lcv_out_${jobid}.root ${input_tracker_out_file} . >> $logfile 2>&1 || exit
echo "...reco match complete" >> $logfile

echo " "
echo " "
echo " "
echo " "

#
# RUN flashmatch with shower and tracks
#
echo " "
echo " "
echo " "
echo " "

echo "run flashmatch inter tool script..." >> $logfile
echo "python ${flashmatch_inter_dir}/inter_ana_flash.py ${input_supera_file} nueid_lcv_out_${jobid}.root ${input_opreco_file} shower_reco_out_${jobid}.root ${input_tracker_out_file} \"\" BBB . inter_nueid_flash.cfg ${input_reco2d_file}" >> $logfile
python ${flashmatch_inter_dir}/inter_ana_flash.py ${input_supera_file} nueid_lcv_out_${jobid}.root ${input_opreco_file} shower_reco_out_${jobid}.root ${input_tracker_out_file} "" BBB . inter_nueid_flash.cfg ${input_reco2d_file} >> $logfile 2>&1 || exit
echo "... flashmatch inter tool script run" >> $logfile

echo " "
echo " "
echo " "
echo " "


#
# RUN simple inference on full image
#
echo " "
echo " "
echo " "
echo " "

echo "run MPID inference script..." >> $logfile
echo "python ${pid_dir}/inference_pid.py ${input_supera_file} nueid_lcv_out_${jobid}.root . ${inference_cfg_file}" >> $logfile
python ${pid_dir}/inference_pid.py ${input_supera_file} nueid_lcv_out_${jobid}.root . ${inference_cfg_file} >> $logfile 2>&1 || exit
echo "... MPID inference script run" >> $logfile

echo "run multiplicity inference script..." >> $logfile
echo "python ${pid_dir}/inference_multiplicity.py ${input_supera_file} nueid_lcv_out_${jobid}.root . ${inference_cfg_file}" >> $logfile
python ${pid_dir}/inference_multiplicity.py ${input_supera_file} nueid_lcv_out_${jobid}.root . ${inference_cfg_file} >> $logfile 2>&1 || exit
echo "... multiplicity inference script run" >> $logfile

echo " "
echo " "
echo " "
echo " "

#
# RUN track+shower+pid combine
#
echo " "
echo " "
echo " "
echo " "
echo "python ${stage2_ana_dir}/combine_stpn.py showerqualsingle_${jobid}.root shower_truth_match_${jobid}.root ${input_tracker_ana2_file} ${input_tracker_ana1_file} ${input_tracker_truth_file} track_pgraph_match_${jobid}.root multipid_out_${jobid}.root multiplicity_out_${jobid}.root nueid_ana_${jobid}.root flash_ana_${jobid}.root ${input_tracker_dir_file} ." >> $logfile
python ${stage2_ana_dir}/combine_stpn.py showerqualsingle_${jobid}.root shower_truth_match_${jobid}.root ${input_tracker_ana2_file} ${input_tracker_ana1_file} ${input_tracker_truth_file} track_pgraph_match_${jobid}.root multipid_out_${jobid}.root multiplicity_out_${jobid}.root nueid_ana_${jobid}.root flash_ana_${jobid}.root ${input_tracker_dir_file} . >> $logfile 2>&1 || exit
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
echo "python ${stage2_ana_dir}/combine_rst.py ${input_pkl_file} stpn_comb_df_${jobid} ." >> $logfile
python ${stage2_ana_dir}/combine_rst.py ${input_pkl_file} stpn_comb_df_${jobid}.pkl . >> $logfile 2>&1 || exit
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
chmod -R a+rwx `pwd -P`/
chmod -R a+rwx `pwd -P`/.pylardcache
chmod -R a+rwx `pwd -P`/../
rm -rf *.root
rm -rf *.pkl
rm -rf .pylardcache
echo "...copied" >> $logfile
