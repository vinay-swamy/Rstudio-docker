# Running Rstudio-server on an academic HPC

Rstudio server lets you run rstudio on a remote server, and use a browser based version of Rstudio. This has several advantages over running Rstudio on the server, and then forwarding the screen, namely that Rstudio-sever requires much less connection bandwidth

Because of the rocker, project, containerized versions of Rstudio-server are easily available, but these can't be directly used as most HPC's do not allow the use of docker. Most HPC's do allow singularity, and converting between docker <==> singularity is pretty straight forward. 

```
singularity pull rstudio_img.sif docker://rocker/Rstudio
```

However, directly using rocker's containers doesn't give the full features of Rstudio because
- you cannot install packages through the standard `install.packages` because the container itself is not writable. A external library collection on the server's filesystem can be used, and these need to to be set in `Rprofile-tmp` and `Renivron-tmp` files. For example in `Rprofile-tmp` above, i set the default library to be  `/manitou/pmg/users/vss2134/RLib_singularity/ `, a location on my HPC. 

- you can only have one instance of Rstudio server at a time. This can be changes if you configure singularity to isolate the home directory, but this will cause you to lose any setting you have previouslt set in Rstudio. 

- connecting python via `reticulate` is challenging. The simplest way to is to hardcode the RETICULATE_PYTHON environment variable in the `Renviron-tmp` file, then rebuild the container. 


