# Running Rstudio-server on an academic HPC

Rstudio server lets you run rstudio on a remote server, and use a browser based version of Rstudio. This has several advantages over running Rstudio on the server, and then forwarding the screen, namely that Rstudio-sever requires much less connection bandwidth

Because of the rocker, project, containerized versions of Rstudio-server are easily available, but these can't be directly used as most HPC's do not allow the use of docker. Most HPC's do allow singularity, and converting between docker <==> singularity is pretty straight forward. 

```
singularity pull rstudio_img.sif docker://rocker/Rstudio
```

However, directly using rocker's containers doesn't give the full features of Rstudio because
- you cannot install packages through the standard `install.packages` because the container itself is not writable. A external library collection on the server's filesystem can be used, but theres no way to add this new path to the Rprofile/Renvironments, and so when installing and loading packages, you'll have to always manually specify the path

- Secondly(and more annoyingly) you can only have one instance of Rstudio server at a time.


