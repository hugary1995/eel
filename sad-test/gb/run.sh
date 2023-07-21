echo "Start: $(date)"
echo "cwd: $(pwd)"

mpirun -n 6 ../../eel-opt -i creep-update2d.i --color off

echo "End: $(date)"
