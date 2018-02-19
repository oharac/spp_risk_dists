library(raster)
library(dplyr)
library(RColorBrewer)
library(sp)
library(rgdal)
library(stringr)

cols <- rev(colorRampPalette(brewer.pal(9, 'Spectral'))(255))

source("https://raw.githubusercontent.com/OHI-Science/ohiprep_v2018/master/src/R/spatial_common.R")

#### The scripts I used to generate the figures for the paper are here:
## https://github.com/OHI-Science/cia/blob/master
## main file is MappingData.R

### cumulative impacts data (all 2013 pressures combined)
ci <- raster(file.path(dir_M,
                       "marine_threats/impact_layers_2013_redo/global_impact_model_2013/normalized_by_one_time_period/averaged_by_num_ecosystems/all_layers/global_cumul_impact_2013_all_layers.tif"))
ci
plot(ci)

### individual pressures (2013)
### stressor data combined with the pressurexhabitat vulnerability matrix and habitat raster layers 

pressure_example <- raster(file.path(dir_M,
                                     "marine_threats/impact_layers_2013_redo/global_impact_model_2013/normalized_by_one_time_period/averaged_by_num_ecosystems/by_threat/shipping_combo.tif"))
pressure_example
plot(pressure_example)


### stressors (data rescaled from 0-1 using max value)
stressor <- raster(file.path(dir_M, 
                             "marine_threats/impact_layers_2013_redo/impact_layers/final_impact_layers/threats_2013_final/normalized_by_one_time_period/shipping.tif"))


#################################################
## example of stacking and randomly selecting data
#################################################

source("https://raw.githubusercontent.com/OHI-Science/ohiprep_v2018/master/src/R/spatial_common.R")


files <- list.files(file.path(dir_M, "git-annex/globalprep/prs_uv/v2017/int"), 
                    pattern = "mol_1km.tif",
                    full = TRUE)

uv_stack <- stack(files)

samp_n <- 100

rand_samp <- sampleRandom(uv_stack, size=samp_n) %>%
  data.frame()

rand_samp$sample_id <- 1:samp_n

rand_samp_data <- rand_samp %>%
  gather("year", "extreme_events", starts_with("uv")) %>%
  mutate(year = substr(year, 9, 12)) %>%
  mutate(year = as.numeric(year)) %>%
  filter(year != 2009)

# check that everything went well
summary(rand_samp_data)        
table(rand_samp_data$sample_id)  