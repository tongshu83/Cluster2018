
/*
  WORKFLOW.SWIFT
*/

import files;
import string;
import sys;
import io;
import stats;
import math;
import location;
import assert;
import json;
import launch;

import R;

import EQR;

string emews_root = getenv("EMEWS_PROJECT_ROOT");
//string turbine_output = getenv("TURBINE_OUTPUT");
string resident_work_ranks = getenv("RESIDENT_WORK_RANKS");
string r_ranks[] = split(resident_work_ranks,",");
int propose_points = toint(argv("pp", "3"));
int max_budget = toint(argv("mb", "110"));
int max_iterations = toint(argv("it", "10"));
int design_size = toint(argv("ds", "10"));
string param_set = argv("param_set_file");
string model_name = argv("model_name");
string exp_id = argv("exp_id");
int benchmark_timeout = toint(argv("benchmark_timeout", "-1"));
string obj_param = argv("obj_param", "val_loss");
string site = argv("site");

// Call to objective function: the NN model,
//  then get results from output file
(string result) obj(string params, string run_id)
{
    string turbine_output = getenv("TURBINE_OUTPUT");

    string outdir = "%s/run/%s" % (turbine_output, run_id);
    printf("running model shell script in: %s", outdir);
    string result_file = outdir/"result.txt";

    ht_procs = json_get(params, "ht_procs");
    sw_procs = json_get(params, "sw_procs");
    int procs[] = [string2int(ht_procs), string2int(sw_procs)];

    string ht_path = "/home/tshu/project/Example-Heat_Transfer/heat_transfer_adios2";
    string sw_path = "/home/tshu/project/Example-Heat_Transfer/stage_write/stage_write";
    string cmds[] = [ht_path, sw_path];

    string args[][];
    int htproc_x = 4;
    int htproc_y = 3;
    string rmethod = "DATASPACES";
    args[0] = split("heat  %d %d 40 50  6 500 %s" % (htproc_x, htproc_y, result_file), " ");
    args[1] = split("heat.bp staged.bp %s \"\" MPI \"\"" % rmethod , " ");
    printf("size: %i", size(args[1]));

    string envs[][];

    envs[0] = [ "swift_chdir=/tmp"/run_id ];
    envs[1] = [ "swift_chdir=/tmp"/run_id ];

    // Something like MPIX_Launch_Swift/apps/multi-1/workflow-1.swift
    printf("swift: multiple launching: %s, %s", cmds[0], cmds[1]);
    exit_code = @par=sum_integer(procs) launch_multi(procs, cmds, args, envs);
    printf("swift: received exit code: %d", exit_code);
    if (exit_code != 0)
    {
        printf("swift: The multi-launched applications did not succeed.");
    }

//    wait (run_model(ht_procs+" "+sw_procs, run_id))
//    {
//        result = get_results(result_file);
//    }

    wait(exit_code) {
      // eresult = get_results(result_file) ;
      result = ht_procs + sw_procs;
    }

    printf("result(%s): %s", run_id, result);
}

// Run a shell script
app (void o) run_model (string params,
        string run_id)
{
    //                    1         2
    "bash" "fake-fob.sh" params run_id;
}

// Get the results from a NN run
(string obj_result) get_results(string result_file)
{
    if (file_exists(result_file))
    {
        file line = input(result_file);
        obj_result = trim(read(line));
    }
    else
    {
        printf("File not found: %s", result_file);
        obj_result = "NaN";
    }
}

(void v) loop(location ME, int ME_rank)
{
    for (boolean b = true, int i = 1;
            b;
            b=c, i = i + 1)
    {
        string params =  EQR_get(ME);
        printf("params: %s", params);
        boolean c;

        if (params == "DONE")
        {
            // We are done: store the final results
//            string finals =  EQR_get(ME);
            string turbine_output = getenv("TURBINE_OUTPUT");
            string fname = "%s/final_res.Rds" % (turbine_output);
            printf("See results in %s", fname) =>
                // printf("Results: %s", finals) =>
                v = make_void() =>
                c = false;
        }
        else if (params == "EQR_ABORT")
        {
            printf("EQR aborted: see output for R error") =>
                string why = EQR_get(ME);
            printf("%s", why) =>
                v = propagate() =>
                c = false;
        }
        else
        {
            string param_array[] = split(params, ";");
            string result[];
            foreach p, j in param_array
            {
                result[j] = obj(p, "%000i_%0000i" % (i,j));
            }
            string results = join(result, ";");
            printf("results: %s", results);
            EQR_put(ME, results) => c = true;
        }
    }
}

// These must agree with the arguments to the objective function in mlrMBO3.R,
// except param.set.file is removed and processed by the mlrMBO.R algorithm wrapper.
string algo_params_template =
"""
param.set.file='%s',
    max.budget = %d,
    max.iterations = %d,
    design.size=%d,
    propose.points=%d
    """;

    (void o) start(int ME_rank) {
        location ME = locationFromRank(ME_rank);

        // algo_params is the string of parameters used to initialize the
        // R algorithm. We pass these as R code: a comma separated string
        // of variable=value assignments.
        string algo_params = algo_params_template %
            (param_set, max_budget, max_iterations,
             design_size, propose_points);
        string algorithm = emews_root/"mlrMBO3.R";
        EQR_init_script(ME, algorithm) =>
            EQR_get(ME) =>
            EQR_put(ME, algo_params) =>
            loop(ME, ME_rank) => {
                EQR_stop(ME) =>
                    EQR_delete_R(ME);
                o = propagate();
            }
    }

main() {

    assert(strlen(emews_root) > 0, "Set EMEWS_PROJECT_ROOT!");

    int ME_ranks[];
    foreach r_rank, i in r_ranks{
        ME_ranks[i] = toint(r_rank);
    }

    foreach ME_rank, i in ME_ranks {
        start(ME_rank) =>
            printf("End rank: %d", ME_rank);
    }
}

// Local Variables:
// c-basic-offset: 2
// End:
