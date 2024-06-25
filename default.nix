# Use a specific version of nixpkgs from an bleeding-edge fork of github.com/NixOS/nixpkgs
let
  pkgs =
    import
      (fetchTarball "https://github.com/rstats-on-nix/nixpkgs/archive/498425cb8a029280851e85b16e83568f34e45a09.tar.gz")
      { };
  # Packages from CRAN
  rpkgs = with pkgs.rPackages; [
    ALDEx2
    bartMachine
    basilisk
    BiocManager
    BiocVersion
    biomformat
    chromote
    ComplexHeatmap
    FSA
    dplyr
    glmnet
    ggplot2
    ggpubr
    knitr
    gbm
    GGally
    MGnifyR
    miaViz
    MOFA2
    multiview
    patchwork
    pheatmap
    randomForest
    reshape2
    reticulate
    rmarkdown
    shadowtext
    styler
    vegan
    xgboost
    UpSetR
    miniUI
  ];

  # Build mia package
  mia = [
    (pkgs.rPackages.buildRPackage {
      name = "mia";
      src = pkgs.fetchgit {
        url = "https://github.com/microbiome/mia";
        branchName = "devel";
        rev = "c17fa9f70f556458247dda22112b14c9889efd3b";
        sha256 = "sha256-HG6DGD/PBEzTEzdayX6JgOs7vQpwLgvLmyb0xayyZ+M=";
      };

      # mia dependencies (see DESCRIPTION)
      propagatedBuildInputs = builtins.attrValues {
        inherit (pkgs.rPackages)
          ape
          BiocGenerics
          BiocParallel
          Biostrings
          bluster
          DECIPHER
          decontam
          DelayedArray
          DelayedMatrixStats
          DirichletMultinomial
          dplyr
          IRanges
          MASS
          MatrixGenerics
          mediation
          MultiAssayExperiment
          rlang
          S4Vectors
          scater
          scuttle
          SingleCellExperiment
          SummarizedExperiment
          tibble
          tidyr
          TreeSummarizedExperiment
          vegan
          rbiom
          ;
      };
    })
  ];

  # Build HoloFoodR package
  holofoodr = [
    (pkgs.rPackages.buildRPackage {
      name = "holofoodrR";
      src = pkgs.fetchgit {
        url = "https://github.com/EBI-Metagenomics/HoloFoodR";
        branchName = "devel";
        rev = "737983440ce72b6b7af5d16c52c92f991c078a38";
        sha256 = "sha256-xDi2BuntVvG8z4ZOW6V8MRken4mHVqA7/EGTnjeYqnk=";
      };

      # HoloFoodR dependencies (see DESCRIPTION)
      propagatedBuildInputs = builtins.attrValues {
        inherit (pkgs.rPackages)
          TreeSummarizedExperiment
          MultiAssayExperiment
          dplyr
          httr2
          jsonlite
          S4Vectors
          ;
      };
    })
  ];

  # Build IntegratedLearner package
  integrated_learner = [
    (pkgs.rPackages.buildRPackage {
      name = "IntegratedLearner";
      src = pkgs.fetchgit {
        url = "https://github.com/himelmallick/IntegratedLearner";
        branchName = "master";
        rev = "6d376d2eb0ee0ab58fb31dc20d5976ba8669eb7d";
        sha256 = "sha256-zrLYckGP6bQrV4KQ3Lo995DlO95Jr659ssRT3vOUOyc=";
      };

      # IntegratedLearner dependencies
      propagatedBuildInputs = builtins.attrValues {
        inherit (pkgs.rPackages)
          SuperLearner
          tidyverse
          caret
          mcmcplots
          glmnetUtils
          ROCR
          quadprog
          nloptr
          ;
      };
    })
  ];

  # System dependencies
  system_packages = builtins.attrValues { inherit (pkgs) R glibcLocales quarto texliveFull ; };

  # R wrapper for nix
  R = pkgs.rWrapper.override {
    packages = [
      rpkgs
      mia
      holofoodr
      integrated_learner
    ];
  };

  # RStudio wrapper for nix
  rstudio_pkgs = pkgs.rstudioWrapper.override {
    packages = [
      rpkgs
      mia
      holofoodr
      integrated_learner
    ];
  };
in

# Build R environment
pkgs.mkShell {
  LOCALE_ARCHIVE =
    if pkgs.system == "x86_64-linux" then "${pkgs.glibcLocalesUtf8}/lib/locale/locale-archive" else "";
  LANG = "en_US.UTF-8";
  LC_ALL = "en_US.UTF-8";
  LC_TIME = "en_US.UTF-8";
  LC_MONETARY = "en_US.UTF-8";
  LC_PAPER = "en_US.UTF-8";
  LC_MEASUREMENT = "en_US.UTF-8";

  buildInputs = [
    system_packages
    R
    rstudio_pkgs
  ];

  shellHook = "ulimit -s 32768";
}