
n = 4;

app (void v) task(int i, string message)
{
  "./task.sh" i message;
}

for (int i = 0; i < n; i = i+1)
{
  task(i, "NO_WAIT");
}

// There is a bug in the container reference handling here:
void V[];
V[0] = propagate();
for (int i = 1; i < n; i = i+1)
{
  void w = V[i-1];
  wait (w) { V[i] = task(i, "WAIT"); }
}
