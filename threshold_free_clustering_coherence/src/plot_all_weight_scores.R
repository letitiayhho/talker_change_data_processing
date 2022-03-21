setwd("/Users/letitiaho/src/talker_change_data_processing/")
library("dplyr")
library("ggplot2")
library("ggpubr")
source("tools/functions.R")
source("threshold_free_clustering/src/functions.R")

S <- readRDS('threshold_free_clustering/data/weight_scores/S.RDS')
T <- readRDS('threshold_free_clustering/data/weight_scores/T.RDS')
M <- readRDS('threshold_free_clustering/data/weight_scores/M.RDS')
N <- readRDS('threshold_free_clustering/data/weight_scores/N.RDS')
L <- readRDS('threshold_free_clustering/data/weight_scores/L.RDS')
H <- readRDS('threshold_free_clustering/data/weight_scores/H.RDS')

S_hist <- histogram(S, title = "S", xlim = c(0.5, 1.5))
T_hist <- histogram(T, title = "T", xlim = c(0.5, 1.5))
M_hist <- histogram(M, title = "M", xlim = c(0.5, 1.5))
N_hist <- histogram(N, title = "N", xlim = c(0.5, 1.5))
L_hist <- histogram(L, title = "L", xlim = c(0.5, 1.5))
H_hist <- histogram(H, title = "H", xlim = c(0.5, 1.5))

plot <- ggarrange(S_hist, T_hist, M_hist, N_hist, L_hist, H_hist, ncol = 2, nrow = 3)
ggsave(plot, filename = 'threshold_free_clustering/figs/weight_scores_one_sample.png', width = 12, height = 10)

talker <- readRDS('threshold_free_clustering/data/weight_scores/talker.RDS')
meaning <- readRDS('threshold_free_clustering/data/weight_scores/meaning.RDS')
constraint <- readRDS('threshold_free_clustering/data/weight_scores/constraint.RDS')

talker_hist <- histogram(talker, title = "Talker", xlim = c(0.5, 1.5))
meaning_hist <- histogram(meaning, title = "Meaning", xlim = c(0.5, 1.5))
constraint_hist <- histogram(constraint, title = "Constraint", xlim = c(0.5, 1.5))

plot <- ggarrange(talker_hist, meaning_hist, constraint_hist, ncol = 1, nrow = 3)
ggsave(plot, filename = 'threshold_free_clustering/figs/weight_scores_two_sample.png', width = 8, height = 10)
