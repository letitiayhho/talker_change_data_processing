## Packages
library("dplyr")
library("kableExtra")



## Generic data wrangling

# Load data
load_data <- function(method, formants = FALSE) {
  if (method == "xcorr") {
    if (formants)
      return(read.csv("data/aggregate/cross_correlation_formant_data.csv"))
    return(read.csv("data/aggregate/cross_correlation_data.csv"))
  }
  if (method == "conv") {
    if (formants)
      return(read.csv("data/aggregate/convolution_formant_data.csv"))
    return(read.csv("data/aggregate/convolution_data.csv"))
  }
  stop("Invalid method, options are \"xcorr\" or \"conv\"")
}

# Function for subsetting data based on condition and level
subset <- function(data, formants = NaN, condition, level) {
  channel_columns = paste("X", 1:128, sep = "")
  
  # Subset by formant if specified
  if (formants == "f0") {
    data <- filter(data, formant == "f0")
  } else if (formants == "f1_f2") {
    data <- filter(data, formant == "f1_f2") 
  } else if (formants == "f3") {
    data <- filter(data, formant == "f3")
  }
  
  # Subset by condition if specified
  if (condition == "talker") {
    if (level == "S")
      return(filter(data, talker == "S") %>% select(all_of(channel_columns)))
    return(filter(data, talker == "T") %>% select(all_of(channel_columns)))
  } else if (condition == "meaning") {
    if (level == "M")
      return(filter(data, meaning == "M") %>% select(all_of(channel_columns)))
    return(filter(data, meaning == "N") %>% select(all_of(channel_columns)))
  } else if (condition == "constraint") {
    if (level == "S")
      return(filter(data, constraint == "S") %>% select(all_of(channel_columns)))
    return(filter(data, constraint == "G") %>% select(all_of(channel_columns)))
  }
}



## Statistical tests

# Function for running a one-sample t-test and saving the p-value, t-statistic, and df
get_one_sample_t <- function(data) {
  t <- apply(data, MARGIN = 2, function(channel) {t.test(channel)$statistic})
  df <- apply(data, MARGIN = 2, function(channel) {t.test(channel)$parameter})
  p <- apply(data, MARGIN = 2, function(channel) {t.test(channel)$p.value})
  return(data.frame("t" = t, "df" = df, "p" = p))
}

# Function for running a paired-samples t-test and saving the p-value, t-statistic, and df
get_paired_samples_t <- function(group1, group2) {
  t <- mapply(function(x, y) {t.test(x, y, paired = TRUE)$statistic}, group1, group2)
  df <- mapply(function(x, y) {t.test(x, y, paired = TRUE)$parameter}, group1, group2)
  p <- mapply(function(x, y) {t.test(x, y, paired = TRUE)$p.value}, group1, group2)
  return(data.frame("t" = t, "df" = df, "p" = p))
}

# Function for running an independent-samples t-test and saving the p-value, t-statistic, and df
get_ind_samples_t <- function(group1, group2) { # mostly to replicate JAMOVI t-test results
  t <- mapply(function(x, y) {t.test(x, y, paired = FALSE, var.equal = TRUE)$statistic}, group1, group2)
  df <- mapply(function(x, y) {t.test(x, y, paired = FALSE, var.equal = TRUE)$parameter}, group1, group2)
  p <- mapply(function(x, y) {t.test(x, y, paired = FALSE, var.equal = TRUE)$p.value}, group1, group2)
  return(data.frame("t" = t, "df" = df, "p" = p))
}

# Taking the p-values of the t-test results and assigning a 1 if sig, 0 if not
get_hot <- function(data) {
  hot <- c()
  hot[data$p < 0.1] <- 1
  hot[data$p > 0.1] <- 0
  return(hot)
}

# Comparing two hot vectors and assigning a 1 if the values match, 0 if not
get_match <- function(group1, group2) {
  match <- c()
  match <- ifelse(group1 == 1 & group2 == 1, 1, 0)
  return(match)
}



## Formatting data tables for display

# Get a single frequency table for results of the t-tests
get_frequency_counts <- function(data) {
  hot <- get_hot(data)
  counts <- margin.table(table(hot), 1)
  proportions <- prop.table(table(hot))
  if (dim(counts) == 1) {return(data.frame("counts" = c(counts[1], 0), "proportion" = c(proportions[1], 0)))}
  else {return(data.frame("counts" = c(counts[1], counts[2]), "proportion" = c(proportions[1], proportions[2])))}
}

get_frequency_table <- function(xcorr, title = NULL) {
  counts <- get_frequency_counts(xcorr)
  kable(counts, caption = title) %>%
    kable_styling(c("striped", "condensed"), full_width = F)
}

# Get a frequency table that combines results for xcorr and conv
get_combined_frequency_table <- function(xcorr, conv, title = NULL, 
                                         group1 = "Cross-correlation", group2 = "Convolution") {
  xcorr_freqs <- get_frequency_counts(xcorr)
  conv_freqs <- get_frequency_counts(conv)
  kable(cbind(xcorr_freqs, conv_freqs), caption = title) %>%
    kable_styling(c("striped", "condensed"), full_width = F) %>%
    add_header_above(c(" ", group1 = 2, group2 = 2))
}

# Get a frequency table that combines results for the three formant levels
get_formant_frequency_table <- function(f0, f1_f2, f3, title = NULL) {
  f0_freqs <- get_frequency_counts(f0)
  f1_f2_freqs <- get_frequency_counts(f1_f2)
  f3_freqs <- get_frequency_counts(f3)
  kable(cbind(f0_freqs, f1_f2_freqs, f3_freqs), caption = title) %>%
    kable_styling(c("striped", "condensed"), full_width = F) %>%
    add_header_above(c(" ", "F0" = 2, "F1 + F2" = 2, "F3" = 2))
}