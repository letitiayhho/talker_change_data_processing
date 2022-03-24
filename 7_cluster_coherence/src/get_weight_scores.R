#!/usr/bin/env Rscript

setwd("/Users/letitiaho/src/talker_change_data_processing/")
library("dplyr")
library("ggplot2")
library("ggpubr")
source("tools/functions.R")
source("7_cluster_coherence/src/functions.R")

coherr <- read.csv(file = "6_coherence/data/average.csv")
overall <- subset(coherr, keepSubjNum = FALSE) %>% colMeans() %>% as.double() %>% normalize()
S <- subset(coherr, talker = "S", keepSubjNum = FALSE) %>% colMeans() %>% as.double() %>% normalize()
T <- subset(coherr, talker = "T", keepSubjNum = FALSE) %>% colMeans() %>% as.double() %>% normalize()
M <- subset(coherr, meaning = "M", keepSubjNum = FALSE) %>% colMeans() %>% as.double() %>% normalize()
N <- subset(coherr, meaning = "N", keepSubjNum = FALSE) %>% colMeans() %>% as.double() %>% normalize()
L <- subset(coherr, constraint = "L", keepSubjNum = FALSE) %>% colMeans() %>% as.double() %>% normalize()
H <- subset(coherr, constraint = "H", keepSubjNum = FALSE) %>% colMeans() %>% as.double() %>% normalize()
weight_scores <- list("overall" = overall, "S" = S, "T" = T, "M" = M, "N" = N, "L" = L, "H" = H)

# Save variables
save_filepath <- paste("7_cluster_coherence/data/weight_scores/weight_scores.RDS", sep = "")
saveRDS(weight_scores, file = save_filepath)
