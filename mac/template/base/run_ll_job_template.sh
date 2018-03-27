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
vertex_out_inputlist=`printf ${inputlist_dir}/vertex_out_inputlist_%05d.txt ${jobid}`
vertex_ana_inputlist=`printf ${inputlist_dir}/vertex_ana_inputlist_%05d.txt ${jobid}`
tracker_ana_inputlist=`printf ${inputlist_dir}/tracker_ana_inputlist_%05d.txt ${jobid}`
shower_ana_inputlist=`printf ${inputlist_dir}/shower_ana_inputlist_%05d.txt ${jobid}`
rst_pkl_inputlist=`printf ${inputlist_dir}/rst_pkl_inputlist_%05d.txt ${jobid}`
all_ana_inputlist=`printf ${inputlist_dir}/all_ana_inputlist_%05d.txt ${jobid}`

#
# get input files
#
input_vertex_out_file=`sed -n 1p ${vertex_out_inputlist}`
input_vertex_ana_file=`sed -n 1p ${vertex_ana_inputlist}`
input_tracker_ana_file=`sed -n 1p ${tracker_ana_inputlist}`
input_shower_ana_file=`sed -n 1p ${shower_ana_inputlist}`
input_rst_pkl_file=`sed -n 1p ${rst_pkl_inputlist}`
input_all_ana_file=`sed -n 1p ${all_ana_inputlist}`

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

nue_ll_dir=${LARCV_BASEDIR}/app/LArOpenCVHandle/ana/likelihood/nue/
numu_ll_dir=${LARCV_BASEDIR}/app/LArOpenCVHandle/ana/likelihood/numu/
intermediate_file_dir=${LARCV_BASEDIR}/app/LArOpenCVHandle/ana/intermediate_file/
final_file_dir=${LARCV_BASEDIR}/app/LArOpenCVHandle/ana/final_file/
filter_dir=${LARCV_BASEDIR}/app/LArOpenCVHandle/ana/pgraph_filter/

#
# RUN Nue LL 
#
echo " "
echo " "
echo " "
echo " "

pdf_file=${LARCV_BASEDIR}/app/LArOpenCVHandle/ana/likelihood/nue/bin/nue_pdfs.root
line_file=${LARCV_BASEDIR}/app/LArOpenCVHandle/ana/likelihood/nue/bin/nue_line_file.root

echo "run nue LL..." >> $logfile
echo "python ${nue_ll_dir}/run_likelihood.py ${input_rst_pkl_file} ${pdf_file} ${line_file} AAA ." >> $logfile
python ${nue_ll_dir}/run_likelihood.py ${input_rst_pkl_file} ${pdf_file} ${line_file} AAA . >> $logfile 2>&1 || exit
echo "... nue LL complete" >> $logfile

echo " "
echo " "
echo " "
echo " "

#
# RUN NuMu LL 
#
echo " "
echo " "
echo " "
echo " "

#numu_pkl1=${numu_ll_dir}/3DLLPdfs.pickle
#numu_pkl2=${numu_ll_dir}/3DLLPdfs_nufilt.pickle

numu_pkl1=${numu_ll_dir}/3DLLPdfs_1mu1p_vs_cosmic_HIGHSTAT.pickle
numu_pkl2=${numu_ll_dir}/3DLLPdfs_1mu1p_vs_nubkg_HIGHSTAT.pickle
numu_pkl3=${numu_ll_dir}/3DLLPdfs_CCpi0_vs_cosmic_HIGHSTAT.pickle

echo "run numu LL..." >> $logfile
echo "python ${numu_ll_dir}/MakeNuMuSelectionFiles.py ${input_tracker_ana_file} ${input_vertex_ana_file} ${numu_pkl1} ${numu_pkl2} ." >> $logfile
python ${numu_ll_dir}/MakeNuMuSelectionFiles.py ${input_tracker_ana_file} ${input_vertex_ana_file} ${numu_pkl1} ${numu_pkl2} ${numu_pkl3} . >> $logfile 2>&1 || exit
echo "... numu LL complete" >> $logfile

echo "combining numuLL..." >> $logfile
echo "python ${nue_ll_dir}/add_to_rst.py ${input_rst_pkl_file} FinalVertexVariables_${jobid}.root AAA ." >> $logfile
python ${nue_ll_dir}/add_to_rst.py ${input_rst_pkl_file} FinalVertexVariables_${jobid}.root AAA . >> $logfile 2>&1 || exit
echo "...combining numuLL complete" >> $logfile

echo " "
echo " "
echo " "
echo " "

#
# RUN intermediate file
#
echo " "
echo " "
echo " "
echo " "

echo "run intermediate file..." >> $logfile
echo "python ${intermediate_file_dir}/intermediate_file.py rst_LL_comb_df_${jobid}.pkl AAA ." >> $logfile
python ${intermediate_file_dir}/intermediate_file.py rst_LL_comb_df_${jobid}.pkl AAA . >> $logfile 2>&1 || exit
echo "...intermediate file complete" >> $logfile

echo " "
echo " "
echo " "
echo " "

#
# RUN all vertex file
#
echo " "
echo " "
echo " "
echo " "

echo "run all vertex file..." >> $logfile
echo "python ${intermediate_file_dir}/hadd_vertices.py . ${input_all_ana_file}" >> $logfile
python ${intermediate_file_dir}/hadd_vertices.py . ${input_all_ana_file} >> $logfile 2>&1 || exit
echo "...all vertex file complete" >> $logfile

echo " "
echo " "
echo " "
echo " "

#
# RUN precut file
#
echo " "
echo " "
echo " "
echo " "

echo "run precut file..." >> $logfile
echo "python ${nue_ll_dir}/precuts.py rst_LL_comb_df_${jobid}.pkl BBB CCC DDD EEE nue_precut . AAA" >> $logfile
python ${nue_ll_dir}/precuts.py rst_LL_comb_df_${jobid}.pkl BBB CCC DDD EEE nue_precut . AAA >> $logfile 2>&1 || exit
echo "...precut file complete" >> $logfile

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
echo "python ${final_file_dir}/make_ttree.py rst_LL_comb_df_${jobid}.pkl nue_precut_${jobid}.pkl rst_numu_comb_df_${jobid}.pkl  ${input_shower_ana_file} ${input_vertex_out_file} AAA FFF . ">> $logfile
python ${final_file_dir}/make_ttree.py rst_LL_comb_df_${jobid}.pkl nue_precut_${jobid}.pkl rst_numu_comb_df_${jobid}.pkl ${input_shower_ana_file} ${input_vertex_out_file} AAA FFF . >> $logfile 2>&1 || exit
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

echo "... nue ..."
echo "python ${filter_dir}/filter.py ${input_vertex_out_file} dllee_analysis_${jobid}.root nue_ana_tree ." >> $logfile
python ${filter_dir}/filter.py ${input_vertex_out_file} dllee_analysis_${jobid}.root nue_ana_tree . >> $logfile 2>&1 || exit

echo "... numu ..."
echo "python ${filter_dir}/filter.py ${input_vertex_out_file} dllee_analysis_${jobid}.root numu_ana_tree ." >> $logfile
python ${filter_dir}/filter.py ${input_vertex_out_file} dllee_analysis_${jobid}.root numu_ana_tree . >> $logfile 2>&1 || exit

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
