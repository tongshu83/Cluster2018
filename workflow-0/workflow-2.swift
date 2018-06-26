
/*
   WORKFLOW.SWIFT
 */

import assert;
import files;
import io;
import json;
import launch;
import location;
import math;
import stats;
import string;
import sys;

string emews_root = getenv("EMEWS_PROJECT_ROOT");
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

(void v) setup_run(string dir) "turbine" "0.0"
[
    """
    file mkdir <<dir>>
    file copy heat_transfer.xml <<dir>>
    """
];

(string result) obj(string params, string run_id)
{
    string turbine_output = getenv("TURBINE_OUTPUT");

    string outdir = "%s/run/%s" % (turbine_output, run_id);
    printf("running obj() in: %s", outdir);
    string ht_result_file = outdir/"time_heat_transfer_adios2.txt";
    string sw_result_file = outdir/"time_stage_write.txt";
    string result_files[] = [ ht_result_file, sw_result_file];

    ht_procs_x = string2int(json_get(params, "ht_procs_x"));
    ht_procs_y = string2int(json_get(params, "ht_procs_y"));
    sw_procs   = string2int(json_get(params, "sw_procs"));
    int procs[] = [ ht_procs_x * ht_procs_y, sw_procs ];

    string ht_path = "/home/tshu/project/Example-Heat_Transfer/heat_transfer_adios2.sh";
    string sw_path = "/home/tshu/project/Example-Heat_Transfer/stage_write.sh";
    string cmds[] = [ht_path, sw_path];

    string args[][];
    string rmethod = "FLEXPATH";
    args[0] = split("heat  %d %d 40 50 6 5 " % (ht_procs_x, ht_procs_y), " ");
    args[1] = split("heat.bp staged.bp %s \"\" MPI \"\"" % rmethod , " ");

    string envs[][];
    envs[0] = [ "swift_chdir="+outdir ];
    envs[1] = [ "swift_chdir="+outdir ];

    printf("swift: multiple launching: %s, %s", cmds[0], cmds[1]);
    setup_run(outdir) =>
        exit_code = @par=sum_integer(procs) launch_multi(procs, cmds, args, envs);
    printf("swift: received exit code: %d", exit_code);
    if (exit_code != 0)
    {
        printf("swift: The multi-launched applications did not succeed.");
    }

    wait(exit_code) {
        result = get_results(result_files);
    }

    printf("result(%s): %s", run_id, result);
}

(string obj_result) get_results(string result_files[])
{
    string obj_results[];
    foreach result_file, i in result_files
    {
        if (file_exists(result_file))
        {
            file line = input(result_file);
            string result = trim(read(line));
            string exec_time[] = split(result, ":");
            int size = 1 + string_count(result, ":", 0, length(result) - 1);
            float sum;
            for (int j = 0, sum = 0; 
                    j < size; 
                    j = j + 1, sum = sum * 60 + val)
            {
                float val = string2float(exec_time[j]);
            }
            obj_results[i] = float2string(sum);
            printf("obj_results[%i] = %s\n", i, obj_results[i]);
        }
        else
        {
            printf("File not found: %s", result_file);
            obj_results[i] = "NaN";
            printf("obj_results[%i] = %s\n", i, obj_results[i]);
        }
    }
    obj_result = get_max(obj_results);
}

// Get the max value 
(string max) get_max(string values[])
{
    string array = trim(join(values));
    int size = 1 + string_count(array, " ", 0, length(array) - 1);
    int count;
    for (int i = 0, count = 0;
            i < size;
            i = i + 1, count = count + tag)
    {
        int tag;
        if (values[i] == "NaN")
        {
            tag = 1;
        }
        else
        {
            tag = 0;
        }
    }
    if (count == 0)
    {
        float nums[];
        foreach value, j in values
        {
            nums[j] = string2float(value);
        }
        float max_num;
        for (int k = 0, max_num = 0.0; 
                k < size; 
                k = k + 1, max_num = max_float(max_num, nums[k]))
        {
        }
        max = float2string(max_num);
    }
    else
    {
        max = "NaN";
    }
}

(string param_array[]) get_param_array()
{
    foreach ht_procs_x in [1:4]
    {
        foreach ht_procs_y in [1:4]
        {
            foreach sw_procs in [1:16]
            {
                int i = (ht_procs_x - 1) * 4 * 16 + (ht_procs_y - 1) * 16 + sw_procs - 1;
                param_array[i] = "{\"ht_procs_x\":%i,\"ht_procs_y\":%i,\"sw_procs\":%i}" % (ht_procs_x, ht_procs_y, sw_procs);
            }
        }
    }
}

main()
{
    string param_array[] = get_param_array();
    string result[];
    foreach p, j in param_array
    {
        printf("p = %s", p);
        // result[j] = obj(p, "%000i_%0000i" % (i, j));
    }
    string results = join(result, ";");
}

