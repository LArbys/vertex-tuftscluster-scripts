#!/bin/bash

#
# nominal
#
python py/combine_folders.py ../1e1p_v4_st_union_p00 1
python py/combine_folders.py ../1e1p_v4_st_cosmic_union_p00 1
python py/combine_folders.py ../1e1p_v4_st_true_union_p00 1
python py/combine_folders.py ../1e1p_v4_st_true_cosmic_union_p00 1
python py/combine_folders.py ../1e1p_v4_st_base_union_p00 1

python py/combine_folders.py ../1mu1p_v4_st_union_p00 1
python py/combine_folders.py ../1mu1p_v4_st_cosmic_union_p00 1
python py/combine_folders.py ../1mu1p_v4_st_true_union_p00 1
python py/combine_folders.py ../1mu1p_v4_st_true_cosmic_union_p00 1
python py/combine_folders.py ../1mu1p_v4_st_base_union_p00 1

python py/combine_folders.py ../extbnb_rep_p00_v4_st_base_union_p00 1
python py/combine_folders.py ../extbnb_rep_p01_v4_st_base_union_p00 1

python py/combine_folders.py ../bnbdata_5e19_v4_st_base_union_p00 1

#
# recluster
#
python py/combine_folders.py ../1e1p_v4_st_union_recluster_p00 1
python py/combine_folders.py ../1e1p_v4_st_cosmic_union_recluster_p00 1
python py/combine_folders.py ../1e1p_v4_st_true_union_recluster_p00 1
python py/combine_folders.py ../1e1p_v4_st_true_cosmic_union_recluster_p00 1
python py/combine_folders.py ../1e1p_v4_st_base_union_recluster_p00 1

python py/combine_folders.py ../1mu1p_v4_st_union_recluster_p00 1
python py/combine_folders.py ../1mu1p_v4_st_cosmic_union_recluster_p00 1
python py/combine_folders.py ../1mu1p_v4_st_true_union_recluster_p00 1
python py/combine_folders.py ../1mu1p_v4_st_true_cosmic_union_recluster_p00 1
python py/combine_folders.py ../1mu1p_v4_st_base_union_recluster_p00 1

python py/combine_folders.py ../extbnb_rep_p00_v4_st_base_union_recluster_p00 1
python py/combine_folders.py ../extbnb_rep_p01_v4_st_base_union_recluster_p00 1

python py/combine_folders.py ../bnbdata_5e19_v4_st_base_union_recluster_p00 1
