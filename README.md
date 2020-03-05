# Rstudio-singularity
I wanted a way to run Rstudio server on my HPC, which can't be done out of the box becasue Rstudio server requires root access. Rstudio server runs much faster than X11 forwarding Rstudio, which was the only way I could use Rstudio on biowulf. So I decied to make a singularity container to run Rstudio server in.
## Dockerfile
A custom docker file used to make a singularity image for Biowulf. I was initially using the tidyverse Rstudio image from rocker, but for some reason it would not let me update the Rprofile folder. So this dockerfile is made from merging several rockerimages - `r-ver`, `rstudio`, and `tidyverse`. all the scripts in this repo except `match_R_bioc.sh` are taken from the rocker repos for those images. `R
