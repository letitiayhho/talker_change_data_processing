subset <- function(data, formants = NaN, condition, level) {
  channel_columns = paste("X", 1:128, sep = "")
  
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
    if (level == "L")
      return(filter(data, constraint == "L") %>% select(all_of(channel_columns)))
    return(filter(data, constraint == "H") %>% select(all_of(channel_columns)))
  }
}

# Function for running a one-sample t-test and saving the p-value, t-statistic, and df
get_one_sample_t <- function(data) {
  t <- apply(data, MARGIN = 2, function(channel) {t.test(channel)$statistic})
  df <- apply(data, MARGIN = 2, function(channel) {t.test(channel)$parameter})
  p <- apply(data, MARGIN = 2, function(channel) {t.test(channel)$p.value})
  return(data.frame("t" = t, "df" = df, "p" = p))
}

# Taking the p-values of the t-test results and assigning a 1 if sig, 0 if not
get_hot <- function(data, alpha = 0.05) {
  hot <- c()
  hot[data$p < alpha] <- 1
  hot[data$p >= alpha] <- 0
  return(hot)
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
get_combined_frequency_table <- function(xcorr, conv, title = NULL) {
  xcorr_freqs <- get_frequency_counts(xcorr)
  conv_freqs <- get_frequency_counts(conv)
  table <- kable(cbind(xcorr_freqs, conv_freqs), caption = title) %>%
    kable_styling(c("striped", "condensed"), full_width = F)
  return(table)
}