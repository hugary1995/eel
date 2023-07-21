echo "Start: $(date)"
echo "cwd: $(pwd)"

mpirun -n 6 ../../eel-opt -i gb_nuc.i --color off

echo "End: $(date)"
