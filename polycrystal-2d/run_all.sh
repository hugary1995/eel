# for nr_ratio in 0.1 1 10; do
#     for m_ratio in 0.1 1 10; do
#         echo "nr_ratio=$a_ratio nr_ratio=$m_ratio"
#         ../eel-opt -i gary.i nr_ratio=$nr_ratio m_ratio=$m_ratio 1>/dev/null 2>/dev/null &
#     done
# done

for load in {10..200..10}; do
    echo "load = $load"
    ../eel-opt -i gary.i load=$load 1>/dev/null 2>/dev/null &
done
