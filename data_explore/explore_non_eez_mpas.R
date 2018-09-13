library(sf)
library(fasterize)

source('https://raw.githubusercontent.com/oharac/src/master/R/common.R')  ###
### includes library(tidyverse); library(stringr); dir_M points to ohi directory

dir_git <- '~/github/spp_risk_dists'

### goal specific folders and info
dir_setup   <- file.path(dir_git, 'setup')
dir_spatial <- file.path(dir_git, 'spatial')
dir_anx     <- file.path(dir_M, 'git-annex')
dir_o_anx   <- file.path(dir_O, 'git-annex/spp_risk_dists')


wdpa_poly_file   <- file.path(dir_o_anx, 'wdpa/wdpa_jun2018/WDPA_June2018-shapefile-polygons.shp')

wdpa_poly <- sf::read_sf(wdpa_poly_file)

# wdpa_poly$IUCN_CAT %>% unique()
iucn_cats <- c('Ia'  = 1,
               'Ib'  = 1,
               'II'  = 2,
               'III' = 3,
               'IV'  = 4,
               'V'   = 5,
               'VI'  = 6)
# wdpa_poly$STATUS %>% table()
# Adopted   Designated  Established    Inscribed Not Reported     Proposed 
#      34       215853            2          241          128         1537 
# wdpa_poly$NO_TAKE %>% unique()
# x <- wdpa_poly %>% filter(NO_TAKE %in% c('All', 'Part'))

wdpa_marine <- wdpa_poly %>%
  filter(MARINE > 0 | GIS_M_AREA > 0) %>%
  filter(STATUS %in% c('Designated', 'Adopted', 'Established')) %>%
  ### no paper parks!
  filter(!str_detect(tolower(MANG_PLAN), 'non-mpa')) %>%
  ### omit non-MPA fisheries or species management plans!
  mutate(no_take = (NO_TAKE == 'All') | (NO_TAKE == 'Part' & NO_TK_AREA > 0.75 * GIS_M_AREA),
         ### if NO_TK_AREA is 75% or more of GIS area, count it...
         cat = iucn_cats[IUCN_CAT],
         cat = ifelse(no_take & !cat %in% 1:2, -1, cat), ### use -1 as a "no take" flag
         cat = ifelse(is.na(cat), 8, cat)) %>%           ### use 8 as an "other protected" flag
  arrange(cat)

wdpa_no_take <- wdpa_marine %>%
  filter(no_take)

wdpa_no_take_abnj <- wdpa_no_take %>%
  filter(ISO3 == 'ABNJ')

eez <- read_sf(file.path(dir_M, 'git-annex/globalprep/spatial/v2017/regions_2017_update.shp')) %>%
  filter(!str_detect(rgn_type, 'land')) %>%
  st_transform(4326)

ggplot() +
  geom_sf(data = wdpa_no_take, aes(fill = cat)) +
  geom_sf(data = eez, fill = NA)

ggplot() +
  geom_sf(data = wdpa_no_take_abnj)

wdpa_no_take_df <- wdpa_no_take %>%
  as.data.frame() %>%
  select(-geometry)

wdpa_abnj_df <- wdpa_marine %>%
  filter(ISO3 == 'ABNJ') %>%
  as.data.frame() %>%
  select(-geometry)
