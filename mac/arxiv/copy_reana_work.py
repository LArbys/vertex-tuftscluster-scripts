import os,sys

loc = str(sys.argv[1])
CFG = str(sys.argv[2])
DIR = str(sys.argv[3])
THIS_DIR=os.path.dirname(os.path.realpath(__file__))

SS = "scp run_reana_job.sh %s/../%s/work" % (THIS_DIR,loc)
print SS
os.system(SS)

SS = "scp %s %s/../%s/work" % (CFG,THIS_DIR,loc)
print SS
os.system(SS)

os.chdir("%s/../%s/work"%(THIS_DIR,loc))

print DIR
vertex_v = [f for f in os.listdir(DIR) if f.startswith("vertexout_larcv_")]
num_v = [vana.split(".")[0].split("_")[-1] for vana in vertex_v]

os.system("rm jobidlist.txt")
os.system("touch jobidlist.txt")

for num in num_v:
    fname = "inputlists/inputlist_%s.txt" % num
    data = ""
    with open(fname,'r') as file_:
        data = file_.read().rstrip()
        
    data += " "
    data += os.path.join(DIR,"vertexout_larcv_%s.root" % num)
    os.system("rm %s" %fname)
    with open(fname,'w+') as file_:
        file_.write(data)

    with open("jobidlist.txt",'a') as file_:
        file_.write(num)
        file_.write("\n")
        
os.chdir(THIS_DIR)

SS = "scp %s/../%s/work/jobidlist.txt %s/../%s/work/rerunlist.txt" % (THIS_DIR,loc,THIS_DIR,loc)
print SS
os.system(SS)

SS = "scp run_reana.py %s/../%s/work/" % (THIS_DIR,loc)
print SS
os.system(SS)
