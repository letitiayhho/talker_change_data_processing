#!/usr/bin/env Rscript

setwd("/Users/letitiaho/src/talker_change_data_processing/")
source("5_cluster_cross_correlations/src/functions.R")

wilcoxon_results_fpath = "4_test_cross_correlations/data/wilcoxon/two.sided_wilcoxon_results.RData"
load(wilcoxon_results_fpath)

# Normalize data by max and min of whole data set
overall <- normalize_by(overall_w$w, max(overall_w$w), min(overall_w$w))

max_one_sample <- max(S_w$w, T_w$w, M_w$w, N_w$w, L_w$w, H_w$w)
min_one_sample <- min(S_w$w, T_w$w, M_w$w, N_w$w, L_w$w, H_w$w)
S <- normalize_by(S_w$w, max_one_sample, min_one_sample)
T <- normalize_by(T_w$w, max_one_sample, min_one_sample)
M <- normalize_by(M_w$w, max_one_sample, min_one_sample)
N <- normalize_by(N_w$w, max_one_sample, min_one_sample)
L <- normalize_by(L_w$w, max_one_sample, min_one_sample)
H <- normalize_by(H_w$w, max_one_sample, min_one_sample)

max_two_sample <- max(talker_w$w, meaning_w$w, constraint_w$w)
min_two_sample <- min(talker_w$w, meaning_w$w, constraint_w$w)
talker <- normalize_by(talker_w$w, max_two_sample, min_two_sample)
meaning <- normalize_by(meaning_w$w, max_two_sample, min_two_sample)
constraint <- normalize_by(constraint_w$w, max_two_sample, min_two_sample)

# SL <- normalize(xcorr$SL)
# SH <- normalize(xcorr$SH)
# TL <- normalize(xcorr$TL)
# TH <- normalize(xcorr$TH)
# NL <- normalize(xcorr$NL)
# NH <- normalize(xcorr$NH)
# ML <- normalize(xcorr$ML)
# MH <- normalize(xcorr$MH)

weight_scores <- list("overall" = overall,
                      "S" = S,
                      "T" = T,
                      "M" = M,
                      "N" = N,
                      "L" = L,
                      "H" = H,
                      "talker" = talker,
                      "meaning" = meaning,
                      "constraint" = constraint
                      # "SL" = SL,
                      # "SH" = SH,
                      # "TL" = TL,
                      # "TH" = TH,
                      # "NL" = NL,
                      # "NH" = NH,
                      # "ML" = ML,
                      # "MH" = MH,
                      )

save_filepath <- paste("5_cluster_cross_correlations/data/weight_scores/weight_scores_two.sided.RDS", sep = "")
saveRDS(weight_scores, file = save_filepath)