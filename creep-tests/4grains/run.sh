echo "Start: $(date)"
echo "cwd: $(pwd)"

mpirun -n 6 ../../eel-opt -i creep-poly.i

echo "End: $(date)"