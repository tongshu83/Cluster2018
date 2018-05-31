
/* Other launch_multi() examples are here:
  git@bitbucket.org:jmjwozniak/mpix_launch_swift.git apps/multi-1/
*/

import launch;

/*
string a[] = [];
launch("heat_transfer", a);
*/

int procs[] = [ 4, 2];
string commands[] = ["heat_transfer", "stage_write" ];
string a[][];
a[0] = ["hello.txt", "hello1", "hello2"];
a[1] = ["bye.txt",   "bye1", "bye2", "bye3"];

launch_multi(procs, commands, args, EMPTY_SS);
