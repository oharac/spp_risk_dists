library(raster)
library(sf)


source('https://raw.githubusercontent.com/oharac/src/master/R/common.R')  ###
### includes library(tidyverse); library(stringr); dir_M points to ohi directory

dir_git <- '~/github/spp_risk_dists'

### goal specific folders and info
dir_data  <- file.path(dir_git, 'data')
dir_o_anx <- file.path(dir_O, 'git-annex/spp_risk_dists')

source(file.path(dir_git, '_setup/common_fxns.R'))

### Gall-Peters doesn't have an EPSG?
gp_proj4 <- '+proj=cea +lon_0=0 +lat_ts=45 +x_0=0 +y_0=0 +ellps=WGS84 +units=m +no_defs'

risk_un_rast   <- raster(file.path(dir_git, '_output', 'mean_risk_raster_comp.tif'))



land_poly <- sf::read_sf(file.path(dir_git, '_spatial/ne_10m_land', 
                                   'ne_10m_land_no_casp.shp')) %>%
  st_transform(gp_proj4) 

map_df <- data.frame(risk = values(risk_un_rast)) %>%
  cbind(coordinates(risk_un_rast)) %>% 
  filter(!is.na(risk))

riskmap <- ggplot(map_df) +
  geom_raster(aes(x, y, fill = risk), show.legend = FALSE) +
  geom_sf(data = land_poly, aes(geometry = geometry), 
          fill = NA, color = 'black', size = .25) +
  ggtheme_map() +
  theme(plot.margin = unit(c(.05, 0, .1, .4), units = 'cm')) +
  coord_sf(datum = NA) + ### ditch graticules
  scale_fill_gradientn(colors = risk_cols, values = risk_vals, limits = c(0, 1),
                       labels = risk_lbls, breaks = risk_brks,
                       guide  = guide_colourbar(label.position = 'left',
                                                label.hjust = 1)) +
  scale_x_continuous(expand = c(0, 0), limits = c(-6000000, -5000000)) +
  scale_y_continuous(expand = c(0, 0), limits = c(5700000, 6300000))

riskmap
###################

ocean_rast   <- raster(file.path(dir_git, '_spatial', 'ocean_area_rast.tif'))

ocean_df <- data.frame(area = values(ocean_rast)) %>%
  cbind(coordinates(ocean_rast)) %>% 
  filter(!is.na(area))

oceanmap <- ggplot(ocean_df) +
  geom_raster(aes(x, y, fill = area), show.legend = FALSE) +
  geom_sf(data = land_poly, aes(geometry = geometry), 
          fill = NA, color = 'black', size = .25) +
  ggtheme_map() +
  theme(plot.margin = unit(c(.05, 0, .1, .4), units = 'cm')) +
  coord_sf(datum = NA) + ### ditch graticules
  scale_fill_distiller(palette = 'Blues') +
  scale_x_continuous(expand = c(0, 0), limits = c(-6000000, -5000000)) +
  scale_y_continuous(expand = c(0, 0), limits = c(5700000, 6300000))

oceanmap
###################

# ocean_rast2   <- raster(file.path(dir_o_anx, 'spatial', 'ocean_1km.tif'))
# 
# ocean2_df <- data.frame(ocean = values(ocean_rast2)) %>%
#   cbind(coordinates(ocean_rast2)) %>% 
#   filter(!is.na(ocean))
# 
# oceanmap2 <- ggplot(ocean2_df) +
#   geom_raster(aes(x, y, fill = ocean), show.legend = FALSE) +
#   geom_sf(data = land_poly, aes(geometry = geometry), 
#           fill = NA, color = 'black', size = .25) +
#   ggtheme_map() +
#   theme(plot.margin = unit(c(.05, 0, .1, .4), units = 'cm')) +
#   coord_sf(datum = NA) + ### ditch graticules
#   scale_fill_distiller(palette = 'Blues') +
#   scale_x_continuous(expand = c(0, 0), limits = c(-6000000, -5000000)) +
#   scale_y_continuous(expand = c(0, 0), limits = c(5700000, 6300000))
# 
# oceanmap2
###################

