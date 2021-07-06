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

get_one_sample_t <- function(data) {
  t <- apply(data, MARGIN = 2, function(channel) {t.test(channel)$statistic})
  df <- apply(data, MARGIN = 2, function(channel) {t.test(channel)$parameter})
  p <- apply(data, MARGIN = 2, function(channel) {t.test(channel)$p.value})
  return(data.frame("t" = t, "df" = df, "p" = p))
}

get_two_sample_t <- function(group1, group2) {
  t <- mapply(function(x, y) {t.test(x, y)$statistic}, group1, group2)
  df <- mapply(function(x, y) {t.test(x, y)$parameter}, group1, group2)
  p <- mapply(function(x, y) {t.test(x, y)$p.value}, group1, group2)
  return(data.frame("t" = t, "df" = df, "p" = p))
}

get_lag_distribution <- function(group1, group2, labels, channel) {
  labels <- c(rep(labels[1], nrow(group1)), rep(labels[2], nrow(group2)))
  data <- data.frame(labels, lags = c(group1[[paste("X", channel, sep = "")]], group2[[paste("X", channel, sep = "")]]))
  plot <- ggplot(data = data, aes(lags, colour = labels)) +
    geom_density() +
    ggtitle(paste("Channel", channel))
  return(plot)
}