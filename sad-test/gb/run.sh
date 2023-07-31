echo "Start: $(date)"
echo "cwd: $(pwd)"

# mpirun -n 1 ../../eel-opt -i gary.i --keep-cout --redirect-stdout 
mpirun -n 8 ../../eel-opt -i gary.i
# nohup mpirun -n 1 ../../eel-opt -i gary.i > log.txt 2>&1 &

echo "End: $(date)"
