### Figure out the whole weighted variance thing....


library(tidyverse)

### variance with weighting?
# set.seed = 2
# l <- vector('list', 100)
# 
# for(i in 1:100) {
  df <- data.frame(x  = rnorm(1000, mean = 1), 
                   w  = runif(1000),
                   gp = floor(runif(1000) * 100)) %>%
    mutate(x = ifelse(runif(1000) < 0.05, NA, x)) %>% 
      ### create a few NAs
    group_by(gp) %>%
    arrange(x) %>%
    filter(gp > 15 | x == first(x)) %>%
      ### create groups with only one observation
    ungroup()

  
  var_sum <- df %>%
    filter(!is.na(x)) %>%
    mutate(mean_t   = 1/n() * sum(x),
           w_mean_t = sum(x * w) / sum(w),
           var_t    = 1/(n() - 1) * sum((x - mean_t)^2),
           V1_t     = sum(w),
           V2_t     = sum(w^2),
           alpha_t  = V1_t - V2_t / V1_t,
           w_var_t  = sum(w * (x - w_mean_t)^2) / alpha_t) %>%
    select(mean_t, w_mean_t, var_t, w_var_t) %>%
    distinct() %>%
    mutate(tag = 'full data set')
  
  var_gp_df <- df %>% 
    filter(!is.na(x)) %>%
    ### This ^^^ should be proper way to calculate weighted variance: 
    ### https://en.wikipedia.org/wiki/Weighted_arithmetic_mean#Weighted_sample_variance
    group_by(gp) %>%
    summarize(mean_g    = 1/n() * sum(x), ### weighted mean in group
              w_mean_g  = sum(x * w) / sum(w), ### weighted mean in group
              var_g     = 1/(n() - 1) * sum((x - mean_g)^2),
              V1      = sum(w),         ### sum of wt in group
              V2      = sum(w^2),       ### sum of wt^2 in group
              alpha_g = V1 - (V2/V1),     ### Bessel correction in group
              w_var_g = sum(w * (x - w_mean_g)^2) / alpha_g, ### variance in group
              n_obs_g = n()) %>%
    ungroup()
  
  ### Pooled variance assumes same variance in all groups.  Can't assume that?
  ### so s^2 total = 1/(N_t - 1) * (sum[(N_g - 1) * s^2_g + N_g * mu^2 g] - N_t * mu^2_t)
  var_sum_reconstructed <- var_gp_df %>% ### https://stats.stackexchange.com/questions/211837/variance-of-subsample
    mutate(w_var_g = ifelse(is.na(w_var_g) | is.infinite(w_var_g), 0, w_var_g),
           var_g   = ifelse(is.na(var_g)   | is.infinite(var_g),   0, var_g)) %>%
      ### fix groups with problematic variances due to n == 1
    summarize(mean_t = 1/sum(n_obs_g) * sum(mean_g * n_obs_g), 
                ### unweighted mean over all groups
              w_mean_t = sum(w_mean_g * V1) / sum(V1), 
                ### weighted mean across all group weighted means
              var_t   = 1 / (sum(n_obs_g) - 1) * (sum(var_g * (n_obs_g - 1) + n_obs_g * mean_g^2) - sum(n_obs_g) * mean_t^2),
                ### unweighted variance, reconstructed?
              V1_t    = sum(V1), V2_t = sum(V2),
              alpha_t = V1_t - (V2_t / V1_t),
              w_var_t = 1/alpha_t * sum(alpha_g * w_var_g + V1 * w_mean_g^2) - 
                1/alpha_t * V1_t * w_mean_t^2) %>%
    select(mean_t, w_mean_t, var_t, w_var_t) %>%
    mutate(tag = 'reconstructed data set')

  ### NAs change the calculations.
  
  combined_df <- bind_rows(var_sum, var_sum_reconstructed)
#   l[[i]] <- df_sum
# }
# #      
# l <- bind_rows(l) %>%
#   mutate(diff = w_var1 - w_var_pooled)

  x <- cell_values_all %>%
    filter(cell_id == first(cell_id)) %>%
    select(cell_id, mean_risk, var_risk, n_spp_risk)
  

  
  z <- x %>%
    mutate(mean_risk_g = mean_risk,   ### protect it
           n_spp_risk_g = n_spp_risk, ### protect it
           var_risk_g  = ifelse(var_risk < 0 | is.na(var_risk) | is.infinite(var_risk), 
                                0, var_risk)) %>%
    ### any non-valid variances probably due to only one observation, which
    ### results in corrected var of infinity... set to zero and proceed!
    group_by(cell_id) %>%
    summarize(mean_risk_t = sum(mean_risk_g * n_spp_risk_g) / sum(n_spp_risk_g),
              n_spp_risk_t  = sum(n_spp_risk_g), ### n_total
              var_risk    = 1 / (n_spp_risk_t - 1) *
                (sum(var_risk_g * (n_spp_risk_g - 1) + n_spp_risk_g * mean_risk_g^2) -
                     n_spp_risk_t * mean_risk_t^2),
              var_risk = ifelse(var_risk < 0, 0, var_risk),
              var_risk = ifelse(is.nan(var_risk) | is.infinite(var_risk), NA, var_risk))
  ### get rid of negative (tiny) variances and infinite variances
  