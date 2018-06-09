# Biodiversity intactness mapping

## describe need

Is there an overarching need for a global map of risk to biodiversity? what does this provide that others can't just do themselves. This is basically just publishing as standalone something that has been done previously in OHI assessments - what does this offer above and beyond that?

- mean is easy to "get"; variance might be tougher to explain
- range-rarity adjusted mean
- compare to MPA coverage

### Notes from Ben:

1. including trend as a result or panel in a figure makes sense.  it's not a key result, but worth including
2. bivariate plot to show mean and trend sounds good
3. for main results (ie in the main paper) I would definitely include a figure with panels of results by taxa and also something that addresses range size (in particular endemic species)
4. might consider showing mean and geometric mean (or something) that weights by the 'worser' (as Max says) of the species present.
5. not sure about AM threshold stuff - probably will need to do it as a sensitivity analysis and report in SI.
6. reviewers are almost certainly going to ask 'so what do these maps then mean for conservation' which is a great set up for the following paper but we can't ignore it in this paper completely.  We'll need to discuss the issue at a minimum. A 'simple' way to throw a bone to this would be to overlap MPAs (of different classes), noting that fishing is a major pressure to most biodiversity in the ocean, and see what the overlap shows. Talk about it within the frame of 'what does the global MPA estate do for threatened and endangered species'.
7. I don't think we need to do the depth range clipping unless it's really easy. Although we do point out the issue in your paper, so maybe we have to??

## The analysis

Update spatial data

- IUCN maps from Red List spatial data download site: get version 2018-1 in late June
- Other IUCN maps from Gina Ralph in late June
- update spatial data from Bird Life International

Preparing ranges

- Subpopulations
    - Identify all marine species with separately-assessed subpopulations
        - not just those with subpops included in the IUCN maps?
        - for IUCN maps not currently differentiated by subpop, can we match subpops 
          to ocean basins using e.g. FAO Major Fishing Areas or ecoregions or Longhurst 
          provinces?
        - use regional assessed values where available?
- Depth clipping
    - Identify habitat depth zones for all species based on habitat list from API
        - Differentiate neritic/oceanic, and for neritic, differentiate intertidal and above
        - find bathymetry data set to create depth zone rasters (i.e. > 200 m, < 20 m)
- Taxonomic and/or functional groups
    - What are some logical or common taxonomic breakdowns?
 
    
    
# Update of Selig 2014

- Original study
    - IUCN, BLI, AM data for spp dists (~12000ish spp total) to calculate for each cell:
        - Species richness
        - Range rarity
        - Relative range rarity
    - compare to CHI overall map - 
        - high impact (high threat - vocab here? can we frame it as a verb?  as 
          potential for degradation etc?)
        - low impact  (low threat)
    - at coarse scale (hexagons at 2200 km^2?)
- New study
    - Add more species with updated data sets
        - possibly "core habitat"? i.e. 60% AM abnd IUCN AOO maps?
        - Same metrics - richness, range rarity, rel range rarity
        - can we add some metric of functional group representation?
    - Add IUCN extinction risk
        - mean(risk), var(risk) across all spp - to identify impacted/degraded areas
        - threatened/endangered spp count and relative endangered spp count - 
          another measure of conservation priority
    - Analyze newest CHI overall impact - analyze at finer scale e.g. 1 km^2?
    - Add in the rate of change as additional filter - bad and getting worse; 
      pristine but getting worse.
    - Can we incorporate acceleration into this as well? e.g. stabilizing?  or 
      highly variable impacts?
- SI
    - break into taxonomic groups
    - separate analysis by range sizes (endemism?)
    - analyze by stressor clusters
    
    
    
