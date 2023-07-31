echo "Start: $(date)"
echo "cwd: $(pwd)"

# mpirun -n 6 ../eel-opt -i gary.i --color off
mpirun -n 6 ../eel-opt -i gary.i

echo "End: $(date)"
