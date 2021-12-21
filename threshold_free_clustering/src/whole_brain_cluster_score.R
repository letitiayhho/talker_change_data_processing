#!/usr/bin/env Rscript
#SBATCH --time=01:00:00
#SBATCH --partition=broadwl
#SBATCH --ntasks=1
#SBATCH	--mem-per-cpu=2G

library("dplyr")
library("ggplot2")
library("ggpubr")
source("tools/functions.R")
source("threshold_free_clustering/src/functions.R")

load("8_wilcoxon/data/full_wilcoxon_results.RData")

# Compute pairwise distances
coordinates <- get_coordinates()
distances <- get_pairwise_distances(coordinates)
distances_hist <- get_histogram_of_pairwise_distances(distances, title = "Histogram of pairwise distances")
ggsave(distances_hist, filename = 'threshold_free_clustering/figs/distances.png', width = 8, height = 6)

# Get distance score by standardizing then taking the inverse of the distance
distance_scores <- get_distance_score(distances)
inverse_distances_hist <- get_histogram_of_pairwise_distances(distance_scores, title = "Histogram of inverse and normalized pairwise distances")
ggsave(inverse_distances_hist, filename = 'threshold_free_clustering/figs/inverse_normed_distances.png', width = 8, height = 6)

# Compute weight scores
S_weight_scores <- sigmoid(S_w$w)
S_hist <- histogram(S_weight_scores, title = "S", xlim = c(0.5, 1.5))
T_weight_scores <- sigmoid(T_w$w)
T_hist <- histogram(T_weight_scores, title = "T", xlim = c(0.5, 1.5))
M_weight_scores <- sigmoid(M_w$w)
M_hist <- histogram(M_weight_scores, title = "M", xlim = c(0.5, 1.5))
N_weight_scores <- sigmoid(N_w$w)
N_hist <- histogram(N_weight_scores, title = "N", xlim = c(0.5, 1.5))
L_weight_scores <- sigmoid(L_w$w)
L_hist <- histogram(L_weight_scores, title = "L", xlim = c(0.5, 1.5))
H_weight_scores <- sigmoid(H_w$w)
H_hist <- histogram(H_weight_scores, title = "H", xlim = c(0.5, 1.5))
plot <- ggarrange(S_hist, T_hist, M_hist, N_hist, L_hist, H_hist, ncol = 2, nrow = 3)
ggsave(plot, filename = 'threshold_free_clustering/figs/weight_scores.png', width = 12, height = 10)

# Compute cluster scores with distance and weight scores
S_cluster_scores <- get_cluster_scores(distance_scores, S_weight_scores)
T_cluster_scores <- get_cluster_scores(distance_scores, T_weight_scores)
M_cluster_scores <- get_cluster_scores(distance_scores, M_weight_scores)
N_cluster_scores <- get_cluster_scores(distance_scores, N_weight_scores)
L_cluster_scores <- get_cluster_scores(distance_scores, L_weight_scores)
H_cluster_scores <- get_cluster_scores(distance_scores, H_weight_scores)

# Permute channel weights
S_permuted <- permute_clusters(distance_scores, S_weight_scores, 1000)
T_permuted <- permute_clusters(distance_scores, T_weight_scores, 1000)
M_permuted <- permute_clusters(distance_scores, M_weight_scores, 1000)
N_permuted <- permute_clusters(distance_scores, N_weight_scores, 1000)
L_permuted <- permute_clusters(distance_scores, L_weight_scores, 1000)
H_permuted <- permute_clusters(distance_scores, H_weight_scores, 1000)

save(S_cluster_scores, T_cluster_scores, M_cluster_scores, N_cluster_scores, L_cluster_scores, H_cluster_scores,
     S_permuted, T_permuted, M_permuted, N_permuted, L_permuted, H_permuted,
     file = "threshold_free_clustering/data/one-sample.RData")


# Plot permutation test results
S_hist <- histogram(S_permuted$sum, S_cluster_scores$sum, title = "Same")
T_hist <- histogram(T_permuted$sum, T_cluster_scores$sum, title = "Different")
M_hist <- histogram(M_permuted$sum, M_cluster_scores$sum, title = "Meaningful")
N_hist <- histogram(N_permuted$sum, N_cluster_scores$sum, title = "Nonsense")
L_hist <- histogram(L_permuted$sum, L_cluster_scores$sum, title = "Low constraint")
H_hist <- histogram(H_permuted$sum, H_cluster_scores$sum, title = "High constraint")
plot <- ggarrange(S_hist, T_hist, M_hist, N_hist, L_hist, H_hist, ncol = 2, nrow = 3)
ggsave(plot, filename = 'threshold_free_clustering/figs/permutations.png', width = 12, height = 10)

## Between conditions
# Talker
talker_weight_scores <- sigmoid(talker_w$w)
talker_cluster_scores <- get_cluster_scores(distance_scores, talker_weight_scores)
talker_permuted <- permute_clusters(distance_scores, talker_weight_scores, 1000)
talker_hist <- histogram(talker_permuted$sum, talker_cluster_scores$sum, title = "Talker")

# Meaning
meaning_weight_scores <- sigmoid(meaning_w$w)
meaning_cluster_scores <- get_cluster_scores(distance_scores, meaning_weight_scores)
meaning_permuted <- permute_clusters(distance_scores, meaning_weight_scores, 1000)
meaning_hist <- histogram(meaning_permuted$sum, meaning_cluster_scores$sum, title = "Meaning")

# Constraint
constraint_weight_scores <- sigmoid(constraint_w$w)
constraint_cluster_scores <- get_cluster_scores(distance_scores, constraint_weight_scores)
constraint_permuted <- permute_clusters(distance_scores, constraint_weight_scores, 1000)
constraint_hist <- histogram(constraint_permuted$sum, constraint_cluster_scores$sum, title = "Constraint")

condition_hist <- ggarrange(talker_hist, meaning_hist, constraint_hist, ncol = 1, nrow = 3)
ggsave(condition_hist, filename = 'threshold_free_clustering/figs/compare_conditions_permutations.png', width = 8, height = 10)
save(talker_cluster_scores, talker_permuted, meaning_cluster_scores, meaning_permuted,
     constraint_cluster_scores, constraint_permuted, file = "threshold_free_clustering/data/two-sample.RData")

