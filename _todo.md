To Do, ideas, etc:

- Convert all rasters to wgs84 half degree cells.
    - easy for loiczid and lat
    - for loiczid, create a dataframe of ocean area to compare to AquaMaps cell data
    - for MPAs, create a dataframe of loiczid to year lookup by proportional cell area
        - note that this will be proportion of ocean area protected by mpas
    - for meow, same thing as mpas
    - for CHI pressures, for each loiczid, find log mean? or regular mean?
        - remove zeros, log, mean, exp, then weight back with zeros?

- Compare mean risk and/or trend to CHI pressures
    - pressures
        - which ones in particular? choose a few that seem interesting
    - latitude
        - interaction with pressures? e.g. same pressure has a greater impact at different latitudes?
    - number of species
        - greater species richness in a cell might mean reduced effect of pressures on mean risk due to ecosystem resilience?
        - greater species richness will also probably reduce variance - is this just a statistical effect or can we say this has some physical meaning?
        - there is probably decent correlation between number of species and latitude

- Compare pressures to MPAs - are MPAs really helping?
    - we should see pressures reduced in MPAs - reduced human activity 
        - do pressures layers account for MPAs already or are they independent?
    
- Compare species health to MPAs 
    - old/new MPAs
    - number of species protected by MPAs
    
- Stats analyses:
    - log-mean vs UV, OA, SST, lat, (lat > 0)
        - do this using matrix notation, not just lm()
        - do this focusing on non-pelagic critters, i.e. limit the range to smallish-ranged creatures
    - estimate vs predictor
    - variance - spatially and overall
    - cluster robust standard errors
    
    
    