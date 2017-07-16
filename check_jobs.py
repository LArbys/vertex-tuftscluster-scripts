import os,sys
import ROOT as rt

# Check job id list. Check output folder. Check that tagger output files have entries (and same number of entries)
# based on checks, will produce rerun list

# MCC8.1 nue+cosmic: Maccfrey
#VERTEX_FOLDER="/home/taritree/larbys/data/mcc8.1/nue_1eNpfiltered/out_week0626/vertex"

# MCC8.1 nue+cosmic: Tufts
#VERTEX_FOLDER="/cluster/kappa/90-days-archive/wongjiradlab/larbys/data/mcc8.1/nue_1eNpfiltered/out_week071017/vertex"

# MCC8.1 nue only: Tufts
#VERTEX_FOLDER="/cluster/kappa/90-days-archive/wongjiradlab/larbys/data/mcc8.1/nue_nocosmic_1eNpfiltered/out_week0626/vertex"

# MCC8.1 numu+cosmic: Tufts
VERTEX_FOLDER="/cluster/kappa/90-days-archive/wongjiradlab/larbys/data/mcc8.1/numu_1muNpfiltered/out_week071017/vertex_cosmictags"



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
