#!/bin/bash 
#set -eui pipefail;
PORT=$1
module load singularity
rm ~/.rstudio/sessions/* -rf
echo " go to 127.0.0.1:${PORT}" && singularity exec  --bind=/data/swamyvs/,/data/OGVFB_BG/ /data/swamyvs/singularity_images/rstudio-fromscratch-latest.sif  rserver --www-port $PORT
rm ~/.rstudio/sessions/* -rf