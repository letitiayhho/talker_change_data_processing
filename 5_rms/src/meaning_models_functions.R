remove_outliers <- function(array, sds) {
  # Removes only values above a certain threshold since below 3 sds is negative
  mean_val <- mean(array)
  sd_val <- sd(array)
  indexes_of_values_above_n_sds <- which(array > mean_val + sd_val*sds)
  array[indexes_of_values_above_n_sds] <- NA
  return(array)
}

clean_data <- function(rms, xcorr, channel_number) {
  channel_number <- as.character(channel_number)
  
  # Extract xcorr values for specified channel
  raw_df <- data.frame(rms = rms,
                       xcorr = xcorr[[paste('maximum', channel_number, sep = "")]],
                       meaning = xcorr$meaning)
  
  # Remove outliers
  rms <- remove_outliers(raw_df$rms, 3)
  xcorr <- remove_outliers(raw_df$xcorr, 3)
  
  # Change rms and xcorr to log scale
  raw_df$log_rms <- log(rms)
  raw_df$log_xcorr <- log(xcorr)
  
  # Remove NAs
  clean_df <- raw_df[complete.cases(raw_df),]
  
  return(clean_df)
}

get_multilevel_model <- function(df) {
  # Create data frame for model 
  ulam_df <- list(log_rms = df$log_rms,
                  log_xcorr = df$log_xcorr,
                  meaning = ifelse(df$meaning == "M", 1, 2)) # Recode meaningful to 1 nonsense to 2 to get link() to work
  
  # Fit model
  meaning_model <- ulam(
    alist(
      log_xcorr ~ dnorm(mu, sigma),
      mu <- a[meaning] + b[meaning]*log_rms,
      c(a, b)[meaning] ~ multi_normal(c(a_bar, b_bar) , Rho , sigma_meaning),
      a_bar ~ dnorm(5, 5),
      b_bar ~ dnorm(0, 5),
      sigma_meaning ~ dexp(1),
      sigma ~ dexp(1),
      Rho ~ lkj_corr(2)
    ), data = ulam_df, chains = 4, cores = 4)
  
  return(meaning_model)
}

get_model_summary <- function(model) {
  return(precis(model, depth = 2))
}

get_figure <- function(model, clean_df) {
  rms_seq <- seq(from = 0, to = 3, by = 0.1)
  
  # Extract posterior for meaningful
  s_mu <- link(model, data = data.frame(meaning = 1, log_rms = rms_seq))
  s_mu_mean <- apply(s_mu, 2, mean)
  s_mu_ci <- apply(s_mu, 2, PI, prob = 0.95)
  
  # Extract posterior for nonsense
  t_mu <- link(model, data = data.frame(meaning = 2, log_rms = rms_seq))
  t_mu_mean <- apply(t_mu, 2, mean)
  t_mu_ci <- apply(t_mu, 2, PI, prob = 0.95)
  
  # Generate a data frame for plotting
  plot_df <- data.frame(seq = rms_seq,
                        t_mu_mean = t_mu_mean,
                        s_mu_mean = s_mu_mean,
                        t_ci_min = t_mu_ci[1,],
                        t_ci_max = t_mu_ci[2,],
                        s_ci_min = s_mu_ci[1,],
                        s_ci_max = s_mu_ci[2,])
  
  # Plot
  p <- ggplot(NULL) +
    ylim(0, 8) + 
    xlim(0, 3) +
    
    # Plot raw data
    geom_point(data = clean_df, alpha = 0.5, stroke = 0, size = 2, aes(x = log_rms, y = log_xcorr, color = factor(meaning))) +
    scale_color_manual(values = c("#2D708EFF", "#29AF7FFF")) +
    
    # Plot lines with 95% CI
    geom_line(data = plot_df, size = 0.8, color = '#20A387FF', aes(x = seq, y = t_mu_mean)) +
    geom_line(data = plot_df, size = 0.8, color = '#33638DFF', aes(x = seq, y = s_mu_mean)) +
    geom_ribbon(data = plot_df, aes(x = rms_seq, ymin = t_ci_min, ymax = t_ci_max), fill = "#29AF7FFF", alpha = 0.2) +
    geom_ribbon(data = plot_df, aes(x = rms_seq, ymin = s_ci_min, ymax = s_ci_max), fill = "#2D708EFF", alpha = 0.2) 
  
  return(p)
}

save_figure_as_jpg <- function(figure, file_path) {
  # Open jpeg file
  jpeg(file_path)
  
  # Create plot
  figure
  
  # Close the file
  while (!is.null(dev.list())) dev.off()
}

get_model_for_one_channel <- function(rms, xcorr, channel_number) {
  # Clean data
  clean_df <- clean_data(rms, xcorr, channel_number)
  
  # Run and save model
  model <- get_multilevel_model(clean_df)
  model_path <- paste('5_rms/data/models/meaning_models/channel_', as.character(channel_number), '.RDa', sep = "")
  save(model, file = model_path)
  
  # Plot and save figure
  figure_path <- paste("5_rms/figs/meaning_models/channel_", as.character(channel_number), '.png', sep = "")
  figure <- get_figure(model, clean_df)
  ggsave(figure_path, plot = figure)
  
  # Can't return
  return(model)
}

get_model_for_multiple_channels <- function(rms, xcorr, start, end) {
  for (channel_number in start:end) {
    model <- get_model_for_one_channel(left_superior_parietal, xcorr, channel_number)
  }
}
