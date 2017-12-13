#!/bin/bash

python py/combine_folders.py ../1e1p_v4_reco_union_p00 1
python py/combine_folders.py ../1e1p_v4_reco_cosmic_union_p00 1
python py/combine_folders.py ../1e1p_v4_reco_true_union_p00 1
python py/combine_folders.py ../1e1p_v4_reco_true_cosmic_union_p00 1
python py/combine_folders.py ../1e1p_v4_reco_base_union_p00 1

python py/combine_folders.py ../1mu1p_v4_reco_union_p00 1
python py/combine_folders.py ../1mu1p_v4_reco_cosmic_union_p00 1
python py/combine_folders.py ../1mu1p_v4_reco_true_union_p00 1
python py/combine_folders.py ../1mu1p_v4_reco_true_cosmic_union_p00 1
python py/combine_folders.py ../1mu1p_v4_reco_base_union_p00 1

python py/combine_folders.py ../extbnb_rep_p00_v4_reco_base_union_p00 1
python py/combine_folders.py ../extbnb_rep_p01_v4_reco_base_union_p00 1
python py/combine_folders.py ../bnbdata_5e19_v4_reco_base_union_p00 1