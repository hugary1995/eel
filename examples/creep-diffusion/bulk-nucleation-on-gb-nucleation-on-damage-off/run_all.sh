#!/usr/bin/env bash

for T in {700..1100..100}; do
  pids=()
  for load in {10..40..10}; do
      echo "T = $T, load = $load"
      ../../../eel-opt -i ../base.i creep-diffusion.i T=$T load=$load 1>/dev/null 2>/dev/null &
      pids+=($!)
  done
  for pid in ${pids[*]}; do
    wait $pid
  done


  pids=()
  for load in {50..80..10}; do
      echo "T = $T, load = $load"
      ../../../eel-opt -i ../base.i creep-diffusion.i T=$T load=$load 1>/dev/null 2>/dev/null &
      pids+=($!)
  done
  for pid in ${pids[*]}; do
    wait $pid
  done


  pids=()
  for load in {90..120..10}; do
      echo "T = $T, load = $load"
      ../../../eel-opt -i ../base.i creep-diffusion.i T=$T load=$load 1>/dev/null 2>/dev/null &
      pids+=($!)
  done
  for pid in ${pids[*]}; do
    wait $pid
  done


  pids=()
  for load in {130..160..10}; do
      echo "T = $T, load = $load"
      ../../../eel-opt -i ../base.i creep-diffusion.i T=$T load=$load 1>/dev/null 2>/dev/null &
      pids+=($!)
  done
  for pid in ${pids[*]}; do
    wait $pid
  done


  pids=()
  for load in {170..200..10}; do
      echo "T = $T, load = $load"
      ../../../eel-opt -i ../base.i creep-diffusion.i T=$T load=$load 1>/dev/null 2>/dev/null &
      pids+=($!)
  done
  for pid in ${pids[*]}; do
    wait $pid
  done
done
