# Load libraries
library(dplyr)
library(readr)
library(rethinking)
source("src/5_rms/functions.R")

# Get list of models
models <- dir(path = "data/5_rms/models")
channel_numbers <- as.numeric(parse_number(models))

# Create data frames containing params of all models
means <- data.frame()
sds <- data.frame()

# Loop over and load each model and add params to a data frame
for (i in 1:128) {
  
  # Load the model
  load(file = file.path("data/5_rms/models", models[i]))
  
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
save(means, file = "data/5_rms/model_means.RDa")
save(sds, file = "data/5_rms/model_sds.RDa")