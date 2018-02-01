import sys, os

if len(sys.argv) != 3:
    print
    print "specify..."
    print
    print "FOLDER    = str(sys.argv[1])"
    print "OVERWRITE = bool(sys.argv[2])"
    print
    print "...bye"
    print
    sys.exit(1)

FOLDER    = str(sys.argv[1])
if FOLDER[-1]=="/": FOLDER = FOLDER[:-1]
FOLDER = os.path.basename(FOLDER)
OVERWRITE = bool(sys.argv[2])

PY_DIR    = os.path.dirname(os.path.realpath(__file__))
MAC_DIR   = os.path.join(PY_DIR,"..")
OUT_DIR   = os.path.join(PY_DIR,"../..")

FOLDER_BASE_DIR=os.path.join(OUT_DIR,FOLDER)
FOLDER_OUT_DIR=os.path.join(FOLDER_BASE_DIR,"links")

print
print "FOLDER=",FOLDER
print "FOLDER_BASE_DIR=",FOLDER_BASE_DIR
print


if OVERWRITE==True:
    print "OVERWRITE!"
    SS = "rm -rf %s" % FOLDER_OUT_DIR
    print SS
    os.system(SS)

SS="mkdir -p %s" % FOLDER_OUT_DIR
print SS
os.system(SS)

print
dir_v = [os.path.join(FOLDER_BASE_DIR,f) for f in os.listdir(FOLDER_BASE_DIR) if f.startswith(FOLDER + "_p")]
print dir_v
for dd in dir_v:
    print "@dir=",os.path.basename(dd)
    SS = "ln -s %s %s" % (os.path.join(str(dd),"out","*"),os.path.join(FOLDER_BASE_DIR,"links"))
    print SS
    os.system(SS)
    print "... %d files linked ..." % len(os.listdir(os.path.join(dd,"out")))
    print




