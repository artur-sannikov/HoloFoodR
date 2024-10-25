ARG BIOC_VERSION
FROM bioconductor/bioconductor_docker:${BIOC_VERSION}

# Copy repository to Docker image
COPY --chown=rstudio:rstudio . /opt/pkg

# Install essentials
RUN apt-get install -y python3 python3-setuptools python3-dev python3-pip

# Install HoloFoodR dependencies
RUN Rscript -e 'repos <- BiocManager::repositories(); \
    remotes::install_local(path = "/opt/pkg/", repos=repos, \
    dependencies=TRUE, build_vignettes=FALSE, upgrade=TRUE); \
    sessioninfo::session_info(installed.packages()[,"Package"], \
    include_base = TRUE)'

# Istall CRAN packages for case study
# RUN Rscript -e 'install.packages(c("DT", "patchwork", "reticulate", "reshape", "shadowtext", "shadowtext", \
#     "scater", "ggsignif", "stringr", "ggpubr", "GGally", "ggplot2", "knitr", "latex2exp", "UpSetR"))'

RUN Rscript -e 'install.packages(c("dplyr", "DT", "ggsignif", "latex2exp", "patchwork", "shadowtext", "reticulate"))'

# Install Bioconductor packages for case study
RUN R -e 'BiocManager::install(c("BiocStyle", "ComplexHeatmap", "MGnifyR", "mia", "miaViz", "MOFA2", "scater"))'

# Install HoloFoodR locally
RUN R -e 'devtools::install_local("/opt/pkg/")'

# Install mofapy2 for case study
# RUN python3 -m pip install 'https://github.com/bioFAM/mofapy2/tarball/master'

# Internal port for RStudio server is 8787
EXPOSE 8787
