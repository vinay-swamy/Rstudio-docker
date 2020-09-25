#!/bin/bash
VERSION=$1
rsync -rtlzv --delete cran.r-project.org::CRAN CRAN_BIOC_singularity/R/
rsync -zrtlv --delete master.bioconductor.org::release CRAN_BIOC_singularity/bioc/${VERSION}