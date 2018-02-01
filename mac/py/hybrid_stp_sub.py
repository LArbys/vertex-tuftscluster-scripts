import os,sys
from db import *

if len(sys.argv) != 9:
    print
    print "specify..."
    print
    print "NAME      = str(sys.argv[1])"
    print "TYPE      = str(sys.argv[2])"
    print "TRKCFG    = str(sys.argv[3])"
    print "TANACFG   = str(sys.argv[4])"
    print "SANACFG   = str(sys.argv[5])"
    print "RECLUSTER = int(sys.argv[6])"
    print "TARGET    = str(sys.argv[7])"
    print "NACC      = int(sys.argv[8])"
    print
    print "...bye"
    print
    sys.exit(1)

NAME      = str(sys.argv[1])
TYPE      = str(sys.argv[2])
TRKCFG    = str(sys.argv[3])
TANACFG   = str(sys.argv[4])
SANACFG   = str(sys.argv[5])
RECLUSTER = int(sys.argv[6])
TARGET    = str(sys.argv[7])
NACC      = int(sys.argv[8])

PY_DIR     = os.path.dirname(os.path.realpath(__file__))
MAC_DIR    = os.path.join(PY_DIR,"..")
OUT_FOLDER = "%s_stp_%s" % (NAME,TYPE)
OUT_DIR    = os.path.join(PY_DIR,"../..",OUT_FOLDER)

SCRIPT_DIR = os.path.join(MAC_DIR,"submit_stp")

def shell(SS):
    print SS
    os.system(SS)

shell("rm -rf %s" % OUT_DIR)
shell("mkdir -p %s" % OUT_DIR)



#
# Read how many target files there are
#
targ_lc_flist_v = [os.path.join(TARGET,f) for f in os.listdir(TARGET) if f.endswith(".root") if f.startswith("vertexout")]
targ_lc_num_v   = ["%05d" % int(os.path.basename(f).split(".")[0].split("_")[-1]) for f in targ_lc_flist_v]

# Read pickle files
#
targ_comb_pkl_flist_v = [os.path.join(TARGET,f) for f in os.listdir(TARGET) if f.startswith("ana_comb") if f.endswith(".pkl")]
targ_comb_pkl_num_v   = ["%05d" % int(os.path.basename(f).split(".")[0].split("_")[-1]) for f in targ_comb_pkl_flist_v]

lc_to_ll = {}
for num in targ_lc_num_v:
    lc_to_ll[num] = num

#
# stage1
#
ret_v = get_stage1_flist(NAME);

PREFIX = 'ssnetout-larcv'
targ_ss_flist_v = [f[PREFIX] for f in ret_v if f[PREFIX] != ""]
targ_ss_num_v   = ["%05d" % f['jobtag'] for f in ret_v if f[PREFIX] != ""]

PREFIX = 'reco2d'
targ_ll_reco_flist_v   = [f[PREFIX] for f in ret_v if f[PREFIX] != ""]
targ_ll_reco_num_v     = ["%05d" % f['jobtag'] for f in ret_v if f[PREFIX] != ""]

PREFIX = 'mcinfo'
targ_ll_mcinfo_flist_v = [f[PREFIX] for f in ret_v if f[PREFIX] != ""]
targ_ll_mcinfo_num_v   = ["%05d" % f['jobtag'] for f in ret_v if f[PREFIX] != ""]


#
# Slice on number of accounts
#
fout_all = open(os.path.join(MAC_DIR,"submit_all_%s.sh" % (OUT_FOLDER)),"w+")
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

    targ_lc_ss_flist_slice = []
    targ_lc_ss_num_slice   = []

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

        idx = targ_ss_num_v.index(targ_num)

        targ_lc_ss_flist_slice.append(targ_ss_flist_v[idx])
        targ_lc_ss_num_slice.append(targ_ss_num_v[idx])
        
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
                 targ_lc_num_slice,targ_lc_flist_slice,
                 targ_lc_ss_num_slice,targ_lc_ss_flist_slice):

        targ_ll_reco_num   = x[0]
        targ_ll_reco_flist = x[1]

        targ_ll_mcinfo_num   = x[2]
        targ_ll_mcinfo_flist = x[3]

        targ_lc_num   = x[4]
        targ_lc_flist = x[5]

        targ_lc_ss_num = x[6]
        targ_lc_ss_flist = x[7]

        f = open(os.path.join(inputlists_dir,"reco_inputlist_%04d.txt" % int(targ_lc_num)),"w+")
        f.write(targ_lc_ss_flist)
        f.close()
        del f

        f = open(os.path.join(inputlists_dir,"vertex_inputlist_%04d.txt" % int(targ_lc_num)),"w+")
        f.write(targ_lc_flist)
        f.close()
        del f

        f = open(os.path.join(inputlists_dir,"pkl_inputlist_%04d.txt" % int(targ_lc_num)),"w+")
        tidx = targ_comb_pkl_num_v.index(targ_lc_num)
        f.write(targ_comb_pkl_flist_v[tidx])
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
    shell("scp %s %s" % (os.path.join(MAC_DIR,TRKCFG),work_dir))
    shell("scp %s %s" % (os.path.join(MAC_DIR,TANACFG),work_dir))
    shell("scp %s %s" % (os.path.join(MAC_DIR,SANACFG),work_dir))
    
    # copy & replace templates
    data = ""
    with open(os.path.join(MAC_DIR,"template","run_stp_job_template.sh"),"r") as f:
        data = f.read()

    data = data.replace("YYY",os.path.basename(TRKCFG))
    data = data.replace("ZZZ",os.path.basename(TANACFG))
    data = data.replace("RRR",os.path.basename(SANACFG))
    data = data.replace("AAA",str(RECLUSTER))

    with open(os.path.join(work_dir,"run_stp_job.sh"),"w+") as f:
        f.write(data)

    data = ""
    with open(os.path.join(MAC_DIR,"template","submit_stp_job.sh"),"r") as f:
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
    
