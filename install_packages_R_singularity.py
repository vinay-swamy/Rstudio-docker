#!/usr/bin/env python3
import sys
import subprocess as sp
args= sys.argv
pkgs = "c('" + "','".join(args[2:]) + "')"
container = "/data/swamyvs/singularity_images/rstudio-fromscratch-latest.sif"
if args[1] == 'CRAN':
    cmd = f"""singularity exec  --bind=/data/swamyvs/,/data/OGVFB_BG/ {container} Rscript -e "install.packages({pkgs}, repo='https://cloud.r-project.org/')" """
elif args[1] == 'Bioc':
    cmd = f"""singularity exec  --bind=/data/swamyvs/,/data/OGVFB_BG/ {container} Rscript -e "BiocManager::install({pkgs})" """
elif args[1] == 'github':
    cmd = f"""singularity exec  --bind=/data/swamyvs/,/data/OGVFB_BG/ {container} Rscript -e "remotes::install_github({pkgs})" """
else:
    print('BAD REPO INPUT')
    sys.exit(1)


sp.run(f'module load singularity; {cmd}', shell=True)
