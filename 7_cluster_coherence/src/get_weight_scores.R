#!/usr/bin/env Rscript

setwd("/Users/letitiaho/src/talker_change_data_processing/")
library("dplyr")
library("ggplot2")
library("ggpubr")
source("tools/functions.R")
source("threshold_free_clustering_coherence/src/functions.R")

coherr <- read.csv(file = "7_coherence/data/average.csv")
S <- subset(coherr, talker = "S", keepSubjNum = FALSE) %>% colMeans() %>% as.double() %>% normalize()
T <- subset(coherr, talker = "T", keepSubjNum = FALSE) %>% colMeans() %>% as.double() %>% normalize()
M <- subset(coherr, meaning = "M", keepSubjNum = FALSE) %>% colMeans() %>% as.double() %>% normalize()
N <- subset(coherr, meaning = "N", keepSubjNum = FALSE) %>% colMeans() %>% as.double() %>% normalize()
L <- subset(coherr, constraint = "L", keepSubjNum = FALSE) %>% colMeans() %>% as.double() %>% normalize()
H <- subset(coherr, constraint = "H", keepSubjNum = FALSE) %>% colMeans() %>% as.double() %>% normalize()
weight_scores <- list("S" = S, "T" = T, "M" = M, "N" = N, "L" = L, "H" = H)

# Save variables
save_filepath <- paste("threshold_free_clustering_coherence/data/weight_scores/average.RDS", sep = "")
saveRDS(weight_scores, file = save_filepath)
