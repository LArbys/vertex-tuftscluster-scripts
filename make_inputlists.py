import os,sys

# SPECIFY FOLDER WHERE INPUT DATA LIVES
# numu
#LARCV_SOURCE="/cluster/kappa/90-days-archive/wongjiradlab/larbys/data/mcc8/calmod_mcc8_bnb_nu_cosmic_v06_26_01_run01.09000_run01.09399_v01_p00_out"
#TAGGER_SOURCE="/cluster/kappa/90-days-archive/wongjiradlab/larbys/data/out/mcc8numu/"

# mcc8 nue test: tufts
#SSNET_SOURCE="/cluster/kappa/90-days-archive/wongjiradlab/larbys/data/mcc8/nue_intrinsics_fid10/out_week0619/ssnet/"

# mcc8 nue: tufts
SSNET_SOURCE="/cluster/kappa/90-days-archive/wongjiradlab/larbys/data/mcc8.1/nue_1eNpfiltered/out_week0626/ssnet/"

# MCC8.1 nue only: tufts
#SSNET_SOURCE="/cluster/kappa/90-days-archive/wongjiradlab/larbys/data/mcc8.1/nue_nocosmic_1eNpfiltered/out_week0626/ssnet/"

# We parse folder contents for larcv and larlite files
# We keep them in a dictionary
job_dict = {} # key=jobid, value=dict{"larlite":[],"larcv":[]}

files = os.listdir(SSNET_SOURCE)
for f in files:
    f = f.strip()
    if ".root" not in f or "larcv" not in f:
        continue
    fpath = SSNET_SOURCE + "/" + f
    fileid = int(f.split(".")[-2].split("_")[-1])
    print f.strip(),fileid
    if fileid not in job_dict:
        job_dict[fileid] = {"larcv":[],"tagger":[]}
    job_dict[fileid]["larcv"].append(fpath)


fileid_list = job_dict.keys()
fileid_list.sort()

jobidlist = open("jobidlist.txt",'w')
os.system("mkdir -p inputlists")
os.system("rm -f inputlists/*")
for jobid,fileid in enumerate(fileid_list):
    if len(job_dict[fileid]["larcv"])>0:
        flarcv = open("inputlists/inputlist_%04d.txt"%(fileid),'w')
        for f in job_dict[fileid]["larcv"]:
            print >> flarcv,f
        flarcv.close()    
        print >> jobidlist,fileid

jobidlist.close()

