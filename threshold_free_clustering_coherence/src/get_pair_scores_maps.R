library("dplyr")
library("ggplot2")
library("ggpubr")
source("tools/functions.R")
source("8_wilcoxon/src/functions.R")

coordinates <- get_layout()
df <- data.frame(overall, coordinates)

plot <- ggplot() +
  geom_point(data = df, aes(x = x, y = y, 
                                 size = 1/p, 
                                 alpha = 0.5,
                                 stroke = 0)) +
  geom_point(data = df, aes(x = x, y = y, 
                                 size = 1,
                                 alpha = 0.5,
                                 stroke = 0)) + 
  scale_size_continuous(name = "p", 
                        limits = c(1, 1000),
                        breaks = c(20, 100, 200), 
                        labels = c("0.05", "0.01", "0.005")) +
  guides(alpha = FALSE) +
  ylim(0, 900) +
  xlim(0, 900) +
  annotate("text", x=20, y=5, label= "L", alpha = 0.8) +
  annotate("text", x=880, y=5, label= "R", alpha = 0.8) +
  theme(axis.line=element_blank(),axis.text.x=element_blank(),
        axis.text.y=element_blank(),axis.ticks=element_blank(),
        axis.title.x=element_blank(),
        axis.title.y=element_blank(),
        panel.background=element_blank(),
        panel.border=element_blank(),
        panel.grid.major=element_blank(),
        panel.grid.minor=element_blank(),
        plot.background=element_blank())
plot
ggsave(plot = plot, filename = 'threshold_free_clustering/figs/overall.png', width = 6, height = 5)