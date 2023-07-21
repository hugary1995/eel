echo "Start: $(date)"
echo "cwd: $(pwd)"

# mpirun -n 6 ../eel-opt -i creep.i  --mesh-only --color off
mpirun -n 6 ../eel-opt -i creep.i  --color off

echo "End: $(date)"
