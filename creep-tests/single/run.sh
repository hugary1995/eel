echo "Start: $(date)"
echo "cwd: $(pwd)"

mpirun -n 6 ../../eel-opt -i creep.i

echo "End: $(date)"