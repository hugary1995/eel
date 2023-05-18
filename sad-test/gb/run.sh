echo "Start: $(date)"
echo "cwd: $(pwd)"

mpirun -n 2 ../../eel-opt -i creep.i --color off

echo "End: $(date)"