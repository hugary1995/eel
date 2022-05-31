# Copyright 2023, UChicago Argonne, LLC All Rights Reserved
# License: L-GPL 3.0
#!/usr/bin/env bash

T=300

for i in {1..570}; do
    echo "Cycle ${i}, CC charging"
    if [[ i -eq 1 ]]; then
      mpiexec -n ${MOOSE_JOBS} ../../eel-opt -i base.i ramp.i T0=$T &>/dev/null
    else
      mpiexec -n ${MOOSE_JOBS} ../../eel-opt -i base.i CC_charging.i cycle=${i} T0=$T &>/dev/null
    fi

    echo "Cycle ${i}, CC discharging"
    mpiexec -n ${MOOSE_JOBS} ../../eel-opt -i base.i CC_discharging.i cycle=${i} T0=$T &>/dev/null
done
