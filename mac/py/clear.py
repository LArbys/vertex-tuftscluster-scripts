import os,sys

PY_DIR   = os.path.dirname(os.path.realpath(__file__))
MAC_DIR   = os.path.join(PY_DIR,"..")
OUT_DIR   = os.path.join(PY_DIR,"../..")

def shell(SS):
    print SS
    os.system(SS)

shell("rm -rf %s" % os.path.join(MAC_DIR,"*.sh"))
shell("rm -rf %s" % os.path.join(MAC_DIR,"log","*.txt"))
