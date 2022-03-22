setwd("/Users/letitiaho/src/talker_change_data_processing/")
library("dplyr")
library("ggplot2")
library("ggpubr")
source("tools/functions.R")
source("threshold_free_clustering_coherence/src/functions.R")

weight_scores <- readRDS('threshold_free_clustering_coherence/data/weight_scores/average.RDS')

S_hist <- histogram(weight_scores$S, title = "S", xlim = c(-0.5, 0.5))
T_hist <- histogram(weight_scores$T, title = "T", xlim = c(-0.5, 0.5))
M_hist <- histogram(weight_scores$M, title = "M", xlim = c(-0.5, 0.5))
N_hist <- histogram(weight_scores$N, title = "N", xlim = c(-0.5, 0.5))
L_hist <- histogram(weight_scores$L, title = "L", xlim = c(-0.5, 0.5))
H_hist <- histogram(weight_scores$H, title = "H", xlim = c(-0.5, 0.5))

plot <- ggarrange(S_hist, T_hist, M_hist, N_hist, L_hist, H_hist, ncol = 2, nrow = 3)
plot
ggsave(plot, filename = 'threshold_free_clustering_coherence/figs/weight_scores_average.png', width = 12, height = 10)
