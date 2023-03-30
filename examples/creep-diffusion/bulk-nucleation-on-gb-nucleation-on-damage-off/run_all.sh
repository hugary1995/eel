#!/usr/bin/env bash

for T in {700..1100..100}; do
  pids=()
  for load in {10..200..10}; do
      echo "T = $T, load = $load"
      ../../../eel-opt -i ../base.i creep-diffusion.i T=$T load=$load 1>/dev/null 2>/dev/null &
      pids+=($!)
  done
  for pid in ${pids[*]}; do
    wait $pid
  done
done
