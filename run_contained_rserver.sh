#!/bin/bash 
set -ue
PORT=$1
instancename=$(openssl rand -hex 8)
# for some reason in current build of container no python version can be found 

if [ -z ${2+x} ]
then
      rstmpdir="/manitou/pmg/users/vss2134/${instancename}"
      echo "tmpdir is not specified. Using ${rstmpdir}"
      mkdir -p $rstmpdir
else
    rstmpdir=$2
fi
module load singularity
container=$3
# copy over Rstudio settings 
### this assumes you have a Rstudio default settings folder. 
### To make one, you'll need to run Rstudio once using the `run_rserver_script`, then copy ~/.rstudio to ~/Rstudio-default
RstudioSettings='/manitou-home/home/vss2134/Rstudio-default/monitored/'
mkdir -p $rstmpdir/.rstudio/
mkdir -p $rstmpdir/.R/
cp -r /manitou-home/home/vss2134/Rstudio-default/monitored/ $rstmpdir/.rstudio/
cp -r /manitou-home/home/vss2134/R-default/rstudio $rstmpdir/.R/
cp -r /manitou-home/home/vss2134/R-default/snippets $rstmpdir/.R/

# make /var/* folders (required for Rstudio 1.3+)
mkdir -p $rstmpdir/var/lib/
mkdir -p $rstmpdir/var/run/
mkdir -p $rstmpdir/tmp/

# use a singularity instance  + contain to rstmpdir to allow for multiple R server instances
singularity instance start \
  --contain \
  -H "$rstmpdir" \
  --workdir "$rstmpdir" \
  --bind="/manitou/pmg/users/vss2134" \
  --bind="/pmglocal" \
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
