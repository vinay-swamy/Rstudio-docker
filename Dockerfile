FROM --platform=linux/amd64 rocker/r-ver:4.0.3

# Modified from https://github.com/rocker-org/rocker-versioned2/blob/master/dockerfiles/Dockerfile_rstudio_devel
# commit: ed22626

ENV S6_VERSION=v2.1.0.2
ENV RSTUDIO_VERSION=1.2.5042
ENV PATH=/usr/lib/rstudio-server/bin:$PATH

RUN /rocker_scripts/install_rstudio.sh
RUN /rocker_scripts/install_pandoc.sh
RUN /rocker_scripts/install_tidyverse.sh
RUN rm -f /var/lib/dpkg/available && rm -rf  /var/cache/apt/*


RUN Rscript -e 'install.packages("BiocManager")'
RUN Rscript -e 'BiocManager::install("devtools", update=F, ask=F)'
RUN Rscript -e 'devtools::install_github("mvuorre/exampleRPackage")'


COPY Renviron-tmp /usr/local/lib/Renviron
COPY Renviron-tmp /usr/local/lib/R/etc/Renviron
COPY add_shiny.sh /etc/cont-init.d/add
COPY disable_auth_rserver.conf /etc/rstudio/disable_auth_rserver.conf
COPY pam-helper.sh /usr/lib/rstudio-server/bin/pam-helper
COPY Rprofile-tmp /usr/local/lib/R/etc/Rprofile.site
COPY Rprofile-tmp /usr/local/lib/Rprofile

RUN echo DONE
