import os,sys
import ROOT as rt

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

# Check job id list. Check output folder. Check that tagger output files have entries (and same number of entries)
# based on checks, will produce rerun list

# MCC8.1 nue+cosmic: Maccfrey
#VERTEX_FOLDER="/home/taritree/larbys/data/mcc8.1/nue_1eNpfiltered/out_week0626/vertex"

# MCC8.1 nue+cosmic: Tufts
#VERTEX_FOLDER="/cluster/kappa/90-days-archive/wongjiradlab/larbys/data/mcc8.1/nue_1eNpfiltered/out_week072517/vertex_ssnetmcc8_cosmictags"

# MCC8.1 nue only: Tufts
#VERTEX_FOLDER="/cluster/kappa/90-days-archive/wongjiradlab/larbys/data/mcc8.1/nue_nocosmic_1eNpfiltered/out_week0626/vertex"

# MCC8.1 numu+cosmic: Tufts
#VERTEX_FOLDER="/cluster/kappa/90-days-archive/wongjiradlab/larbys/data/mcc8.1/numu_1muNpfiltered/out_week071017/vertex_cosmictags"

# COMPARISON SAMPLES
#VERTEX_FOLDER=DATAFOLDER+"/comparison_samples/1e1p/out_week080717/vertex_ssnetmcc8_cosmictags"
VERTEX_FOLDER=DATAFOLDER+"/comparison_samples/inclusive_elec/out_week080717/vertex_ssnetmcc8_cosmictags"


files = os.listdir(VERTEX_FOLDER)

file_dict = {}
for f in files:
    f.strip()
    idnum = int(f.split("_")[-1].split(".")[0])
    if idnum not in file_dict:
        file_dict[idnum] = {"vertexana":None,"vertexout":None}
    if "vertexana" in f:
        file_dict[idnum]["vertexana"] = VERTEX_FOLDER+"/"+f
    elif "vertexout" in f:
        file_dict[idnum]["vertexout"] = VERTEX_FOLDER+"/"+f

ids = file_dict.keys()
ids.sort()


rerun_list = []
good_list = []
for fid in ids:
    try:
        rfile_vertexout = rt.TFile( file_dict[fid]["vertexout"] )
        tree = rfile_vertexout.Get("pixel2d_test_img_tree")
        nentries_out = tree.GetEntries()

        rfile_vertexana = rt.TFile( file_dict[fid]["vertexana"] )
        tree = rfile_vertexana.Get("EventVertexTree")
        nentries_ana = tree.GetEntries()

        good_list.append(fid)
    except:
        print "Not ok: ",fid
        rerun_list.append(fid)
        continue

print "Goodlist: ",len(good_list)
print "Rerunlist: ",len(rerun_list)

# read in jobidlist
fjobid = open("jobidlist.txt",'r')
ljobid = fjobid.readlines()
for l in ljobid:
    jobid = int(l.strip())
    if jobid in good_list or jobid in rerun_list:
        continue
    else:
        rerun_list.append(jobid)
fjobid.close()


frerun = open("rerunlist.txt",'w')
for jobid in rerun_list:
    print >> frerun,jobid
frerun.close()
