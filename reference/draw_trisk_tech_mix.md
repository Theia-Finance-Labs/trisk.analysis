# Draw the technology-mix plot

Draw the technology-mix plot

## Usage

``` r
draw_trisk_tech_mix(mix, bases = c("% of NPV value", "% of exposure (EAD)"))
```

## Arguments

- mix:

  Output of \[prepare_for_trisk_tech_mix()\].

- bases:

  Bases to draw (column names present in \`mix\`).

## Value

A ggplot object.
