import os,sys

# DETERMINE MACHINE DATA FOLDER
TUFTS="/cluster/kappa/90-days-archive/wongjiradlab/larbys/data"
MCCAFFREY="/mnt/sdb/larbys/data"
DATAFOLDER="__unset__"
try:
    LOCAL_MACHINE=os.popen("uname -n").readlines()[0].strip()
    if LOCAL_MACHINE not in ["mccaffrey","login001"]:
        raise RuntimeError("unrecognized machine")

    if LOCAL_MACHINE=="mccaffrey":
        DATAFOLDER=MCCAFFREY
    elif LOCAL_MACHINE=="login001":
        DATAFOLDER=TUFTS
        
except:
    print "Could not get machine name"
    LOCAL_MACHINE=os.popen("uname -n").readlines()
    print LOCAL_MACHINE
    sys.exit(-1)

if DATAFOLDER=="__unset__":
    raise RuntimeError("Didnt set DATAFOLDER properly.")

# SPECIFY FOLDER WHERE INPUT DATA LIVES
# numu

# MCC8 Cosmic: MCCAFFERY
#SSNET_SOURCE=DATAFOLDER+"/mcc8.1/corsika_mc/out_week0626/ssnet"


# COMPARISON SAMPLES
# -------------------

# 1e1p
#SSNET_SOURCE=DATAFOLDER+"/comparison_samples/1e1p/out_week080717/ssnet_mcc8"

# 1e1p
SSNET_SOURCE=DATAFOLDER+"/comparison_samples/inclusive_elec/out_week080717/ssnet_mcc8"


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

