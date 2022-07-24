#!/usr/bin/env Rscript

setwd("/Users/letitiaho/src/talker_change_data_processing/")
library("dplyr")
library("ggplot2")
library("ggpubr")
library("kableExtra")
source("tools/functions.R")
source("4_test_cross_correlations/src/functions.R")

# Import data
xcorr <- read.csv(file = "3_cross_correlate/data/average.csv")

#### One-sample t-tests for overall tracking

overall <- get_subject_averages(xcorr)
overall_w <- get_one_sample_wilcoxon(overall)

#### One-sample wilcoxon for each condition

S <- subset(xcorr, talker = "S") %>% get_subject_averages()
T <- subset(xcorr, talker = "T") %>% get_subject_averages()
M <- subset(xcorr, meaning = "M") %>% get_subject_averages()
N <- subset(xcorr, meaning = "N") %>% get_subject_averages()
L <- subset(xcorr, constraint = "L") %>% get_subject_averages()
H <- subset(xcorr, constraint = "H") %>% get_subject_averages()

S_w <- get_one_sample_wilcoxon(S)
T_w <- get_one_sample_wilcoxon(T)
M_w <- get_one_sample_wilcoxon(M)
N_w <- get_one_sample_wilcoxon(N)
L_w <- get_one_sample_wilcoxon(L)
H_w <- get_one_sample_wilcoxon(H)

#### Two-sample Wilcoxon

talker_w <- get_two_sample_wilcoxon(S, T)
meaning_w <- get_two_sample_wilcoxon(M, N)
constraint_w <- get_two_sample_wilcoxon(L, H)

#### Wilcoxon with interaction by constraint

# Subset talker
SL <- subset(xcorr, talker = "S", constraint = "L") %>% get_subject_averages()
SH <- subset(xcorr, talker = "S", constraint = "H") %>% get_subject_averages()
TL <- subset(xcorr, talker = "T", constraint = "L") %>% get_subject_averages()
TH <- subset(xcorr, talker = "T", constraint = "H") %>% get_subject_averages()

# Subset meaning
ML <- subset(xcorr, meaning = "M", constraint = "L") %>% get_subject_averages()
MH <- subset(xcorr, meaning = "M", constraint = "H") %>% get_subject_averages()
NL <- subset(xcorr, meaning = "N", constraint = "L") %>% get_subject_averages()
NH <- subset(xcorr, meaning = "N", constraint = "H") %>% get_subject_averages()

# One-sample t-tests for talker
SL_w <- get_one_sample_wilcoxon(SL)
SH_w <- get_one_sample_wilcoxon(SH)
TL_w <- get_one_sample_wilcoxon(TL)
TH_w <- get_one_sample_wilcoxon(TH)

# One-sample t-tests for meaning
ML_w <- get_one_sample_wilcoxon(ML)
MH_w <- get_one_sample_wilcoxon(MH)
NL_w <- get_one_sample_wilcoxon(NL)
NH_w <- get_one_sample_wilcoxon(NH)

# Two-sample t-tests for interactions
talker_L_w <- get_two_sample_wilcoxon(SL, TL)
talker_H_w <- get_two_sample_wilcoxon(SH, TH)
meaning_L_w <- get_two_sample_wilcoxon(ML, NL)
meaning_H_w <- get_two_sample_wilcoxon(MH, NH)

#### Save vars

ws <- list("overall" = overall_w$w,
           "S" = S_w$w, 
           "T" = T_w$w, 
           "M" = M_w$w, 
           "N" = N_w$w, 
           "L" = L_w$w, 
           "H" = H_w$w, 
           "talker" = talker_w$w, 
           "meaning" = meaning_w$w, 
           "constraint" = constraint_w$w, 
           "SL" = SL_w$w,
           "SH" = SH_w$w,
           "TL" = TL_w$w,
           "TH" = TH_w$w,
           "ML" = ML_w$w,
           "MH" = MH_w$w,
           "NL" = NL_w$w,
           "NH" = NH_w$w)
saveRDS(ws, "5_cluster_cross_correlations/data/wilcoxon/wilcoxon.RDS")
