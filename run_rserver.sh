#!/bin/bash 
#set -eui pipefail;
PORT=$1
module load singularity
rm ~/.rstudio/sessions/* -rf

## EDIT 05.18.2021: need the rserver-tmp binds for Rstudio 1.3+
echo " go to 127.0.0.1:${PORT}" && singularity exec  \
    --bind="/data/swamyvs/" \
    --bind="/data/OGVFB_BG/"  \
    --bind="rserver-tmp/var/lib:/var/lib/rstudio-server" \
    --bind="rserver-tmp/var/run:/var/run/rstudio-server" \
    --bind="rserver-tmp/tmp:/tmp" \
    /data/swamyvs/singularity_images/rstudio-fromscratch-latest.sif  rserver --www-port $PORT
rm ~/.rstudio/sessions/* -rf
