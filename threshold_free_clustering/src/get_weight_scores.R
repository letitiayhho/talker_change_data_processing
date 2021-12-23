#!/usr/bin/env Rscript

setwd("/Users/letitiaho/src/talker_change_data_processing/")
library("dplyr")
library("ggplot2")
library("ggpubr")
source("tools/functions.R")
source("threshold_free_clustering/src/functions.R")

# Get command line args
args = commandArgs(trailingOnly=TRUE)
if (length(args) != 1) {
  stop("One argument ('S', 'T', 'talker', 'meaning', etc) must be supplied", call.=FALSE)
}
condition = args[1]

# Normalize w-score to compute weight scores
filepath <- paste("threshold_free_clustering/data/wilcoxon/", condition, ".RDS", sep = "")
w <- readRDS(file = filepath)

# Get weight scores
weight_scores <- normalize(w$w)

# Plot
# S_hist <- histogram(S_weight_scores, xlab = "weight scores", title = "S", xlim = c(0.5, 1.5))
# T_hist <- histogram(T_weight_scores, xlab = "weight scores", title = "T", xlim = c(0.5, 1.5))
# M_hist <- histogram(M_weight_scores, xlab = "weight scores", title = "M", xlim = c(0.5, 1.5))
# N_hist <- histogram(N_weight_scores, xlab = "weight scores", title = "N", xlim = c(0.5, 1.5))
# L_hist <- histogram(L_weight_scores, xlab = "weight scores", title = "L", xlim = c(0.5, 1.5))
# H_hist <- histogram(H_weight_scores, xlab = "weight scores", title = "H", xlim = c(0.5, 1.5))
# plot <- ggarrange(S_hist, T_hist, M_hist, N_hist, L_hist, H_hist, ncol = 2, nrow = 3)
# ggsave(plot, filename = 'threshold_free_clustering/figs/weight_scores_one_sample.png', width = 12, height = 10)

# talker_hist <- histogram(talker_weight_scores, xlab = "weight scores", title = "talker", xlim = c(0.5, 1.5))
# meaning_hist <- histogram(meaning_weight_scores, xlab = "weight scores", title = "meaning", xlim = c(0.5, 1.5))
# constraint_hist <- histogram(constraint_weight_scores, xlab = "weight scores", title = "constraint", xlim = c(0.5, 1.5))
# plot <- ggarrange(talker_hist, meaning_hist, constraint_hist, ncol = 1, nrow = 3)
# ggsave(plot, filename = 'threshold_free_clustering/figs/weight_scores_two_sample.png', width = 12, height = 10)

# Save variables
save_filepath <- paste("threshold_free_clustering/data/weight_scores/", condition, ".RDS", sep = "")
saveRDS(weight_scores, file = save_filepath)
