FROM rocker/r-ver:4.0.3

# Modified from https://github.com/rocker-org/rocker-versioned2/blob/master/dockerfiles/Dockerfile_rstudio_devel
# commit: ed22626. DO NOT CHANGE( wont work with singularity)

ENV S6_VERSION=v2.1.0.2
ENV RSTUDIO_VERSION=1.2.5042
ENV PATH=/usr/lib/rstudio-server/bin:$PATH

RUN /rocker_scripts/install_rstudio.sh
RUN /rocker_scripts/install_pandoc.sh
RUN /rocker_scripts/install_tidyverse.sh
RUN rm -f /var/lib/dpkg/available && rm -rf  /var/cache/apt/*

# issues with '/var/lib/dpkg/available' not found
# this will recreate
RUN dpkg --clear-avail

# This is to avoid the error
# 'debconf: unable to initialize frontend: Dialog'
ENV DEBIAN_FRONTEND noninteractive

# Update apt-get
RUN apt-get update \
	&& apt-get install -y --no-install-recommends apt-utils \
	&& apt-get install -y --no-install-recommends \
	## Basic deps
	gdb \
	libxml2-dev \
	libz-dev \
	liblzma-dev \
	libbz2-dev \
	libpng-dev \
	libmariadb-dev-compat \
	## sys deps from bioc_full
	pkg-config \
	fortran77-compiler \
	byacc \
	automake \
	curl \
	## This section installs libraries
	libpng-dev \
	libnetcdf-dev \
	libhdf5-serial-dev \
	libfftw3-dev \
	libopenbabel-dev \
	libopenmpi-dev \
	libxt-dev \
	libcairo2-dev \
	libtiff5-dev \
	libreadline-dev \
	libgsl0-dev \
	libgtk2.0-dev \
	libgl1-mesa-dev \
	libglu1-mesa-dev \
	libgmp3-dev \
	libhdf5-dev \
	libncurses-dev \
	libbz2-dev \
	libxpm-dev \
	liblapack-dev \
	libv8-dev \
	libgtkmm-2.4-dev \
	libmpfr-dev \
	libudunits2-dev \
	libmodule-build-perl \
	libapparmor-dev \
	libgeos-dev \
	libprotoc-dev \
	librdf0-dev \
	libmagick++-dev \
	libsasl2-dev \
	libpoppler-cpp-dev \
	libprotobuf-dev \
	libpq-dev \
	libperl-dev \
	## software - perl extentions and modules
	libarchive-extract-perl \
	libfile-copy-recursive-perl \
	libcgi-pm-perl \
	libdbi-perl \
	libdbd-mysql-perl \
	libxml-simple-perl \
	## Databases and other software
	sqlite \
	openmpi-bin \
	mpi-default-bin \
	openmpi-common \
	openmpi-doc \
	tcl8.6-dev \
	tk-dev \
	default-jdk \
	imagemagick \
	tabix \
	ggobi \
	graphviz \
	protobuf-compiler \
	jags \
	## Additional resources
	xfonts-100dpi \
	xfonts-75dpi \
	biber \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/*

##conda block 
RUN apt-get -qq -y install bzip2 \
    && mkdir  /conda \
    && curl -sSL https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh -o /tmp/miniconda.sh \
    && bash /tmp/miniconda.sh -bfp /opt/conda \
    && ls /opt/ \
    && rm -rf /tmp/miniconda.sh \
    && /opt/conda/bin/conda install -y python=3 \
    && /opt/conda/bin/conda update conda \
    && apt-get -qq -y remove curl bzip2 \
    && apt-get -qq -y autoremove \
    && apt-get autoclean \
    && rm -rf /var/lib/apt/lists/* /var/log/dpkg.log \
    && /opt/conda/bin/conda clean --all --yes

ENV PATH /opt/conda/bin:$PATH
COPY base.yml /tmp/
RUN conda init 
RUN conda env update -n base --file /tmp/base.yml 


RUN apt-get update \
	&& apt-get install -y --no-install-recommends libboost-dev  libboost-filesystem1.71-dev libboost-graph1.71-dev libboost-system1.71-dev libboost-all-dev

## dependencies for sf package
RUN apt-get install -y  software-properties-common && \
	apt-get update && add-apt-repository ppa:ubuntugis/ubuntugis-unstable && \
	apt-get update && \
	apt-get install -y gdal-bin \
	libmysqlclient-dev \
	default-libmysqlclient-dev \
	libgdal-dev \
	proj-bin \
	libgeos-dev

RUN Rscript --vanilla -e 'install.packages("Cairo", lib = "/usr/local/lib/R/library", repos="https://cloud.r-project.org/")'
#"/usr/local/lib/R/site-library"  "/usr/local/lib/R/library"

RUN Rscript -e 'install.packages("BiocManager")'
RUN Rscript -e 'BiocManager::install("devtools", update=F, ask=F)'

COPY Renviron-tmp /usr/local/lib/
COPY Renviron-tmp /usr/local/lib/R/etc/Renviron
RUN Rscript -e 'devtools::install_github("vinay-swamy/RBedtools")'


COPY add_shiny.sh /etc/cont-init.d/add
COPY disable_auth_rserver.conf /etc/rstudio/disable_auth_rserver.conf
COPY pam-helper.sh /usr/lib/rstudio-server/bin/pam-helper
COPY Rprofile-tmp /usr/local/lib/R/etc/Rprofile.site
COPY Rprofile-tmp /usr/local/lib/

RUN echo DONE
