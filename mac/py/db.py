import sys, os
import psycopg2


PUB_PSQL_ADMIN_HOST="nudot.lns.mit.edu"
PUB_PSQL_ADMIN_USER="tufts-pubs"
PUB_PSQL_ADMIN_ROLE=""
PUB_PSQL_ADMIN_DB="procdb"
PUB_PSQL_ADMIN_PASS=""
PUB_PSQL_ADMIN_CONN_NTRY="10"
PUB_PSQL_ADMIN_CONN_SLEEP="10"

PARAMS = {
  'dbname': PUB_PSQL_ADMIN_DB,
  'user': PUB_PSQL_ADMIN_USER,
  'password': PUB_PSQL_ADMIN_PASS,
  'host': PUB_PSQL_ADMIN_HOST
  }

print PARAMS
CONN = psycopg2.connect(**PARAMS)
CUR = CONN.cursor()                             

def cast_run_subrun(run,subrun,input_dir):


    runmod100    = run%100
    rundiv100    = run/100
    subrunmod100 = subrun%100
    subrundiv100 = subrun/100
    
    jobtag      = 10000*run + subrun
    inputdbdir  = os.path.join(input_dir,"%03d/%02d/%03d/%02d/"%(rundiv100,runmod100,subrundiv100,subrunmod100))

    return jobtag, inputdbdir

def get_stage1_flist(project,IS_MC):

    res_v = []
    

    input_format = "%s-Run%06d-SubRun%06d.root"

    if IS_MC == 0:
        input_dir = "/cluster/kappa/90-days-archive/wongjiradlab/larbys/data/db/%s/stage1/"
    else:
        input_dir = "/cluster/kappa/90-days-archive/wongjiradlab/larbys/data/db/%s/"

    input_dir = input_dir % project

    SS = '''SELECT runnumber,subrunnumber FROM %s;'''
    SS = SS % project
    print SS
    CUR.execute(SS)
    print "Fetching..."
    rse_v =  CUR.fetchall()
    print "...fetched"
    print "Exist (%d)..." % len(rse_v)
    for ix,rs in enumerate(rse_v):
        SS = "%0.1f\r" % (float(ix) / float(len(rse_v)) * float(100.0))
        print SS,
        sys.stdout.flush()


        run    = rs[0]
        subrun = rs[1]

        jobtag, inputdir = cast_run_subrun(rs[0],rs[1],input_dir)

        res = {}
        res = { 'reco2d' : os.path.join(inputdir,input_format%("reco2d",run,subrun)),
                'mcinfo' : os.path.join(inputdir,input_format%("mcinfo",run,subrun)),
                'opreco' : os.path.join(inputdir,input_format%("opreco",run,subrun)),
                'ssnetout-larcv' : os.path.join(inputdir,input_format%("ssnetout-larcv",run,subrun)),
                'run' : run,
                'subrun' : subrun,
                'jobtag' : jobtag
            }
        
        # for key in res:
        #     if key == 'run': continue
        #     if key == 'subrun': continue
        #     if key == 'jobtag' : continue
        #     if os.path.exists(res[key])==False:
        #         res[key] = ""

        res_v.append(res)
        res = {}

    print "...exists"
    return res_v

def get_stage2_flist(project,tag):

    res_v = []

    input_format = "%s_%05d%s"

    input_dir = "/cluster/kappa/90-days-archive/wongjiradlab/larbys/data/db/%s/stage2/%s/"
    input_dir = input_dir % (project,tag)

    SS = '''SELECT runnumber,subrunnumber FROM %s;'''
    SS = SS % project
    print SS
    CUR.execute(SS)
    print "Fetching..."
    rse_v =  CUR.fetchall()
    print "...fetched"
    print "Exist (%d)..." % len(rse_v)
    for ix,rs in enumerate(rse_v):
        SS = "%0.1f\r" % (float(ix) / float(len(rse_v)) * float(100.0))
        print SS,
        sys.stdout.flush()


        run    = rs[0]
        subrun = rs[1]

        jobtag, inputdir = cast_run_subrun(rs[0],rs[1],input_dir)
        

        res = {}
        res = { 
             "ana_comb_df": os.path.join(inputdir,input_format%("ana_comb_df",jobtag,".pkl")),
             "ana_truth_df": os.path.join(inputdir,input_format%("ana_truth_df",jobtag,".pkl")),
             "ana_vertex_df": os.path.join(inputdir,input_format%("ana_vertex_df",jobtag,".pkl")),
             "dllee_analysis": os.path.join(inputdir,input_format%("dllee_analysis",jobtag,".root")),
             "FinalVertexVariables": os.path.join(inputdir,input_format%("FinalVertexVariables",jobtag,".root")),
             "intermediate_file": os.path.join(inputdir,input_format%("intermediate_file",jobtag,".root")),
             "lcv_trash": os.path.join(inputdir,input_format%("lcv_trash",jobtag,".root")),
             "LL_comb_df": os.path.join(inputdir,input_format%("LL_comb_df",jobtag,".pkl")),
             "multipid_out": os.path.join(inputdir,input_format%("multipid_out",jobtag,".root")),
             "rst_comb_df": os.path.join(inputdir,input_format%("rst_comb_df",jobtag,".pkl")),
             "rst_LL_comb_df": os.path.join(inputdir,input_format%("rst_LL_comb_df",jobtag,".pkl")),
             "rst_numu_comb_df": os.path.join(inputdir,input_format%("rst_numu_comb_df",jobtag,".pkl")),
             "showerqualsingle": os.path.join(inputdir,input_format%("showerqualsingle",jobtag,".root")),
             "shower_reco_out": os.path.join(inputdir,input_format%("shower_reco_out",jobtag,".root")),
             "shower_truth_match": os.path.join(inputdir,input_format%("shower_truth_match",jobtag,".root")),
             "stp_comb_df": os.path.join(inputdir,input_format%("stp_comb_df",jobtag,".pkl")),
             "tracker_anaout": os.path.join(inputdir,input_format%("tracker_anaout",jobtag,".root")),
             "tracker_reco": os.path.join(inputdir,input_format%("tracker_reco",jobtag,".root")),
             "track_pgraph_match": os.path.join(inputdir,input_format%("track_pgraph_match",jobtag,".root")),
             "trackqualsingle": os.path.join(inputdir,input_format%("trackqualsingle",jobtag,".root")),
             "track_truth_match": os.path.join(inputdir,input_format%("track_truth_match",jobtag,".root")),
             "vertexana": os.path.join(inputdir,input_format%("vertexana",jobtag,".root")),
             "vertexana_filter_nue_ana_tree": os.path.join(inputdir,input_format%("vertexana_filter_nue_ana_tree",jobtag,".root")),
             "vertexana_filter_numu_ana_tree": os.path.join(inputdir,input_format%("vertexana_filter_numu_ana_tree",jobtag,".root")),
             "vertexout": os.path.join(inputdir,input_format%("vertexout",jobtag,".root")),
             "vertexout_filter_nue_ana_tree": os.path.join(inputdir,input_format%("vertexout_filter_nue_ana_tree",jobtag,".root")),
             "vertexout_filter_numu_ana_tree": os.path.join(inputdir,input_format%("vertexout_filter_numu_ana_tree",jobtag,".root")),
             "run" : run,
             "subrun" : subrun,
             "jobtag" : jobtag
             }
        
        # for key in res:
        #     if key == 'run': continue
        #     if key == 'subrun': continue
        #     if key == 'jobtag' : continue
        #     if os.path.exists(res[key])==False:
        #         res[key] = ""

        res_v.append(res)
        res = {}

    print "...exists"
    return res_v

