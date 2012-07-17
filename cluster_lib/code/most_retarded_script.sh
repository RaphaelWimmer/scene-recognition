#!/bin/sh
echo "addpath('/work/shiry/scene-recognition/cluster_lib/example'); run_cluster"  | /usr/sww/pkg/matlab-r2010b/bin/matlab > /work/shiry/scene-recognition/results/train_poselets.txt 2>&1 &
