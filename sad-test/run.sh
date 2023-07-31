echo "Start: $(date)"
echo "cwd: $(pwd)"

mpirun -n 6 ../eel-opt -i gb-creep.i

echo "End: $(date)"
