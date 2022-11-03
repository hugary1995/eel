#!/usr/bin/env bash

CC_charging_fname="3D_SSB_CC_charging"
CV_charging_fname="3D_SSB_CV_charging"
CC_discharging_fname="3D_SSB_CC_discharging"

CC_charging_frames=100
CV_charging_frames=100
CC_discharging_frames=100

pvpython visualize_c.py ${CC_charging_fname}.e $CC_charging_frames 0
pvpython visualize_c.py ${CV_charging_fname}.e $CV_charging_frames $CC_charging_frames 
pvpython visualize_c.py ${CC_discharging_fname}.e $CC_discharging_frames $((CC_charging_frames+CV_charging_frames))
ffmpeg -y -framerate 20 -pattern_type glob -i 'c/*.png' -c:v libx264 -pix_fmt yuv420p c.mov

pvpython visualize_h.py ${CC_charging_fname}.e $CC_charging_frames 0
pvpython visualize_h.py ${CV_charging_fname}.e $CV_charging_frames $CC_charging_frames 
pvpython visualize_h.py ${CC_discharging_fname}.e $CC_discharging_frames $((CC_charging_frames+CV_charging_frames))
ffmpeg -y -framerate 20 -pattern_type glob -i 'h/*.png' -c:v libx264 -pix_fmt yuv420p h.mov

pvpython visualize_i_ca.py ${CC_charging_fname}.e $CC_charging_frames 0
pvpython visualize_i_ca.py ${CV_charging_fname}.e $CV_charging_frames $CC_charging_frames 
pvpython visualize_i_ca.py ${CC_discharging_fname}.e $CC_discharging_frames $((CC_charging_frames+CV_charging_frames))
ffmpeg -y -framerate 20 -pattern_type glob -i 'i_ca/*.png' -c:v libx264 -pix_fmt yuv420p i_ca.mov

pvpython visualize_i.py ${CC_charging_fname}.e $CC_charging_frames 0
pvpython visualize_i.py ${CV_charging_fname}.e $CV_charging_frames $CC_charging_frames 
pvpython visualize_i.py ${CC_discharging_fname}.e $CC_discharging_frames $((CC_charging_frames+CV_charging_frames))
ffmpeg -y -framerate 20 -pattern_type glob -i 'i/*.png' -c:v libx264 -pix_fmt yuv420p i.mov

pvpython visualize_j.py ${CC_charging_fname}.e $CC_charging_frames 0
pvpython visualize_j.py ${CV_charging_fname}.e $CV_charging_frames $CC_charging_frames 
pvpython visualize_j.py ${CC_discharging_fname}.e $CC_discharging_frames $((CC_charging_frames+CV_charging_frames))
ffmpeg -y -framerate 20 -pattern_type glob -i 'j/*.png' -c:v libx264 -pix_fmt yuv420p j.mov

pvpython visualize_p.py ${CC_charging_fname}.e $CC_charging_frames 0
pvpython visualize_p.py ${CV_charging_fname}.e $CV_charging_frames $CC_charging_frames 
pvpython visualize_p.py ${CC_discharging_fname}.e $CC_discharging_frames $((CC_charging_frames+CV_charging_frames))
ffmpeg -y -framerate 20 -pattern_type glob -i 'p/*.png' -c:v libx264 -pix_fmt yuv420p p.mov

pvpython visualize_Phi_ca.py ${CC_charging_fname}.e $CC_charging_frames 0
pvpython visualize_Phi_ca.py ${CV_charging_fname}.e $CV_charging_frames $CC_charging_frames 
pvpython visualize_Phi_ca.py ${CC_discharging_fname}.e $CC_discharging_frames $((CC_charging_frames+CV_charging_frames))
ffmpeg -y -framerate 20 -pattern_type glob -i 'Phi_ca/*.png' -c:v libx264 -pix_fmt yuv420p Phi_ca.mov

pvpython visualize_Phi.py ${CC_charging_fname}.e $CC_charging_frames 0
pvpython visualize_Phi.py ${CV_charging_fname}.e $CV_charging_frames $CC_charging_frames 
pvpython visualize_Phi.py ${CC_discharging_fname}.e $CC_discharging_frames $((CC_charging_frames+CV_charging_frames))
ffmpeg -y -framerate 20 -pattern_type glob -i 'Phi/*.png' -c:v libx264 -pix_fmt yuv420p Phi.mov

pvpython visualize_T.py ${CC_charging_fname}.e $CC_charging_frames 0
pvpython visualize_T.py ${CV_charging_fname}.e $CV_charging_frames $CC_charging_frames 
pvpython visualize_T.py ${CC_discharging_fname}.e $CC_discharging_frames $((CC_charging_frames+CV_charging_frames))
ffmpeg -y -framerate 20 -pattern_type glob -i 'T/*.png' -c:v libx264 -pix_fmt yuv420p T.mov

python curves.py ${CC_charging_fname}.csv $CC_charging_frames ${CV_charging_fname}.csv $CV_charging_frames ${CC_discharging_fname}.csv $CC_discharging_frames
ffmpeg -y -framerate 20 -pattern_type glob -i 'curves/CV_*.png' -c:v libx264 -pix_fmt yuv420p CV.mov
ffmpeg -y -framerate 20 -pattern_type glob -i 'curves/V_*.png' -c:v libx264 -pix_fmt yuv420p Vt.mov
ffmpeg -y -framerate 20 -pattern_type glob -i 'curves/C_*.png' -c:v libx264 -pix_fmt yuv420p Ct.mov

python collage.py
ffmpeg -y -framerate 20 -pattern_type glob -i 'animation/*.png' -c:v libx264 -pix_fmt yuv420p 3D_SSB.mov
