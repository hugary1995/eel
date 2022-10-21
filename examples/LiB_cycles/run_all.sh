#!/usr/bin/env bash

for i in {1..1000}; do
    echo "Cycle ${i}, CC charging"
    if [[ i -eq 1 ]]; then
      mpiexec -n ${MOOSE_JOBS} ../../eel-opt -i ramp.i &>/dev/null
    else
      mpiexec -n ${MOOSE_JOBS} ../../eel-opt -i CC_charging.i cycle=${i} &>/dev/null
    fi

    echo "Cycle ${i}, CV charging"
    mpiexec -n ${MOOSE_JOBS} ../../eel-opt -i CV_charging.i cycle=${i} &>/dev/null

    echo "Cycle ${i}, CC discharging"
    mpiexec -n ${MOOSE_JOBS} ../../eel-opt -i CC_discharging.i cycle=${i} &>/dev/null
done
