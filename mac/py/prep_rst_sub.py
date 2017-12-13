import os,sys
from locs import *

if len(sys.argv) != 8:
    print
    print "specify..."
    print
    print "NAME    = str(sys.argv[1])"
    print "TYPE    = str(sys.argv[2])"
    print "RECOCFG = str(sys.argv[3])"
    print "TRKCFG  = str(sys.argv[4])"
    print "TANACFG = str(sys.argv[5])"
    print "SANACFG = str(sys.argv[6])"
    print "NACC    = int(sys.argv[7])"
    print
    print "...bye"
    print
    sys.exit(1)

NAME    = str(sys.argv[1])
TYPE    = str(sys.argv[2])
RECOCFG = str(sys.argv[3])
TRKCFG  = str(sys.argv[4])
TANACFG = str(sys.argv[5])
SANACFG = str(sys.argv[6])
NACC    = int(sys.argv[7])

NAME_DIR  = DATA_DIR_m[NAME]
LL_DIR    = LL_DIR_m[NAME]

PY_DIR    = os.path.dirname(os.path.realpath(__file__))
MAC_DIR   = os.path.join(PY_DIR,"..")
OUT_DIR   = os.path.join(PY_DIR,"../..")

def shell(SS):
    print SS
    os.system(SS)

#
# Read how many ssnet files in directory
#
targ_lc_flist_v = [os.path.join(NAME_DIR,f) for f in os.listdir(NAME_DIR) if f.endswith(".root")]
targ_lc_num_v   = [int(os.path.basename(f).split(".")[0].split("_")[-1]) for f in targ_lc_flist_v]

#
# Read how many ll file
#

data = ""
with open(os.path.join(LL_DIR_m[NAME],"..","correlated.txt"),"r") as f:
    data = f.read()
data = data.split("\n")
data = data[:-1]
lc_to_ll = {}
for d in data: 
    lcnum = int(float(d.split(",")[0]))
    llnum = int(float(d.split(",")[1]))
    lc_to_ll[lcnum] = llnum

targ_ll_reco_flist_v   = [os.path.join(LL_DIR_m[NAME],f) for f in os.listdir(LL_DIR_m[NAME]) if f.startswith("larlite_reco2d")]
targ_ll_mcinfo_flist_v = [os.path.join(LL_DIR_m[NAME],f) for f in os.listdir(LL_DIR_m[NAME]) if f.startswith("larlite_mcinfo")]

targ_ll_reco_num_v     = [int(os.path.basename(f).split(".")[0].split("_")[-1]) for f in targ_ll_reco_flist_v]
targ_ll_mcinfo_num_v   = [int(os.path.basename(f).split(".")[0].split("_")[-1]) for f in targ_ll_mcinfo_flist_v]

#
# Slice on number of accounts
#
fout_all = open(os.path.join(MAC_DIR,"submit_all_%s_rst_%s.sh" % (NAME,TYPE)),"w+")
for accid in xrange(NACC):
    
    # set paths
    name_dir_name = "%s_rst_%s_p%02d" % (NAME,TYPE,accid)
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

    targ_ll_reco_flist_slice = []
    targ_ll_reco_num_slice   = []

    targ_ll_mcinfo_flist_slice = []
    targ_ll_mcinfo_num_slice   = []


    for targ_num,targ_flist in zip(targ_lc_num_slice_tmp,
                                   targ_lc_flist_slice_tmp):


        try: 
            value = lc_to_ll[targ_num]
        except KeyError:
            print "@targ_num=",targ_num
            print "... doesn't exist in larlite"
            continue

        targ_lc_flist_slice.append(targ_flist)
        targ_lc_num_slice.append(targ_num)
        
        idx0 = targ_ll_reco_num_v.index(lc_to_ll[targ_num])

        targ_ll_reco_flist_slice.append(targ_ll_reco_flist_v[idx0])
        targ_ll_reco_num_slice.append(targ_ll_reco_num_v[idx0])

        if targ_ll_mcinfo_flist_v and targ_ll_mcinfo_num_v:
            idx1 = targ_ll_mcinfo_num_v.index(lc_to_ll[targ_num])
            targ_ll_mcinfo_flist_slice.append(targ_ll_mcinfo_flist_v[idx1])
            targ_ll_mcinfo_num_slice.append(targ_ll_mcinfo_num_v[idx1])
        else:
            targ_ll_mcinfo_flist_slice.append("INVALID")
            targ_ll_mcinfo_num_slice.append(-1)


    num_slice = len(targ_ll_reco_num_slice)

    for x in zip(targ_ll_reco_num_slice,targ_ll_reco_flist_slice,
                 targ_ll_mcinfo_num_slice,targ_ll_mcinfo_flist_slice,
                 targ_lc_num_slice,targ_lc_flist_slice):

        targ_ll_reco_num   = x[0]
        targ_ll_reco_flist = x[1]

        targ_ll_mcinfo_num   = x[2]
        targ_ll_mcinfo_flist = x[3]

        targ_lc_num   = x[4]
        targ_lc_flist = x[5]

        f = open(os.path.join(inputlists_dir,"reco_inputlist_%04d.txt" % int(targ_lc_num)),"w+")
        f.write(targ_lc_flist)
        f.close()
        del f

        f = open(os.path.join(inputlists_dir,"ll_inputlist_%04d.txt" % int(targ_lc_num)),"w+")
        f.write(targ_ll_reco_flist)
        f.write(" ")
        f.write(targ_ll_mcinfo_flist)
        f.close()
        del f
        
        f = open(os.path.join(work_dir,"jobidlist.txt"),"a")
        f.write(str(targ_lc_num))
        f.write("\n")
        f.close()
        del f


    shell("scp %s %s" % (os.path.join(work_dir,"jobidlist.txt"),
                         os.path.join(work_dir,"rerunlist.txt")))
    shell("scp %s %s" % (os.path.join(MAC_DIR,RECOCFG),work_dir))
    shell("scp %s %s" % (os.path.join(MAC_DIR,TRKCFG),work_dir))
    shell("scp %s %s" % (os.path.join(MAC_DIR,TANACFG),work_dir))
    shell("scp %s %s" % (os.path.join(MAC_DIR,SANACFG),work_dir))
    
    # copy & replace templates
    data = ""
    with open(os.path.join(MAC_DIR,"template","run_rst_job_template.sh"),"r") as f:
        data = f.read()

    data = data.replace("XXX",os.path.basename(RECOCFG))
    data = data.replace("YYY",os.path.basename(TRKCFG))
    data = data.replace("ZZZ",os.path.basename(TANACFG))
    data = data.replace("RRR",os.path.basename(SANACFG))

    with open(os.path.join(work_dir,"run_rst_job.sh"),"w+") as f:
        f.write(data)

    data = ""
    with open(os.path.join(MAC_DIR,"template","submit_rst_job.sh"),"r") as f:
        data = f.read()

    data = data.replace("XXX",name_dir_name)
    data = data.replace("YYY",str(int(num_slice)))

    with open(os.path.join(MAC_DIR,"submit_%s.sh" % name_dir_name),"w+") as f:
        f.write(data)
        
    shell("rm -rf %s" % os.path.join(OUT_DIR,name_dir_name))
    shell("mv -f %s %s" % (name_dir,OUT_DIR))
    fout_all.write("sbatch " + "submit_%s.sh\n" % name_dir_name)
    break

fout_all.close()
    
