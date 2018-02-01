import os,sys
from db import *

if len(sys.argv) != 7:
    print
    print "specify..."
    print
    print "NAME       = str(sys.argv[1])"
    print "TYPE       = str(sys.argv[2])"
    print "IS_MC      = int(sys.argv[3])"
    print "FILTER     = int(sys.argv[4])"
    print "ST_TARGET  = str(sys.argv[5])"
    print "NACC       = int(sys.argv[6])"
    print
    print "...bye"
    print
    sys.exit(1)

NAME       = str(sys.argv[1])
TYPE       = str(sys.argv[2])
IS_MC      = int(sys.argv[3])
FILTER     = int(sys.argv[4])
ST_TARGET  = str(sys.argv[5])
NACC       = int(sys.argv[6])


PY_DIR     = os.path.dirname(os.path.realpath(__file__))
MAC_DIR    = os.path.join(PY_DIR,"..")
OUT_FOLDER = "%s_ll_%s" % (NAME,TYPE)
OUT_DIR    = os.path.join(PY_DIR,"../..",OUT_FOLDER)

SCRIPT_DIR = os.path.join(MAC_DIR,"submit_ll")

def shell(SS):
    print SS
    os.system(SS)

shell("rm -rf %s" % OUT_DIR)
shell("mkdir -p %s" % OUT_DIR)

#
# Read vertex files
#
ret_v = get_stage2_flist(NAME,"test3");

VALID  = 'ana_comb_df'
PREFIX = 'vertexout'

targ_lc_flist_v = [f[PREFIX] for f in ret_v if f[VALID] != ""]
targ_lc_num_v   = [int(f['jobtag']) for f in ret_v if f[VALID] != ""]

#
# Read pickle files
#
targ_pkl_flist_v = [os.path.join(ST_TARGET,f) for f in os.listdir(ST_TARGET) if f.startswith("rst_comb_df") if f.endswith(".pkl")]
targ_pkl_num_v   = [int(os.path.basename(f).split(".")[0].split("_")[-1]) for f in targ_pkl_flist_v]


#
# Slice on number of accounts
#
fout_all = open(os.path.join(MAC_DIR,"submit_all_%s.sh" % (OUT_FOLDER)),"w+")

if NACC < 0:
    NACC = len(targ_pkl_flist_v)

for accid in xrange(NACC):
    
    # set paths
    name_dir_name = "%s_p%02d" % (OUT_FOLDER,accid)
    name_dir      = os.path.join(MAC_DIR,name_dir_name)

    out_dir        = os.path.join(name_dir,"out")
    work_dir       = os.path.join(name_dir,"work")
    inputlists_dir = os.path.join(work_dir,"inputlists")

    shell("mkdir -p %s" % name_dir)
    shell("mkdir -p %s" % out_dir)
    shell("mkdir -p %s" % work_dir)
    shell("mkdir -p %s" % inputlists_dir)
    shell("touch %s" % os.path.join(work_dir,"jobidlist.txt"))    
    
    # slice input files
    start = int(accid*len(targ_lc_flist_v) / float(NACC))
    end   = int((accid+1)*len(targ_lc_flist_v) / float(NACC))

    targ_lc_flist_slice_tmp = targ_lc_flist_v[start:end]
    targ_lc_num_slice_tmp   = targ_lc_num_v[start:end]

    targ_lc_flist_slice = []
    targ_lc_num_slice   = []

    targ_pkl_flist_slice = []
    targ_pkl_num_slice   = []

    for targ_num,targ_flist in zip(targ_lc_num_slice_tmp,
                                   targ_lc_flist_slice_tmp):
        idx = int(-1)
        try:
            idx = targ_pkl_num_v.index(targ_num)
        except ValueError:
            print "@targ_num=%d does not exists @pkl folder" % targ_num
            continue
            
        assert idx>=0

        targ_lc_flist_slice.append(targ_flist)
        targ_lc_num_slice.append(targ_num)

        targ_pkl_flist_slice.append(targ_pkl_flist_v[idx])
        targ_pkl_num_slice.append(targ_pkl_num_v[idx])
    

    num_slice = len(targ_pkl_num_slice)
    if num_slice == 0: 

        shell("rm -rf  %s" % name_dir)
        shell("rm -rf  %s" % out_dir)
        shell("rm -rf %s" % work_dir)
        shell("rm -rf %s" % inputlists_dir)

        continue

    for x in zip(targ_lc_num_slice,targ_lc_flist_slice,
                 targ_pkl_num_slice,targ_pkl_flist_slice):

        targ_lc_num   = x[0]
        targ_lc_flist = x[1]

        targ_pkl_num   = x[2]
        targ_pkl_flist = x[3]

        f = open(os.path.join(inputlists_dir,"vertex_out_inputlist_%05d.txt" % int(targ_lc_num)),"w+")
        tidx = targ_lc_num_v.index(targ_lc_num)
        f.write(targ_lc_flist_v[tidx])
        f.close()
        del f

        f = open(os.path.join(inputlists_dir,"vertex_ana_inputlist_%05d.txt" % int(targ_lc_num)),"w+")
        tidx = targ_lc_num_v.index(targ_lc_num)
        f.write(targ_lc_flist_v[tidx].replace("out","ana"))
        f.close()
        del f

        f = open(os.path.join(inputlists_dir,"tracker_ana_inputlist_%05d.txt" % int(targ_pkl_num)),"w+")
        tidx = targ_pkl_num_v.index(targ_pkl_num)
        temp=targ_pkl_flist_v[tidx].replace("rst_comb_df","tracker_anaout")
        temp=temp.replace("pkl","root")
        f.write(temp)
        f.close()
        del f

        f = open(os.path.join(inputlists_dir,"rst_pkl_inputlist_%05d.txt" % int(targ_pkl_num)),"w+")
        tidx = targ_pkl_num_v.index(targ_pkl_num)
        f.write(targ_pkl_flist_v[tidx])
        f.close()
        del f

        f = open(os.path.join(work_dir,"jobidlist.txt"),"a")
        f.write(str(targ_pkl_num))
        f.write("\n")
        f.close()
        del f


    shell("scp %s %s" % (os.path.join(work_dir,"jobidlist.txt"),
                         os.path.join(work_dir,"rerunlist.txt")))

    # copy & replace templates
    data = ""
    with open(os.path.join(MAC_DIR,"template","run_ll_job_template.sh"),"r") as f:
        data = f.read()

    data = data.replace("AAA",str(int(IS_MC)))

    with open(os.path.join(work_dir,"run_ll_job.sh"),"w+") as f:
        f.write(data)

    data = ""
    with open(os.path.join(MAC_DIR,"template","submit_ll_job.sh"),"r") as f:
        data = f.read()

    data = data.replace("XXX",os.path.join(OUT_DIR,name_dir_name))
    data = data.replace("YYY",str(int(num_slice)))
    data = data.replace("CCC",name_dir_name)

    with open(os.path.join(SCRIPT_DIR,"submit_%s.sh" % name_dir_name),"w+") as f:
        f.write(data)
        
    shell("rm -rf %s" % os.path.join(OUT_DIR,name_dir_name))
    shell("mv -f %s %s" % (name_dir,OUT_DIR))
    fout_all.write("sbatch" + " " + os.path.join(SCRIPT_DIR,"submit_%s.sh\n" % name_dir_name))

fout_all.close()
    
