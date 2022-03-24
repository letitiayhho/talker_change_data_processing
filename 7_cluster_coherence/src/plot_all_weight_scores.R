setwd("/Users/letitiaho/src/talker_change_data_processing/")
library("dplyr")
library("ggplot2")
library("ggpubr")
source("tools/functions.R")
source("7_cluster_coherence/src/functions.R")

# Load weight scores
weight_scores <- readRDS('7_cluster_coherence/data/weight_scores/weight_scores.RDS')

# Overall plot
overall_hist <- histogram(weight_scores$overall, title = "Overall", xlim = c(0, 1))
overall_hist
ggsave(overall_hist, filename = '7_cluster_coherence/figs/weight_scores_overall.png', width = 12, height = 10)

# Plot for each condition
S_hist <- histogram(weight_scores$S, title = "S", xlim = c(0, 1))
T_hist <- histogram(weight_scores$T, title = "T", xlim = c(0, 1))
M_hist <- histogram(weight_scores$M, title = "M", xlim = c(0, 1))
N_hist <- histogram(weight_scores$N, title = "N", xlim = c(0, 1))
L_hist <- histogram(weight_scores$L, title = "L", xlim = c(0, 1))
H_hist <- histogram(weight_scores$H, title = "H", xlim = c(0, 1))

plot <- ggarrange(S_hist, T_hist, M_hist, N_hist, L_hist, H_hist, ncol = 2, nrow = 3)
plot
ggsave(plot, filename = '7_cluster_coherence/figs/weight_scores.png', width = 12, height = 10)

