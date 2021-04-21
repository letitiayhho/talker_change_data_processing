# Load libraries
library(dplyr)
library(readr)
library(rethinking)

# Get list of models
channel_numbers <- as.numeric(parse_number(models))

# Create data frames containing params of all models
p <- c()
difference <- c()

# Loop over and load each model and add params to a data frame
for (i in 1:128) {
  
  # Load the model
  model <- paste("channel_", i, ".RDa", sep = "")
  print(paste("Loading ", model, sep = ""))
  load(file = paste("5_rms/data/models/multilevel_models/", model, sep = ""))
  
  # Sample betas from the posterior to calculate the probability
  # of beta from one fit overlapping with the other
  posterior <- extract.samples(model, n = 1e4)
  b_same_talker <- posterior$b[,1]
  b_different_talker <- posterior$b[,2]
  p <- c(p, mean(b_same_talker > b_different_talker))

  # Calculate the difference between betas
  params <- precis(model, depth = 2)
  b_bar_same_talker <- params$mean[1]
  b_bar_different_talker <- params$mean[2]
  difference <- c(difference, b_bar_same_talker - b_bar_different_talker)
}

# Save
df <- data.frame(p = p, difference = difference)
save(df, file = paste("5_rms/data/multilevel_beta_comparison.RDa", sep = ""))
