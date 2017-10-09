import os,sys

PWD = sys.argv[1]


PY_DIR   = os.path.dirname(os.path.realpath(__file__))
MAC_DIR   = os.path.join(PY_DIR,"..")
OUT_DIR   = os.path.join(PY_DIR,"../..")

def shell(SS):
    print SS
    os.system(SS)

TEMPLATE_DIR      = os.path.join(MAC_DIR,"template")
TEMPLATE_BASE_DIR = os.path.join(TEMPLATE_DIR,"base")


for type_ in ['reco','reana','cheater','filter','shower']:
    
    print "@type=",type_
    data = ""
    with open(os.path.join(TEMPLATE_BASE_DIR,"submit_job.sh"),"r") as f:
        data = f.read()
        
    data = data.replace("ZZZ",type_)

    #folder = os.path.basename(PWD)
    folder = str(PWD)
    data = data.replace("AAA",folder)

    img = [f for f in os.listdir(os.path.join(PWD,"image")) if f.endswith(".img")]
    img = img[0]
    data = data.replace("BBB",img)
        
    with open(os.path.join(TEMPLATE_DIR,"submit_%s_job.sh" % type_),"w+") as f:
        f.write(data)

    shell("scp %s %s" % (os.path.join(TEMPLATE_BASE_DIR,"run_%s_job_template.sh" % type_),
                                      os.path.join(TEMPLATE_DIR,"run_%s_job_template.sh" % type_)))
    print
