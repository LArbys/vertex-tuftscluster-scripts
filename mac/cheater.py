import os,sys,time
import subprocess

def exec_system(input_):
    return subprocess.Popen(input_,stdout=subprocess.PIPE).communicate()[0].split("\n")[:-1]

def njobs():
    return int(len(exec_system(["squeue","-u","vgenty01"])) - 1)

SUBMIT = str(sys.argv[1])
files_v = [os.path.join(SUBMIT,f) for f in os.listdir(SUBMIT) if f.endswith(".sh")]

while 1:
    if njobs() < 50:
        script = files_v.pop()
        SS = "./%s 1>/dev/null 2>/dev/null &" % script
        print SS
        os.system(SS)
    else:
        time.sleep(1)
        print "Sleep"
    if len(files_v) == 0: break

sys.exit(0)
