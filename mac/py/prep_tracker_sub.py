import os,sys
from locs import *

if len(sys.argv) != 5:
    print
    print "specify..."
    print
    print "NAME  = str(sys.argv[1])"
    print "TYPE  = str(sys.argv[2])"
    print "NACC  = int(sys.argv[3])"
    print "TARGET= str(sys.argv[4])"
    print
    print "...bye"
    print
    sys.exit(1)

NAME  = str(sys.argv[1])
TYPE   = str(sys.argv[2])
NACC  = int(sys.argv[3])
TARGET= str(sys.argv[4])

NAME_DIR  = DATA_DIR_m[NAME]
PY_DIR   = os.path.dirname(os.path.realpath(__file__))
MAC_DIR   = os.path.join(PY_DIR,"..")
OUT_DIR   = os.path.join(PY_DIR,"../..")

def shell(SS):
    print SS
    os.system(SS)

#
# Read how many files in directory
#
flist_v = [os.path.join(NAME_DIR,f) for f in os.listdir(NAME_DIR) if f.endswith(".root")]
num_v   = [int(os.path.basename(f).split(".")[0].split("_")[-1]) for f in flist_v]


#
# Read how many files in target directory
#
targ_flist_v = [os.path.join(TARGET,f) for f in os.listdir(TARGET) if f.startswith("vertexout_larcv_")]
targ_num_v   = [int(os.path.basename(f).split(".")[0].split("_")[-1]) for f in targ_flist_v]


#
# Slice on number of accounts
#
for accid in xrange(NACC):
    
    # set paths
    name_dir_name = "%s_%s_tracker_p%02d" % (NAME,TYPE,accid)
    name_dir      = os.path.join(PY_DIR,name_dir_name)

    out_dir       = os.path.join(name_dir,"out")
    work_dir      = os.path.join(name_dir,"work")
    inputlists_dir= os.path.join(work_dir,"inputlists")

    shell("mkdir -p %s" % name_dir)
    shell("mkdir -p %s" % out_dir)
    shell("mkdir -p %s" % work_dir)
    shell("mkdir -p %s" % inputlists_dir)
    
    # slice input files
    start = int(accid*len(targ_flist_v) / float(NACC))
    end   = int((accid+1)*len(targ_flist_v) / float(NACC))

    targ_flist_slice = targ_flist_v[start:end]
    targ_num_slice   = targ_num_v[start:end]

    flist_slice = []
    num_slice = []

    for targ_num,targ_flist in zip(targ_num_slice,targ_flist_slice):
        idx = num_v.index(targ_num)
        flist_slice.append(flist_v[idx])
        num_slice.append(num_v[idx])


    assert len(num_slice)      == len(flist_slice)
    assert len(targ_num_slice) == len(targ_flist_slice)

    assert len(num_slice)     == len(targ_num_slice)
    assert len(flist_slice)   == len(targ_flist_slice)

    shell("touch %s" % os.path.join(work_dir,"jobidlist.txt"))    
    
    for num,flist,targ_num,targ_flist in zip(num_slice,flist_slice,
                                             targ_num_slice,targ_flist_slice):
        
        assert int(num) == int(targ_num)

        f = open(os.path.join(inputlists_dir,"inputlist_%04d.txt" % int(num)),"w+")
        f.write(flist)
        f.write(" ")
        f.write(targ_flist)
        f.close()
        del f
        
        f = open(os.path.join(work_dir,"jobidlist.txt"),"a")
        f.write(str(num))
        f.write("\n")
        f.close()
        del f


    shell("scp %s %s" % (os.path.join(work_dir,"jobidlist.txt"),
                         os.path.join(work_dir,"rerunlist.txt")))
    
    # copy & replace templates
    data = ""
    with open(os.path.join(MAC_DIR,"template","run_tracker_job_template.sh"),"r") as f:
        data = f.read()

    with open(os.path.join(work_dir,"run_tracker_job.sh"),"w+") as f:
        f.write(data)

    data = ""
    with open(os.path.join(MAC_DIR,"template","submit_tracker_job.sh"),"r") as f:
        data = f.read()

    data = data.replace("XXX",name_dir_name)
    data = data.replace("YYY",str(len(num_slice)))

    with open(os.path.join(MAC_DIR,"submit_%s.sh" % name_dir_name),"w+") as f:
        f.write(data)
        
    shell("rm -rf %s" % os.path.join(OUT_DIR,name_dir_name))
    shell("mv -f %s %s" % (name_dir,OUT_DIR))
