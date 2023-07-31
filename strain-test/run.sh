echo "Start: $(date)"
echo "cwd: $(pwd)"

mpirun -n 6 ../eel-opt -i debug.i

echo "End: $(date)"
