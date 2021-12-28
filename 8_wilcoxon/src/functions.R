subset <- function(data, talker = NaN, meaning = NaN, constraint = NaN, keepLabels = FALSE, keepSubjNum = TRUE) {
  channel_columns = paste("X", as.character(1:128), sep = "")
  if (talker == "S") {
    data <- filter(data, talker == "S")
  } else if (talker == "T") {
    data <- filter(data, talker == "T")
  }
  if (meaning == "M") {
    data <- filter(data, meaning == "M")
  } else if (meaning == "N") {
    data <- filter(data, meaning == "N")
  }
  if (constraint == "L") {
    data <- filter(data, constraint == "L")
  } else if (constraint == "H") {
    data <- filter(data, constraint == "H")
  }
  if (keepLabels) {
    data <- select(data, all_of(c("subject_number", "talker", "meaning", "constraint", channel_columns)))
  } else if (keepSubjNum) {
    data <- select(data, all_of(c("subject_number", channel_columns)))
  }  else {
    data <- select(data, all_of(channel_columns))
  }
  return(data)
}

get_subject_averages <- function(data) {
  channel_labels <- paste("X", as.character(1:128), sep = "")
  data <-  data %>%
    group_by(subject_number) %>%
    summarise_at(vars(all_of(channel_labels)), mean) %>%
    select(all_of(channel_labels))
  return(data)
}

get_one_sample_t <- function(data) {
  t <- apply(data, MARGIN = 2, function(channel) {t.test(channel)$statistic})
  df <- apply(data, MARGIN = 2, function(channel) {t.test(channel)$parameter})
  p <- apply(data, MARGIN = 2, function(channel) {t.test(channel)$p.value})
  return(data.frame("t" = t, "df" = df, "p" = p))
}

get_one_sample_wilcoxon <- function(data) {
  w <- apply(data, MARGIN = 2, function(channel) {wilcox.test(channel)$statistic})
  p <- apply(data, MARGIN = 2, function(channel) {wilcox.test(channel)$p.value})
  return(data.frame("w" = w, "p" = p))
}

get_two_sample_t <- function(group1, group2) {
  t <- mapply(function(x, y) {t.test(x, y)$statistic}, group1, group2)
  df <- mapply(function(x, y) {t.test(x, y)$parameter}, group1, group2)
  p <- mapply(function(x, y) {t.test(x, y)$p.value}, group1, group2)
  return(data.frame("t" = t, "df" = df, "p" = p))
}

get_two_sample_wilcoxon <- function(group1, group2) {
  w <- mapply(function(x, y) {wilcox.test(x, y)$statistic}, group1, group2)
  p <- mapply(function(x, y) {wilcox.test(x, y)$p.value}, group1, group2)
  return(data.frame("w" = w, "p" = p))
}

get_lag_distribution <- function(group1, group2, labels, channel) {
  labels <- c(rep(labels[1], nrow(group1)), rep(labels[2], nrow(group2)))
  data <- data.frame(labels, lags = c(group1[[paste("X", channel, sep = "")]], group2[[paste("X", channel, sep = "")]]))
  plot <- ggplot(data = data, aes(lags, colour = labels)) +
    geom_density() +
    ggtitle(paste("Channel", channel))
  return(plot)
}