#!/bin/bash 
set -ue
PORT=$1
instancename=$(openssl rand -hex 8)
# for some reason in current build of container no python version can be found 

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

# make /var/* folders (required for Rstudio 1.3+)
mkdir -p $rstmpdir/var/lib/
mkdir -p $rstmpdir/var/run/
mkdir -p $rstmpdir/tmp/

# use a singularity instance  + contain to rstmpdir to allow for multiple R server instances
singularity instance start \
  --contain \
  -H "$rstmpdir" \
  --workdir "$rstmpdir" \
  --bind="/data/swamyvs/" \
  --bind="/data/OGVFB_BG/"  \
  --bind="$rstmpdir/var/lib:/var/lib/rstudio-server" \
  --bind="$rstmpdir/var/run:/var/run/rstudio-server" \
  --bind="$rstmpdir/tmp:/tmp" \
  "$container" \
  $instancename


echo "Go to 127.0.0.1:${PORT}"

# stop instance when scripts is ctrl c 
trap "singularity instance stop -s SIGKILL '$instancename';" EXIT
singularity exec \
  "instance://$instancename" \
  rserver --www-port $PORT
