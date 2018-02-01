#
# ssnet stuff
#
DATA_DIR_m = {}


DATA_DIR_m['1e1p_v4']="/cluster/kappa/90-days-archive/wongjiradlab/larbys/data/comparison_samples/1e1p/out_week112117/ssnet_mcc8_fixedcroisplity"
DATA_DIR_m['1mu1p_v4']="/cluster/kappa/90-days-archive/wongjiradlab/larbys/data/comparison_samples/1mu1p/out_week112117/ssnet_mcc8_fixedcroisplity"
DATA_DIR_m['bnbdata_5e19_v4'] = "/cluster/kappa/90-days-archive/wongjiradlab/larbys/data/bnbdata_5e19/out_week112117/ssnet_fixedcroisplity"
DATA_DIR_m['extbnb_rep_p00_v4'] = "/cluster/kappa/90-days-archive/wongjiradlab/larbys/data/comparison_samples/extbnb_wprecuts_reprocess/out_week112117/ssnet_fixedcroisplity_p00"
DATA_DIR_m['extbnb_rep_p01_v4'] = "/cluster/kappa/90-days-archive/wongjiradlab/larbys/data/comparison_samples/extbnb_wprecuts_reprocess/out_week112117/ssnet_fixedcroisplity_p01"

DATA_DIR_m['mcc8v3_corsika_p00'] = '/cluster/kappa/90-days-archive/wongjiradlab/larbys/data/symlinks/mcc8v3_corsika_p00/ssnet'
DATA_DIR_m['mcc8v3_corsika_p01'] = '/cluster/kappa/90-days-archive/wongjiradlab/larbys/data/symlinks/mcc8v3_corsika_p01/ssnet'
DATA_DIR_m['mcc8v3_corsika_p02'] = '/cluster/kappa/90-days-archive/wongjiradlab/larbys/data/symlinks/mcc8v3_corsika_p02/ssnet'

DATA_DIR_m['mcc8v4_cocktail_p00'] = '/cluster/kappa/90-days-archive/wongjiradlab/larbys/data/symlinks/mcc8v4_cocktail_p00/ssnet'
DATA_DIR_m['mcc8v4_cocktail_p01'] = '/cluster/kappa/90-days-archive/wongjiradlab/larbys/data/symlinks/mcc8v4_cocktail_p01/ssnet'
DATA_DIR_m['mcc8v4_cocktail_p02'] = '/cluster/kappa/90-days-archive/wongjiradlab/larbys/data/symlinks/mcc8v4_cocktail_p02/ssnet'
DATA_DIR_m['mcc8v4_cocktail_p03'] = '/cluster/kappa/90-days-archive/wongjiradlab/larbys/data/symlinks/mcc8v4_cocktail_p03/ssnet'
DATA_DIR_m['mcc8v4_cocktail_p04'] = '/cluster/kappa/90-days-archive/wongjiradlab/larbys/data/symlinks/mcc8v4_cocktail_p04/ssnet'

#
# larlite stuff
#
LL_DIR_m = {}

LL_DIR_m['1e1p'] = "/cluster/kappa/90-days-archive/wongjiradlab/vgenty/data/comparison_samples/1e1p/larlite"
LL_DIR_m['1e1p_v4'] = LL_DIR_m['1e1p']

LL_DIR_m['1mu1p'] = "/cluster/kappa/90-days-archive/wongjiradlab/vgenty/data/comparison_samples/1mu1p/larlite"
LL_DIR_m['1mu1p_v4'] = LL_DIR_m['1mu1p']

LL_DIR_m['bnbdata_5e19_v4'] = "/cluster/kappa/90-days-archive/wongjiradlab/vgenty/data/comparison_samples/bnbdata_5e19/larlite"

LL_DIR_m['extbnb_rep_p00'] = "/cluster/kappa/90-days-archive/wongjiradlab/vgenty/data/comparison_samples/extbnb_wprecuts_reprocess/larlite_p00/larlite"
LL_DIR_m['extbnb_rep_p01'] = "/cluster/kappa/90-days-archive/wongjiradlab/vgenty/data/comparison_samples/extbnb_wprecuts_reprocess/larlite_p01/larlite"

LL_DIR_m['extbnb_rep_p00_v4'] = LL_DIR_m['extbnb_rep_p00']
LL_DIR_m['extbnb_rep_p01_v4'] = LL_DIR_m['extbnb_rep_p01']

LL_DIR_m['mcc8v4_cocktail_p00'] = "/cluster/kappa/90-days-archive/wongjiradlab/vgenty/data/comparison_samples/mcc8v4_cocktail_p00/larlite"
LL_DIR_m['mcc8v4_cocktail_p01'] = "/cluster/kappa/90-days-archive/wongjiradlab/vgenty/data/comparison_samples/mcc8v4_cocktail_p01/larlite"
LL_DIR_m['mcc8v4_cocktail_p02'] = "/cluster/kappa/90-days-archive/wongjiradlab/vgenty/data/comparison_samples/mcc8v4_cocktail_p02/larlite"
LL_DIR_m['mcc8v4_cocktail_p03'] = "/cluster/kappa/90-days-archive/wongjiradlab/vgenty/data/comparison_samples/mcc8v4_cocktail_p03/larlite"
LL_DIR_m['mcc8v4_cocktail_p04'] = "/cluster/kappa/90-days-archive/wongjiradlab/vgenty/data/comparison_samples/mcc8v4_cocktail_p04/larlite"

LL_DIR_m['mcc8v3_corsika_p00'] = "/cluster/kappa/90-days-archive/wongjiradlab/vgenty/data/comparison_samples/mcc8v3_corsika_p00/larlite"
LL_DIR_m['mcc8v3_corsika_p01'] = "/cluster/kappa/90-days-archive/wongjiradlab/vgenty/data/comparison_samples/mcc8v3_corsika_p01/larlite"
LL_DIR_m['mcc8v3_corsika_p02'] = "/cluster/kappa/90-days-archive/wongjiradlab/vgenty/data/comparison_samples/mcc8v3_corsika_p02/larlite"

UNION_DIR_m = {}
UNION_DIR_m['1e1p'] = "/cluster/kappa/90-days-archive/wongjiradlab/vgenty/data/comparison_samples/1e1p/ssnet_union/"
UNION_DIR_m['1mu1p'] = "/cluster/kappa/90-days-archive/wongjiradlab/vgenty/data/comparison_samples/1mu1p/ssnet_union/"
UNION_DIR_m['signal'] = "/cluster/kappa/90-days-archive/wongjiradlab/vgenty/data/signal_samples/output"

if __name__ == '__main__':
    print
    print "Keys in DATA_DIR_m"

    for ix,key in enumerate(DATA_DIR_m):
        print "%02d) %s"%(ix,key)
    
    print
    print
