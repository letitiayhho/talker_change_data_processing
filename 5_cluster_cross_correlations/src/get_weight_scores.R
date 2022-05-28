#!/usr/bin/env Rscript

setwd("/Users/letitiaho/src/talker_change_data_processing/")
source("5_cluster_cross_correlations/src/functions.R")

xcorr <- readRDS(file = "5_cluster_cross_correlations/data/wilcoxon/wilcoxon.RDS")

# Normalize data by max and min of whole data set
# overall <- normalize_by(xcorr$overall, max(xcorr$overall), min(xcorr$overall))
overall <- normalize_by(xcorr$overall, max_one_sample, min_one_sample)

max_one_sample <- max(xcorr$S, xcorr$T, xcorr$M, xcorr$N, xcorr$L, xcorr$H, xcorr$overall)
min_one_sample <- min(xcorr$S, xcorr$T, xcorr$M, xcorr$N, xcorr$L, xcorr$H, xcorr$overall)
# max_one_sample <- max(xcorr$S, xcorr$T, xcorr$M, xcorr$N, xcorr$L, xcorr$H)
# min_one_sample <- min(xcorr$S, xcorr$T, xcorr$M, xcorr$N, xcorr$L, xcorr$H)
S <- normalize_by(xcorr$S, max_one_sample, min_one_sample) + 0.5
T <- normalize_by(xcorr$T, max_one_sample, min_one_sample) + 0.5
M <- normalize_by(xcorr$M, max_one_sample, min_one_sample) + 0.5
N <- normalize_by(xcorr$N, max_one_sample, min_one_sample) + 0.5
L <- normalize_by(xcorr$L, max_one_sample, min_one_sample) + 0.5
H <- normalize_by(xcorr$H, max_one_sample, min_one_sample) + 0.5

max_two_sample <- max(xcorr$talker, xcorr$meaning, xcorr$constraint)
min_two_sample <- min(xcorr$talker, xcorr$meaning, xcorr$constraint)
talker <- normalize_by(xcorr$talker, max_two_sample, min_two_sample)
meaning <- normalize_by(xcorr$meaning, max_two_sample, min_two_sample)
constraint <- normalize_by(xcorr$constraint, max_two_sample, min_two_sample)

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

save_filepath <- paste("5_cluster_cross_correlations/data/weight_scores/weight_scores.RDS", sep = "")
saveRDS(weight_scores, file = save_filepath)