import os,sys
from locs import *

NAME  = str(sys.argv[1])
CFG   = str(sys.argv[2])
NACC  = int(sys.argv[3])

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
num_v   = [os.path.basename(f).split(".")[0].split("_")[-1] for f in flist_v]

#
# Slice on number of accounts
#
for accid in xrange(NACC):
    
    # set paths
    name_dir_name = "%s_cheater_p%02d" % (NAME,accid)
    name_dir      = os.path.join(MAC_DIR,name_dir_name)

    out_dir       = os.path.join(name_dir,"out")
    work_dir      = os.path.join(name_dir,"work")
    inputlists_dir= os.path.join(work_dir,"inputlists")

    shell("mkdir -p %s" % name_dir)
    shell("mkdir -p %s" % out_dir)
    shell("mkdir -p %s" % work_dir)
    shell("mkdir -p %s" % inputlists_dir)
    
    # slice input files
    start = int(accid*len(flist_v) / float(NACC))
    end   = int((accid+1)*len(flist_v) / float(NACC))

    flist_slice = flist_v[start:end]
    num_slice   = num_v[start:end]
    assert len(num_slice) == len(flist_slice)

    shell("touch %s" % os.path.join(work_dir,"jobidlist.txt"))    
    
    for num,flist in zip(num_slice,flist_slice):
        f = open(os.path.join(inputlists_dir,"inputlist_%04d.txt" % int(num)),"w+")
        f.write(flist)
        f.close()
        del f
        
        f = open(os.path.join(work_dir,"jobidlist.txt"),"a")
        f.write(str(num))
        f.write("\n")
        f.close()
        del f


    shell("scp %s %s" % (os.path.join(work_dir,"jobidlist.txt"),
                         os.path.join(work_dir,"rerunlist.txt")))
    shell("scp %s %s" % (os.path.join(MAC_DIR,CFG),work_dir))
    shell("scp %s %s" % (os.path.join(PY_DIR,"run_cheater.py"),work_dir))
    
    # copy & replace templates

    data = ""
    with open(os.path.join(MAC_DIR,"template","run_cheater_job_template.sh"),"r") as f:
        data = f.read()
    data = data.replace("XXX",CFG)
    with open(os.path.join(work_dir,"run_cheater_job.sh"),"w+") as f:
        f.write(data)

    data = ""
    with open(os.path.join(MAC_DIR,"template","submit_cheater_job.sh"),"r") as f:
        data = f.read()

    data = data.replace("XXX",name_dir_name)
    data = data.replace("YYY",str(len(num_slice)))

    with open(os.path.join(MAC_DIR,"submit_%s.sh" % name_dir_name),"w+") as f:
        f.write(data)
        
    shell("rm -rf %s" % os.path.join(OUT_DIR,name_dir_name))
    shell("mv -f %s %s" % (name_dir,OUT_DIR))
    
    
