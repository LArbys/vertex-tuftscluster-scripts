import os,sys

CFG=str(sys.argv[1])

for loc in [
    # "bnbdata_5e19_p00",
    # "bnbdata_5e19_p01",
    # "bnbdata_5e19_p02",
    # "bnbdata_5e19_p03",
    # "bnbdata_5e19_p04",
    # "bnbdata_5e19_p05"
    "1e1p",
    #"1e1p_small",
    #"1mu1p",
    "extbnb"
    #"inclusive_muon",
    #"inclusive_elec",
    #"ncpizero",
    #"corsika"
    ]:

    SS = "scp run_job.sh ../%s/work" % loc
    print SS
    os.system(SS)

    SS = "scp %s ../%s/work" % (CFG,loc)
    print SS
    os.system(SS)

    SS = "scp ../%s/work/jobidlist.txt ../%s/work/rerunlist.txt" % (loc,loc)
    print SS
    os.system(SS)

    SS = "scp run.py ../%s/work/" % loc
    print SS
    os.system(SS)
