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

plot_average_xcorrs <- function(condition_xcorrs, fname, p) { # should be n_subs x n_chans 
  means <- c(colMeans(as.matrix(condition_xcorrs)))
  sds <- c(sapply(condition_xcorrs, sd))
  # p <- (1/p)/max(1/p) 
  
  # order by inverse p-value size
  means <- means[order(p)]
  sds <- sds[order(p)]
  p <- p[order(p)]
  df <- data.frame(chans <- c(1:128), means, sds, p)
  
  plot <- ggplot(df, aes(x = chans, y = means)) +
    geom_point() +
    geom_errorbar(aes(ymin = means - sds, ymax = means + sds)) +
    ylab('Average cross correlation') +
    xlab('Channel') +
    ylim(-1, 1) + 
    geom_point(aes(x = chans, y = p))
  ggsave(plot = plot, filename = fname, width = 6, height = 3.5)
  return(plot)
}

get_one_sample_subject_wilcoxon <- function(condition_xcorrs) {
  sub_means <- c(rowMeans(as.matrix(condition_xcorrs)))
  w <- wilcox.test(sub_means)
  return(list('w' = w$statistic,
              'p' = w$p.value))
}

get_two_sample_subject_wilcoxon <- function(condition1_xcorrs, condition2_xcorrs) {
  cond1_sub_means <- c(rowMeans(as.matrix(condition1_xcorrs)))
  cond2_sub_means <- c(rowMeans(as.matrix(condition2_xcorrs)))
  w <- wilcox.test(cond1_sub_means, y = cond2_sub_means)
  return(list('w' = w$statistic,
              'p' = w$p.value))
}

get_subject_averages <- function(data) {
  channel_labels <- paste("X", as.character(1:128), sep = "")
  data <-  data %>%
    group_by(subject_number) %>%
    summarise_at(vars(all_of(channel_labels)), mean) %>%
    select(all_of(channel_labels))
  return(data)
}

get_one_sample_t_for_each_channel <- function(data) {
  t <- apply(data, MARGIN = 2, function(channel) {t.test(channel)$statistic})
  df <- apply(data, MARGIN = 2, function(channel) {t.test(channel)$parameter})
  p <- apply(data, MARGIN = 2, function(channel) {t.test(channel)$p.value})
  return(data.frame("t" = t, "df" = df, "p" = p))
}

get_one_sample_wilcoxon_for_each_channel <- function(data, alt) {
  w <- apply(data, MARGIN = 2, function(channel) {wilcox.test(channel, exact = TRUE, alternative = c(alt))$statistic})
  p <- apply(data, MARGIN = 2, function(channel) {wilcox.test(channel, exact = TRUE, alternative = c(alt))$p.value})
  return(data.frame("w" = w, "p" = p))
}

get_two_sample_t_for_each_channel <- function(group1, group2) {
  t <- mapply(function(x, y) {t.test(x, y)$statistic}, group1, group2)
  df <- mapply(function(x, y) {t.test(x, y)$parameter}, group1, group2)
  p <- mapply(function(x, y) {t.test(x, y)$p.value}, group1, group2)
  return(data.frame("t" = t, "df" = df, "p" = p))
}

get_two_sample_wilcoxon_for_each_channel <- function(group1, group2, paired) {
  w <- mapply(function(x, y) {wilcox.test(x, y, paired = paired, exact = TRUE)$statistic}, group1, group2)
  p <- mapply(function(x, y) {wilcox.test(x, y, paired = paired, exact = TRUE)$p.value}, group1, group2)
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