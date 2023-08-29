#!/usr/bin/env python3
import sys
import subprocess as sp
args= sys.argv
pkgs = "c('" + "','".join(args[3:]) + "')"
container = args[1]
singularity_cmd_stem = '''
singularity exec  \
    --bind="/manitou/pmg/users/vss2134" \
    --bind="/pmglocal" \
    --bind="/manitou-home/home/vss2134/rserver-tmp/var/lib:/var/lib/rstudio-server" \
    --bind="/manitou-home/home/vss2134/rserver-tmp/var/run:/var/run/rstudio-server" \
    --bind="/manitou-home/home/vss2134/rserver-tmp/tmp:/tmp" '''
if args[2] == 'CRAN':
    cmd = f"""{singularity_cmd_stem} {container} Rscript -e "install.packages({pkgs}, repo='https://cloud.r-project.org/')" """
elif args[2] == 'Bioc':
    cmd = f"""{singularity_cmd_stem} {container} Rscript -e "BiocManager::install({pkgs})" """
elif args[2] == 'github':
    cmd = f"""{singularity_cmd_stem} {container} Rscript -e "remotes::install_github({pkgs})" """
else:
    print('BAD REPO INPUT')
    sys.exit(1)


sp.run(f'module load singularity; {cmd}', shell=True)
