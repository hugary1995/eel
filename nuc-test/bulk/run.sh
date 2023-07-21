echo "Start: $(date)"
echo "cwd: $(pwd)"

mpirun -n 6 ../../eel-opt -i bulk_nuc.i --color off

echo "End: $(date)"
