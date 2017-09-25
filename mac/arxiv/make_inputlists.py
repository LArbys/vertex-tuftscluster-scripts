import os,sys

# DETERMINE MACHINE DATA FOLDER
#TUFTS="/cluster/kappa/90-days-archive/wongjiradlab/larbys/data"
#SSNET_SOURCE=DATAFOLDER+"/comparison_samples/1e1p/out_week080717/ssnet_mcc8"
SSNET_SOURCE=str(sys.argv[1])
OUTDIR=str(sys.argv[2])

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

jobidlist = open(os.path.join(OUTDIR,"jobidlist.txt"),'w')
os.system("mkdir -p %s" % os.path.join(OUTDIR,"inputlists"))
os.system("rm -f %s/*" % os.path.join(OUTDIR,"inputlists"))
for jobid,fileid in enumerate(fileid_list):
    if len(job_dict[fileid]["larcv"])>0:
        flarcv = open(os.path.join(OUTDIR,"inputlists/inputlist_%04d.txt"%(fileid)),'w')
        for f in job_dict[fileid]["larcv"]:
            print >> flarcv,f
        flarcv.close()    
        print >> jobidlist,fileid

jobidlist.close()

