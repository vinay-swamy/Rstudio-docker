#!/bin/bash 
#set -eui pipefail;
PORT=$1 # port on Manitou
SIF=$2 # path to singularity image
module load singularity

rm ~/.rstudio/sessions/* -rf # clear previous session file 
mkdir -p /manitou-home/home/vss2134/rserver-tmp/tmp
mkdir -p /manitou-home/home/vss2134/rserver-tmp/var/lib
mkdir -p /manitou-home/home/vss2134/rserver-tmp/var/run
## need the rserver-tmp binds for things to work properly
singularity exec  \
    --bind="/manitou/pmg/users/vss2134" \
    --bind="/pmglocal" \
    --bind="/manitou-home/home/vss2134/rserver-tmp/var/lib:/var/lib/rstudio-server" \
    --bind="/manitou-home/home/vss2134/rserver-tmp/var/run:/var/run/rstudio-server" \
    --bind="/manitou-home/home/vss2134/rserver-tmp/tmp:/tmp" \
    $SIF  rserver --www-port $PORT

## ctrl-c to stop server