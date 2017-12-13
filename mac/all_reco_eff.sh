#!/bin/bash

python py/prep_reco_sub.py 1e1p_v4 union cfg/ssnet_segment_nu_only_croi_base_no_cosmic_c10_union.cfg 8;
python py/prep_reco_sub.py 1e1p_v4 cosmic_union cfg/ssnet_segment_nu_only_croi_base_yes_cosmic_c10_union.cfg 8;
python py/prep_reco_sub.py 1e1p_v4 true_union cfg/true_segment_nu_only_croi_base_no_cosmic_c10_union.cfg 8;
python py/prep_reco_sub.py 1e1p_v4 true_cosmic_union cfg/true_segment_nu_only_croi_base_yes_cosmic_c10_union.cfg 8;
python py/prep_reco_sub.py 1e1p_v4 base_union cfg/prod_fullchain_ssnet_combined_newtag_base_c10_union.cfg 8;

python py/prep_reco_sub.py 1mu1p_v4 union cfg/ssnet_segment_nu_only_croi_base_no_cosmic_c10_union.cfg 8;
python py/prep_reco_sub.py 1mu1p_v4 cosmic_union cfg/ssnet_segment_nu_only_croi_base_yes_cosmic_c10_union.cfg 8;
python py/prep_reco_sub.py 1mu1p_v4 true_union cfg/true_segment_nu_only_croi_base_no_cosmic_c10_union.cfg 8;
python py/prep_reco_sub.py 1mu1p_v4 true_cosmic_union cfg/true_segment_nu_only_croi_base_yes_cosmic_c10_union.cfg 8;
python py/prep_reco_sub.py 1mu1p_v4 base_union cfg/prod_fullchain_ssnet_combined_newtag_base_c10_union.cfg 8;

python py/prep_reco_sub.py extbnb_rep_p00_v4 base_union cfg/prod_fullchain_ssnet_combined_newtag_extbnb_c10_union.cfg 12;
python py/prep_reco_sub.py extbnb_rep_p01_v4 base_union cfg/prod_fullchain_ssnet_combined_newtag_extbnb_c10_union.cfg 12;

python py/prep_reco_sub.py bnbdata_5e19_v4 base_union cfg/prod_fullchain_ssnet_combined_newtag_extbnb_c10_union.cfg 12;

