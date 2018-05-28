General direction:

Update of Selig 2014

- Original study
    - IUCN, BLI, AM data for spp dists (~12000ish spp total) to calculate for each cell:
        - Species richness
        - Range rarity
        - Relative range rarity
    - compare to CHI overall map - 
        - high impact (high threat - vocab here? can we frame it as a verb?  as potential for degradation etc?)
        - low impact  (low threat)
    - at coarse scale (hexagons at 2200 km^2?)
- New study
    - Add more species with updated data sets
        - possibly "core habitat"? i.e. 60% AM abnd IUCN AOO maps?
        - Same metrics - richness, range rarity, rel range rarity
    - Add IUCN extinction risk
        - mean(risk), var(risk) across all spp - to identify impacted/degraded areas
        - threatened/endangered spp count and relative endangered spp count - another measure of conservation priority
    - Analyze newest CHI overall impact - analyze at finer scale e.g. 1 km^2?
    - Add in the rate of change as additional filter - bad and getting worse; pristine but getting worse.
    - Can we incorporate acceleration into this as well? e.g. stabilizing?  or highly variable impacts?
- SI
    - break into taxonomic groups
    - separate analysis by range sizes (endemism?)
    - analyze by stressor clusters
    
    
    
- To do - spp dists only
    - describe need - is there an overarching need for a global map of risk 
      to biodiversity? what does this provide that others can't just do
        - mean is easy to "get"; variance might be tougher
        - this is basically just publishing as standalone something that has
          been done previously in OHI assessments - what does this offer
          above and beyond that?
        - what additional analyses or commentary we can provide to make this
          a valuable exercise?
        - using IUCN subpop maps to refine
    - update spatial data
        - update spatial data for IUCN
            - download from Red List spatial data site 
                - EOO maps for comprehensively assessed species
            - download from Red List spatial API? 
                - Need to get a token
                - what kind of data available? EOOs for more species? AOOs?
            - Get data from Gina Ralph
        - update spatial data from Bird Life International
            - do they have AOO maps? or just EOO?
        - update spatial data from AquaMaps
    - can we publish this as essentially a product?
        - using half degree cells, do we need to include AquaMaps in on the paper?
        - boosting resolution?
            - analyze IUCN at higher resolution, e.g. quarter degree cells
                - but flakiness of IUCN border seems to reduce value of this
                - clipping to depth would be a good add
            - can we do something with AquaMaps to improve without changing
              the underlying data
                - e.g. limit ranges to Longhurst provinces or ecoregions?
                - reproject to .25 deg cells, using same params except 
                  clipping to new bottom depth and maybe distance to shore
        - is there value in doing this at 1 km^2 resolution?
            - plays well with Cumulative Impacts... but not really any
              additional information value at that higher res
    - Investigate probability-weighted vs. simple clip areas
    

Preparing ranges
- Subpopulations
    - Identify all marine species with separately-assessed subpopulations
        - not just those with subpops included in the IUCN maps
        - for IUCN EOO maps not differentiated by subpop, can we match
          subpops to ocean basins using e.g. FAO Major Fishing Areas or
          ecoregions or Longhurst provinces?
        - Can we do this for IUCN assessed but unmapped spp as well, i.e.
          dividing up AquaMaps into assessed subpopulations?
- Depth clipping
    - Identify max depth for all species in IUCN assessments
        - Differentiate <200 m bottom creatures as a T/F
        - Can we separate into benthic and demersal vs non-benthic/non-demersal?
            - by class? order? genus?
            - habitats from IUCN API?
                - e.g. many that are benthic-ish, some that are "epipelagic" -
                  perhaps these can be refined looking at the narratives for
                  key terms?
            - narratives from IUCN API?
    
    