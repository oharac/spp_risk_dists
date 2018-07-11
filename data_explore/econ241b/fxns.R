library(rnaturalearth)
library(sf)

loiczid_rast <- raster(file.path(dir_git, 'spatial/loiczid_raster.tif'))
           
ctrys50m <- rnaturalearth::ne_countries(scale = 50, type = 'countries', returnclass = 'sf') %>%
  select(iso_a3, iso_n3, admin)
           
plot_map <- function(rast_df, value, plot_title, leg_title, pal = 'RdYlGn', show.legend = TRUE) {

  rast_pts <- subs(loiczid_rast, rast_df, by = 'loiczid', which = value) %>%
    rasterToPoints() %>%
    as.data.frame() %>%
    setNames(c('x', 'y', 'layer'))
  
  map_plot <- ggplot(rast_pts) +
    ggtheme_plot() +
    theme(axis.title = element_blank(),
          axis.text  = element_blank()) +
    geom_sf(data = ctrys50m, fill = 'grey55', color = 'grey45', size = .25) +
    geom_raster(aes(x, y, fill = layer), show.legend = show.legend) +
    scale_fill_distiller(palette = pal) +
    labs(fill  = leg_title,
         title = plot_title)
  
  return(map_plot)
  
}


##################################################=
### Functions for generating regressor dataframe
##################################################=

gen_stressor_df <- function() {
  
  stressor_files <- list.files('stressor_to_loiczid', 
                               # pattern = 'slr_2016|sst_2012|uv_2016|oa_2016',
                               full.names = TRUE)
  
  if(exists('stressor_df')) rm(stressor_df)
  for(stressor_file in stressor_files) {  ### stressor_file <- stressor_files[3]
    stressor_name <- basename(stressor_file) %>%
      str_replace('_simple.csv', '')
    
    # cat('Processing', stressor_name, '...\n')
    
    tmp <- read_csv(stressor_file, col_types = 'ddddd') %>%
      select(-n_na, -contains('var'), -contains('zero'))
    
    if(!str_detect(stressor_name, '^oa|^uv|^sst|^slr')) {
      tmp <- tmp %>%
        mutate(stressor_mean = ifelse(is.na(stressor_mean), 0, stressor_mean))
    }
    tmp <- tmp %>%
      setNames(c('loiczid', 
                 paste0(stressor_name, '_mean')))
    
    if(!exists('stressor_df')) {
      stressor_df <- tmp    ### create it the first time through the loop
    } else {
      stressor_df <- stressor_df %>%
        full_join(tmp, by = 'loiczid')     ### join it on subsequent times through the loop
    }
  }
  
  stressor_df <- stressor_df %>%
    setNames(names(stressor_df) %>% str_replace('[0-9]{4}_', ''))
  
  return(stressor_df)
  
}

gen_regression_df <- function(risk_by_cell_df, stressor_df) {
    
  lat_df <- read_csv(file.path(dir_data, 'latlong_lookup.csv'), col_types = 'ddd') %>%
    mutate(dummyS = as.integer(lat < 0),
           latAbs = abs(lat)) %>%
    select(loiczid, latAbs, dummyS)
  
  
  mpa1_6_df <- read_csv(file.path(dir_data, 'wdpa_i_vi_lookup.csv'), col_types = 'ddd') %>%
    left_join(read_csv(file.path(dir_data, 'ocean_area_lookup.csv'), col_types = 'dd')) %>%
    group_by(loiczid) %>%
    summarize(mpa1_6_pct = sum(wdpa_yr_km2) / first(ocean_area_km2))
  
  mpa1_4_df <- read_csv(file.path(dir_data, 'wdpa_i_iv_lookup.csv'), col_types = 'ddd') %>%
    left_join(read_csv(file.path(dir_data, 'ocean_area_lookup.csv'), col_types = 'dd')) %>%
    group_by(loiczid) %>%
    summarize(mpa1_4_pct = sum(wdpa_yr_km2) / first(ocean_area_km2))
  
  mpa_new_1_6_df <- read_csv(file.path(dir_data, 'wdpa_i_vi_lookup.csv'), col_types = 'ddd') %>%
    left_join(read_csv(file.path(dir_data, 'ocean_area_lookup.csv'), col_types = 'dd')) %>%
    group_by(loiczid) %>%
    filter(year >= 2006) %>%
    summarize(mpa_new_1_6_pct = sum(wdpa_yr_km2) / first(ocean_area_km2))
  
  mpa_new_1_4_df <- read_csv(file.path(dir_data, 'wdpa_i_iv_lookup.csv'), col_types = 'ddd') %>%
    left_join(read_csv(file.path(dir_data, 'ocean_area_lookup.csv'), col_types = 'dd')) %>%
    group_by(loiczid) %>%
    filter(year >= 2006) %>%
    summarize(mpa_new_1_4_pct = sum(wdpa_yr_km2) / first(ocean_area_km2))
  
  eez_df <- read_csv(file.path(dir_data, 'eez_cells.csv'))
  
  risk_v_stressor_df <- full_join(risk_by_cell_df, stressor_df, by = 'loiczid') %>%
    left_join(lat_df, by = 'loiczid') %>%
    filter(n_spp >= 5) %>%
    # filter(!is.na(log_mean_risk)) %>%
    filter(!is.na(mean_risk)) %>%
    filter(!is.na(sst_mean)) %>%
    filter(!is.na(oa_mean)) %>%
    filter(!is.na(uv_mean)) %>%
    left_join(eez_df, by = 'loiczid') %>%
    left_join(mpa1_6_df, by = 'loiczid') %>%
    left_join(mpa1_4_df, by = 'loiczid') %>%
    left_join(mpa_new_1_6_df, by = 'loiczid') %>%
    left_join(mpa_new_1_4_df, by = 'loiczid') %>%
    mutate(eez         = ifelse(is.na(eez), 0, eez),
           mpa1_6_pct  = ifelse(is.na(mpa1_6_pct), 0, mpa1_6_pct),
           mpa1_4_pct  = ifelse(is.na(mpa1_4_pct), 0, mpa1_4_pct),
           mpa_new_1_4_pct = ifelse(is.na(mpa_new_1_4_pct), 0, mpa_new_1_4_pct),
           mpa_new_1_6_pct = ifelse(is.na(mpa_new_1_6_pct), 0, mpa_new_1_6_pct))

  return(risk_v_stressor_df)
}


##################################################=
### Functions for generating spatial clustering
##################################################=

latlong_df <- read_csv(file.path(dir_data, 'latlong_lookup.csv'), col_types = 'ddd')
rescale <- function(x) {(x - min(x)) / (max(x) - min(x))}

gen_clusters <- function(rgn_df = NULL, 
                         rgn_wt = 2, 
                         n_clusts = 150, 
                         n_starts = 25) {
  if(!is.null(rgn_df)) {
    cluster_df <- rgn_df %>% 
      setNames(c('loiczid', 'id')) %>%
      left_join(latlong_df, by = 'loiczid')

    cluster_norm_df <- cluster_df %>%
      select(-loiczid) %>% ### not spatially relevant
      mutate(lat_norm  = rescale(lat),
             long_norm = rescale(long),
             rgn_norm  = rescale(id),
             rgn_norm  = rgn_wt * rgn_norm) %>%
      select(-lat, -long, -id)
    
    set.seed(1234)
    
    fit_km <- kmeans(cluster_norm_df,
                     n_clusts, 
                     nstart = n_starts)
    
    adj_clust_df <- cluster_df %>%
      select(loiczid) %>%
      mutate(id_adj = fit_km$cluster)
    
  } else { ### no regions given; just do lat-long
    cluster_df <- latlong_df
    
    cluster_norm_df <- cluster_df %>%
      select(-loiczid) %>% ### not spatially relevant
      mutate(lat_norm  = rescale(lat),
             long_norm = rescale(long)) %>%
      select(-lat, -long)
    
    set.seed(1234)
    
    fit_km <- kmeans(cluster_norm_df,
                     n_clusts, 
                     nstart = n_starts)
    
    adj_clust_df <- cluster_df %>%
      select(loiczid) %>%
      mutate(id_adj = fit_km$cluster)
  }
  
  return(adj_clust_df)
  
}

##################################################=
### Functions for calculating standard errors
##################################################=

calc_B_hat <- function(X, y) {
  Xt_X <- solve(t(X) %*% X)
  Xt_y <- t(X) %*% y
  beta_hat <- Xt_X %*% Xt_y
  return(beta_hat)
}

calc_V_tilde <- function(X, y, clust_vec) {
  ### Calculate Beta_hat (-g): remove g obs and calc beta hat; then calc
  ### e_tilde_g for each group (store in a list object) and sum,
  ### calculate V as X'X * (Sum X'e e'X by group) * X'X
  
  clust_id_vec <- unique(clust_vec) %>% sort()
  
  e_tilde_g <- vector('list', length = length(clust_id_vec))
  
  for (g in clust_id_vec) { ### g <- 3
    X_minusg <- X[clust_vec != g, ]
    y_minusg <- y[clust_vec != g]
    Xt_X_minusg <- t(X_minusg) %*% X_minusg
    Xt_y_minusg <- t(X_minusg) %*% y_minusg
    
    beta_hat_minusg <- solve(Xt_X_minusg) %*% Xt_y_minusg
    
    y_g <- y[clust_vec == g]
    X_g <- X[clust_vec == g, ]
    
    e_tilde_g[[g]] <- y_g - X_g %*% beta_hat_minusg
  }
  
  
  Gsum_terms <- vector('list', length = length(clust_id_vec))
  
  for (g in clust_id_vec) { ### g <- 1
    X_g <- X[clust_vec == g, ]
    e_g <- e_tilde_g[[g]]
    
    Gsum_terms[[g]] <- t(X_g) %*% e_g %*% t(e_g) %*% X_g
  }
  
  Gsum <- Reduce('+', Gsum_terms)
  
  V_tilde <- Xt_X %*% Gsum %*% Xt_X
  
  return(V_tilde)
  
}

calc_V_hat <- function(X, y, clust_vec) {
  ### Calculate Beta_hat (-g): remove g obs and calc beta hat; then calc
  ### e_tilde_g for each group (store in a list object) and sum,
  ### calculate V as: a_n * X'X * (Sum omega) * X'X
  
  beta_hat <- calc_B_hat(X, y)
  
  clust_id_vec <- unique(clust_vec) %>% sort()
  
  G <- length(unique(clust_id_vec))
  
  omega_g <- vector('list', length = G)
  
  for (g in 1:G) { ### g <- 1
    
    y_g <- y[clust_vec == g]
    X_g <- X[clust_vec == g, ]
    
    e_hat_g <- y_g - X_g %*% beta_hat
    
    omega_g[[g]] <- t(X_g) %*% e_hat_g %*% t(e_hat_g) %*% X_g
  }
  
  Omega_n <- Reduce('+', omega_g)
  
  n_obs <- length(y)
  k_regr <- dim(X)[2]
  a_n <- (n_obs - 1) / (n_obs - k_regr) * G / (G - 1)
  
  V_hat <- a_n * Xt_X %*% Omega_n %*% Xt_X
  
  return(V_hat)

}
