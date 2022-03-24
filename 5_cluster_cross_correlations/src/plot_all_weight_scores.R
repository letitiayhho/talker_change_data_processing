setwd("/Users/letitiaho/src/talker_change_data_processing/")
library("dplyr")
library("ggplot2")
library("ggpubr")
source("tools/functions.R")
source("5_cluster_cross_correlations/src/functions.R")

weight_scores <- readRDS('5_cluster_cross_correlations/data/weight_scores/weight_scores.RDS')

# One-sample

S_hist <- histogram(weight_scores$S, title = "S", xlim = c(0, 1))
T_hist <- histogram(weight_scores$T, title = "T", xlim = c(0, 1))
M_hist <- histogram(weight_scores$M, title = "M", xlim = c(0, 1))
N_hist <- histogram(weight_scores$N, title = "N", xlim = c(0, 1))
L_hist <- histogram(weight_scores$L, title = "L", xlim = c(0, 1))
H_hist <- histogram(weight_scores$H, title = "H", xlim = c(0, 1))

plot <- ggarrange(S_hist, T_hist, M_hist, N_hist, L_hist, H_hist, ncol = 2, nrow = 3)
ggsave(plot, filename = '5_cluster_cross_correlations/figs/weight_scores_one_sample.png', width = 12, height = 10)

# Two-sample

talker_hist <- histogram(weight_scores$talker, title = "Talker", xlim = c(0, 1))
meaning_hist <- histogram(weight_scores$meaning, title = "Meaning", xlim = c(0, 1))
constraint_hist <- histogram(weight_scores$constraint, title = "Constraint", xlim = c(0, 1))

plot <- ggarrange(talker_hist, meaning_hist, constraint_hist, ncol = 1, nrow = 3)
ggsave(plot, filename = '5_cluster_cross_correlations/figs/weight_scores_two_sample.png', width = 8, height = 10)
