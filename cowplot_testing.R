library(ggplot2)
library(cowplot)
p1 <- ggplot(data = data.frame(x = 1:10, y = 1:10, z = 1:10)) + 
  geom_point(aes(x, y, color = z)) +
  theme(plot.margin = unit(c(0, 0, 0, 0), "cm")) +
  scale_color_gradientn(colors = c('red', 'blue'),
                      guide  = guide_colourbar(label.position = 'left',
                                 label.hjust = 1))
p2 <- qplot(1:10, (1:10)^2) + 
  theme(axis.text.y = element_blank(),
        axis.title.y = element_blank(),
        axis.ticks.y = element_blank(),
        plot.margin = unit(c(0, 0, 0, 0), "cm"),
        panel.spacing = unit(c(0, 0, 0, 0), "cm"))
plot_grid(p1, p2)
