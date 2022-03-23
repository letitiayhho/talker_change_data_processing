#!/usr/bin/env Rscript

setwd("/Users/letitiaho/src/talker_change_data_processing/")
source("5_cluster_cross_correlations/src/functions.R")

xcorr <- readRDS(file = "5_cluster_cross_correlations/data/wilcoxon/wilcoxon.RDS")

overall <- normalize(xcorr$overall)
S <- normalize(xcorr$S)
T <- normalize(xcorr$T)
M <- normalize(xcorr$M)
N <- normalize(xcorr$N)
L <- normalize(xcorr$L)
H <- normalize(xcorr$H)
talker <- normalize(xcorr$talker)
meaning <- normalize(xcorr$meaning)
constraint <- normalize(xcorr$constraint)
SL <- normalize(xcorr$SL)
SH <- normalize(xcorr$SH)
TL <- normalize(xcorr$TL)
TH <- normalize(xcorr$TH)
NL <- normalize(xcorr$NL)
NH <- normalize(xcorr$NH)
ML <- normalize(xcorr$ML)
MH <- normalize(xcorr$MH)

weight_scores <- list("overall" = overall,
                      "S" = S,
                      "T" = T,
                      "M" = M,
                      "N" = N,
                      "L" = L,
                      "H" = H,
                      "talker" = talker,
                      "meaning" = meaning,
                      "constraint" = constraint,
                      "SL" = SL,
                      "SH" = SH,
                      "TL" = TL,
                      "TH" = TH,
                      "NL" = NL,
                      "NH" = NH,
                      "ML" = ML,
                      "MH" = MH)

save_filepath <- paste("5_cluster_cross_correlations/data/weight_scores/weight_scores.RDS", sep = "")
saveRDS(weight_scores, file = save_filepath)