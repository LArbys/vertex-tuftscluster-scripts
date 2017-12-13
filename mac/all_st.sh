#!/bin/bash

#
# nominal
#
python py/prep_st_sub.py 1e1p_v4 union cfg/tracker/tracker_read_nue.cfg cfg/truth/track_config_mc.cfg cfg/truth/shower_config_mc.cfg 0 `pwd -P`/../1e1p_v4_reco_union 8
python py/prep_st_sub.py 1e1p_v4 cosmic_union cfg/tracker/tracker_read_nue.cfg cfg/truth/track_config_mc.cfg cfg/truth/shower_config_mc.cfg 0 `pwd -P`/../1e1p_v4_reco_cosmic_union 8
python py/prep_st_sub.py 1e1p_v4 true_union cfg/tracker/tracker_read_nue.cfg cfg/truth/track_config_mc.cfg cfg/truth/shower_config_mc.cfg 0 `pwd -P`/../1e1p_v4_reco_true_union 8
python py/prep_st_sub.py 1e1p_v4 true_cosmic_union cfg/tracker/tracker_read_nue.cfg cfg/truth/track_config_mc.cfg cfg/truth/shower_config_mc.cfg 0 `pwd -P`/../1e1p_v4_reco_true_cosmic_union 8
python py/prep_st_sub.py 1e1p_v4 base_union cfg/tracker/tracker_read_nue.cfg cfg/truth/track_config_mc.cfg cfg/truth/shower_config_mc.cfg 0 `pwd -P`/../1e1p_v4_reco_base_union 8


python py/prep_st_sub.py 1mu1p_v4 union cfg/tracker/tracker_read_nue.cfg cfg/truth/track_config_mc.cfg cfg/truth/shower_config_mc.cfg 0 `pwd -P`/../1mu1p_v4_reco_union 8
python py/prep_st_sub.py 1mu1p_v4 cosmic_union cfg/tracker/tracker_read_nue.cfg cfg/truth/track_config_mc.cfg cfg/truth/shower_config_mc.cfg 0 `pwd -P`/../1mu1p_v4_reco_cosmic_union 8
python py/prep_st_sub.py 1mu1p_v4 true_union cfg/tracker/tracker_read_nue.cfg cfg/truth/track_config_mc.cfg cfg/truth/shower_config_mc.cfg 0 `pwd -P`/../1mu1p_v4_reco_true_union 8
python py/prep_st_sub.py 1mu1p_v4 true_cosmic_union cfg/tracker/tracker_read_nue.cfg cfg/truth/track_config_mc.cfg cfg/truth/shower_config_mc.cfg 0 `pwd -P`/../1mu1p_v4_reco_true_cosmic_union 8
python py/prep_st_sub.py 1mu1p_v4 base_union cfg/tracker/tracker_read_nue.cfg cfg/truth/track_config_mc.cfg cfg/truth/shower_config_mc.cfg 0 `pwd -P`/../1mu1p_v4_reco_base_union 8

python py/prep_st_sub.py extbnb_rep_p00_v4 base_union cfg/tracker/tracker_read_cosmo.cfg cfg/truth/track_config_data.cfg cfg/truth/shower_config_data.cfg 0 `pwd -P`/../extbnb_rep_p00_v4_reco_base_union 12
python py/prep_st_sub.py extbnb_rep_p01_v4 base_union cfg/tracker/tracker_read_cosmo.cfg cfg/truth/track_config_data.cfg cfg/truth/shower_config_data.cfg 0 `pwd -P`/../extbnb_rep_p01_v4_reco_base_union 12
python py/prep_st_sub.py bnbdata_5e19_v4 base_union cfg/tracker/tracker_read_cosmo.cfg cfg/truth/track_config_data.cfg cfg/truth/shower_config_data.cfg 0 `pwd -P`/../bnbdata_5e19_v4_reco_base_union 12

#
# recluster
#
python py/prep_st_sub.py 1e1p_v4 union_recluster cfg/tracker/tracker_read_nue.cfg cfg/truth/track_config_mc.cfg cfg/truth/shower_config_mc.cfg 1 `pwd -P`/../1e1p_v4_reco_union 8
python py/prep_st_sub.py 1e1p_v4 cosmic_union_recluster cfg/tracker/tracker_read_nue.cfg cfg/truth/track_config_mc.cfg cfg/truth/shower_config_mc.cfg 1 `pwd -P`/../1e1p_v4_reco_cosmic_union 8
python py/prep_st_sub.py 1e1p_v4 true_union_recluster cfg/tracker/tracker_read_nue.cfg cfg/truth/track_config_mc.cfg cfg/truth/shower_config_mc.cfg 1 `pwd -P`/../1e1p_v4_reco_true_union 8
python py/prep_st_sub.py 1e1p_v4 true_cosmic_union_recluster cfg/tracker/tracker_read_nue.cfg cfg/truth/track_config_mc.cfg cfg/truth/shower_config_mc.cfg 1 `pwd -P`/../1e1p_v4_reco_true_cosmic_union 8
python py/prep_st_sub.py 1e1p_v4 base_union_recluster cfg/tracker/tracker_read_nue.cfg cfg/truth/track_config_mc.cfg cfg/truth/shower_config_mc.cfg 1 `pwd -P`/../1e1p_v4_reco_base_union 8


python py/prep_st_sub.py 1mu1p_v4 union_recluster cfg/tracker/tracker_read_nue.cfg cfg/truth/track_config_mc.cfg cfg/truth/shower_config_mc.cfg 1 `pwd -P`/../1mu1p_v4_reco_union 8
python py/prep_st_sub.py 1mu1p_v4 cosmic_union_recluster cfg/tracker/tracker_read_nue.cfg cfg/truth/track_config_mc.cfg cfg/truth/shower_config_mc.cfg 1 `pwd -P`/../1mu1p_v4_reco_cosmic_union 8
python py/prep_st_sub.py 1mu1p_v4 true_union_recluster cfg/tracker/tracker_read_nue.cfg cfg/truth/track_config_mc.cfg cfg/truth/shower_config_mc.cfg 1 `pwd -P`/../1mu1p_v4_reco_true_union 8
python py/prep_st_sub.py 1mu1p_v4 true_cosmic_union_recluster cfg/tracker/tracker_read_nue.cfg cfg/truth/track_config_mc.cfg cfg/truth/shower_config_mc.cfg 1 `pwd -P`/../1mu1p_v4_reco_true_cosmic_union 8
python py/prep_st_sub.py 1mu1p_v4 base_union_recluster cfg/tracker/tracker_read_nue.cfg cfg/truth/track_config_mc.cfg cfg/truth/shower_config_mc.cfg 1 `pwd -P`/../1mu1p_v4_reco_base_union 8

python py/prep_st_sub.py extbnb_rep_p00_v4 base_union_recluster cfg/tracker/tracker_read_cosmo.cfg cfg/truth/track_config_data.cfg cfg/truth/shower_config_data.cfg 1 `pwd -P`/../extbnb_rep_p00_v4_reco_base_union 12
python py/prep_st_sub.py extbnb_rep_p01_v4 base_union_recluster cfg/tracker/tracker_read_cosmo.cfg cfg/truth/track_config_data.cfg cfg/truth/shower_config_data.cfg 1 `pwd -P`/../extbnb_rep_p01_v4_reco_base_union 12
python py/prep_st_sub.py bnbdata_5e19_v4 base_union_recluster cfg/tracker/tracker_read_cosmo.cfg cfg/truth/track_config_data.cfg cfg/truth/shower_config_data.cfg 1 `pwd -P`/../bnbdata_5e19_v4_reco_base_union 12
