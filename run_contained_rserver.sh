#!/bin/bash 
set -ue
PORT=$1
instancename=$(openssl rand -hex 8)

## Each Rstudio-server instance will need to be contained inside its own folder
## by default, this script can make a new folder to set as the home directory each time/
## Or, pass a directory to $2 and that folder will be used 

if [ -z ${2+x} ]
then
      rstmpdir="/data/swamyvs/stmp/${instancename}"
      echo "tmpdir is not specified. Using ${rstmpdir}"
      mkdir -p $rstmpdir
else
    rstmpdir=$2
fi
module load singularity
container="/data/swamyvs/singularity_images/rstudio-fromscratch-latest.sif"
# copy over Rstudio settings
RstudioSettings='/home/swamyvs/Rstudio-default/monitored/'
mkdir -p $rstmpdir/.rstudio/
mkdir -p $rstmpdir/.R/
cp -r /home/swamyvs/Rstudio-default/monitored/ $rstmpdir/.rstudio/
cp -r /home/swamyvs/R-default/rstudio $rstmpdir/.R/
cp -r /home/swamyvs/R-default/snippets $rstmpdir/.R/


## Singularity instance can isolate individual isntances of a container with a separate home/tmpdir for each instance. This allows us to have multiple rstudio-server sessions up and running
singularity instance start \
  --contain \
  -H "$rstmpdir" \
  --workdir "$rstmpdir" \
  -B /data/swamyvs/,/data/OGVFB_BG/ \
  "$container" \
  $instancename


echo "Go to 127.0.0.1:${PORT}"

# stop instance when scripts is ctrl c 
trap "singularity instance stop -s SIGKILL '$instancename';" EXIT
singularity exec \
  "instance://$instancename" \
  rserver --www-port $PORT
