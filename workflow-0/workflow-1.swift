import assert;
import io;
import launch;
import stats;
import string;
import sys;

// Commands and process counts
int procs[] = [12, 3];
string cmds[] = ["/home/tshu/project/Example-Heat_Transfer/heat_transfer_adios2", "/home/tshu/project/Example-Heat_Transfer/stage_write/stage_write"];

// Command line arguments
string a[][];

// mpiexec -n 12 ./heat_transfer_adios2 heat 4 3 40 50 6 500
a[0] = split("heat 4 3 40 50 6 500", " ");
printf("size: %i", size(a[0]));

// mpiexec -n 3 stage_write/stage_write heat.bp staged.bp FLEXPATH "" MPI ""
a[1] = split("heat.bp staged.bp FLEXPATH \"\" MPI \"\"", " ");
printf("size: %i", size(a[1]));

// Environment variables
//string envs[][];

printf("swift: multiple launching: %s, %s", cmds[0], cmds[1]);
exit_code = @par=sum_integer(procs) launch_multi(procs, cmds, a, EMPTY_SS);
printf("swift: received exit code: %d", exit_code);
if (exit_code != 0)
{
    printf("swift: The multi-launched applications did not succeed.");
}

