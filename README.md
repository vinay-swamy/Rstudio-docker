## Running Rstudio-server on Manitou

To run Rstudio on singulartiy on manitou, you need to first build the container. You'll need docker installed on your local machine to do this. These containers are built on top of [rocker's] R docker containers. 


First, fork and clone this repo. You need to edit the following files, and appropriately change the paths to match your own configuration:
- `Rprofile-tmp`: this file is copied to the container's `/home/rstudio/.Rprofile` and is used to set the default library location.
- `Renviron-tmp`: this file is copied to the container's `/home/rstudio/.Renviron` and is used to set the default python location.
- `install_packages_R_singularity.py` :  You cannot use the regular `install.packages` function in Rstudio bc the way the container is set up. Instead, you need to use this script to install packages. Change the paths here
- `run_rserver.sh`: call this script to start an Rstudio session
- `run_contained_rserver.sh` : This will start an Rstudio session in a contained environment. This is useful if you want to run multiple Rstudio sessions at the same time, but is a little more challenging to set up.

The reason we need to create a custom Rprofile/Renviron file is because you cannot install packages through the standard `install.packages` because the container itself is not writable. A external library collection on the server's filesystem can be used, and these need to to be set in `Rprofile-tmp` and `Renivron-tmp` files. For example in `Rprofile-tmp` above, i set the default library to be  `/manitou/pmg/users/vss2134/RLib_singularity/ `, and you'll need make sure this is reflected across all the files.

Next, build the container and push it to docker hub. I'm pushing it to my docker hub here, but you'll need to use your own account 
```
docker build -t vinayswamy/rstudiodocker:latest .
docker push vinayswamy/rstudiodocker:latest

```

Then on Manitou, request a compute node, load singularity, clone this repo, and pull the container
```
module load singularity 
singularity pull rstudio.sif docker://vinayswamy/rstudiodocker:latest
```

Then you can run the container with the following command. 

```
bash run_rserver.sh 9099 rstudio.sif
```

9099 is the port Rstudio is running on, and you can change this to whatever you want. Then on your local machine, open a tunnel and forward it to the port you specified above. Make sure you change the node to whatever node you are on.

```
ssh -t -t  uni@128.59.124.102  -L 7077:localhost:8088 ssh m004 -L 8088:localhost:9099
```

Then, open a browser and got to http://127.0.0.1:7077 and you should see Rstudio running. 


## installing packages 

You can use the `install_packages_R_singularity.py` script to install packages. This script will install the packages in the default library location you set in `Rprofile-tmp`. You can run this script from the command line like so:

```
python install_packages_R_singularity.py rstudio.sif CRAN dplyr
```
1st arg is the path to the singularity image, second is the package repo(one of "CRAN", "Bioc", "github"), and the third is the package name(s). You can install multiple packages by adding more package names at the end. Make sure you run `run_rserver.sh` before you run this script.

## Upgrading R/Rstudio version

To upgrade the R verison, you'll need to change the initial portion of the docker file to match a newer version of a rocker docker container. For example to upgrade to R 4.3.1, I would get the Rstudio rocker docker file from the rocker repo(https://github.com/rocker-org/rocker-versioned2/blob/master/dockerfiles/rstudio_4.3.1.Dockerfile), and replace the relevant portion of the docker file in this repo. Then rebuild the container and push it to docker hub. 


## Limitations

Directly using rocker's containers doesn't give the full features of Rstudio because

- you can only have one instance of Rstudio server at a time. This can be changes if you configure singularity to isolate the home directory, but this will cause you to lose any setting you have previouslt set in Rstudio. 

- connecting python via `reticulate` is challenging. The simplest way to is to hardcode the RETICULATE_PYTHON environment variable in the `Renviron-tmp` file, then rebuild the container. 


