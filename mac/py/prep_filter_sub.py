import os,sys
from locs import *

if len(sys.argv) != 6:
    print
    print "specify..."
    print
    print "NAME  = str(sys.argv[1])"
    print "TYPE  = str(sys.argv[2])"
    print "NACC  = int(sys.argv[3])"
    print "TARGET= str(sys.argv[4])"
    print "LLCUT = str(sys.argv[5])"
    print
    print "...bye"
    print
    sys.exit(1)

NAME   = str(sys.argv[1])
TYPE   = str(sys.argv[2])
NACC   = int(sys.argv[3])
TARGET = str(sys.argv[4])
LLCUT  = str(sys.argv[5])

NAME_DIR  = DATA_DIR_m[NAME]
PY_DIR   = os.path.dirname(os.path.realpath(__file__))
MAC_DIR   = os.path.join(PY_DIR,"..")
OUT_DIR   = os.path.join(PY_DIR,"../..")

def shell(SS):
    print SS
    os.system(SS)

#
# Read how many out files in target directory
#
targ_out_flist_v = [os.path.join(TARGET,f) for f in os.listdir(TARGET) if f.startswith("vertexout_larcv_")]
targ_out_num_v   = [int(os.path.basename(f).split(".")[0].split("_")[-1]) for f in targ_out_flist_v]
#targ_out_num_v, targ_out_flist_v = (list(t) for t in zip(*sorted(zip(targ_out_num_v, targ_out_flist_v))))


#
# Read how many ana files in target directory
#
targ_ana_flist_v = [os.path.join(TARGET,f) for f in os.listdir(TARGET) if f.startswith("vertexana_larcv_")]
targ_ana_num_v   = [int(os.path.basename(f).split(".")[0].split("_")[-1]) for f in targ_ana_flist_v]
#targ_ana_num_v, targ_ana_flist_v = (list(t) for t in zip(*sorted(zip(targ_ana_num_v, targ_ana_flist_v))))


assert len(targ_out_flist_v) == len(targ_ana_flist_v)
assert len(targ_out_num_v)   == len(targ_ana_num_v)

#
# Slice on number of accounts
#
for accid in xrange(NACC):
    
    # set paths
    name_dir_name = "%s_filter_%s_p%02d" % (NAME,TYPE,accid)
    name_dir      = os.path.join(PY_DIR,name_dir_name)

    out_dir       = os.path.join(name_dir,"out")
    work_dir      = os.path.join(name_dir,"work")
    inputlists_dir= os.path.join(work_dir,"inputlists")

    shell("mkdir -p %s" % name_dir)
    shell("mkdir -p %s" % out_dir)
    shell("mkdir -p %s" % work_dir)
    shell("mkdir -p %s" % inputlists_dir)
    


    # slice input files
    start = int(accid*len(targ_out_flist_v) / float(NACC))
    end   = int((accid+1)*len(targ_out_flist_v) / float(NACC))
    
    targ_out_flist_slice = targ_out_flist_v[start:end]
    targ_out_num_slice   = targ_out_num_v[start:end]

    targ_ana_flist_slice = []
    targ_ana_num_slice   = []

    for targ_num,targ_flist in zip(targ_out_num_slice,targ_out_flist_slice):
        idx = targ_ana_num_v.index(targ_num)
        targ_ana_flist_slice.append(targ_ana_flist_v[idx])
        targ_ana_num_slice.append(targ_ana_num_v[idx])

    assert len(targ_out_num_slice)   == len(targ_ana_num_slice)
    assert len(targ_out_flist_slice) == len(targ_ana_flist_slice)

    shell("touch %s" % os.path.join(work_dir,"jobidlist.txt"))    
    
    for targ_ana_num,targ_ana_flist,targ_out_num,targ_out_flist in zip(targ_ana_num_slice,targ_ana_flist_slice,
                                                                       targ_out_num_slice,targ_out_flist_slice):
        
        assert int(targ_ana_num) == int(targ_out_num)
        
        f = open(os.path.join(inputlists_dir,"inputlist_%04d.txt" % int(targ_ana_num)),"w+")
        f.write(targ_ana_flist)
        f.write(" ")
        f.write(targ_out_flist)
        f.close()
        del f
        
        f = open(os.path.join(work_dir,"jobidlist.txt"),"a")
        f.write(str(targ_out_num))
        f.write("\n")
        f.close()
        del f


    shell("scp %s %s" % (os.path.join(work_dir,"jobidlist.txt"),
                         os.path.join(work_dir,"rerunlist.txt")))
    
    # copy & replace templates
    data = ""
    with open(os.path.join(MAC_DIR,"template","run_filter_job_template.sh"),"r") as f:
        data = f.read()
        
    data = data.replace("XXX",LLCUT)
    with open(os.path.join(work_dir,"run_filter_job.sh"),"w+") as f:
        f.write(data)

    data = ""
    with open(os.path.join(MAC_DIR,"template","submit_filter_job.sh"),"r") as f:
        data = f.read()

    data = data.replace("XXX",name_dir_name)
    data = data.replace("YYY",str(len(targ_out_num_slice)))

    with open(os.path.join(MAC_DIR,"submit_%s.sh" % name_dir_name),"w+") as f:
        f.write(data)
        
    shell("rm -rf %s" % os.path.join(OUT_DIR,name_dir_name))
    shell("mv -f %s %s" % (name_dir,OUT_DIR))
