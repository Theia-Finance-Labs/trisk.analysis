# Sector-shaded technology colours

Shades of a sector's base colour (\[TRISK_SECTOR_PALETTE\]) for its
technologies, ordered dark (carbon-intensive) to light (clean).

## Usage

``` r
trisk_sector_shades(sector, technologies)
```

## Arguments

- sector:

  Sector name (key into \[TRISK_SECTOR_PALETTE\]; unknown sectors fall
  back to neutral grey).

- technologies:

  Character vector of technology names in that sector.

## Value

Named character vector of hex colours, one per technology.
