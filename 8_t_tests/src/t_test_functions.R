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