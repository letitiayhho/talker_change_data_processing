# Load libraries
library(dplyr)
library(readr)
library(rethinking)

# Get list of models
models <- dir(path = paste("data/5_b_rms/models/simple_linear_models", sep = ""))
channel_numbers <- as.numeric(parse_number(models))

# Create data frames containing params of all models
means <- data.frame()
sds <- data.frame()

# Loop over and load each model and add params to a data frame
for (i in 1:128) {
  
  # Load the model
  load(file = paste("data/5_b_rms/models/simple_linear_models/", models[i], sep = ""))
  
  # Horizontally concat into a data frame
  params <- precis(model, depth = 2)
  means <- rbind(means, params$mean)
  sds <- rbind(sds, params$sd)
}

# Clean up data frame
colnames(means) <- rownames(params)
colnames(sds) <- rownames(params)
means$channel_number <- channel_numbers
means <- arrange(means, channel_number)
sds$channel_number <- channel_numbers
sds <- arrange(sds, channel_number)

# Save
save(means, file = paste("5_b_rms/data/simple_linear_models_means.RDa", sep = ""))
save(sds, file = paste("5_b_rms/data/simple_linear_models_sds.RDa", sep = ""))