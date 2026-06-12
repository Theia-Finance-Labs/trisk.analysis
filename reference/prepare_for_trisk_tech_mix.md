# Prepare dual-basis technology mix

Aggregates a tech-detail frame to sector x technology and computes each
technology's share of baseline NPV value and of exposure (EAD), within
sector. Negative NPVs are clamped to zero, and a sector with no positive
NPV (or no exposure) falls back to an equal split, so shares stay in
\`\[0, 1\]\` and sum to 1 (mirrors the \`add_exposure_share_from_npv()\`
guard).

## Usage

``` r
prepare_for_trisk_tech_mix(analysis_data)
```

## Arguments

- analysis_data:

  Tech-detail frame (see \[pipeline_trisk_tech_mix()\]).

## Value

A tibble: one row per sector/technology with both share columns.
