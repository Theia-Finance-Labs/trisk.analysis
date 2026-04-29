# TRISK plot palette constants

Hex colour codes used by the built-in \`pipeline_crispy\_\*\` plot
functions. Exported so users can match the palette in custom plots and
vignette chunks.

## Usage

``` r
TRISK_HEX_RED

TRISK_HEX_GREEN

TRISK_HEX_GREY

TRISK_HEX_ADJUSTED

STATUS_GREEN
```

## Format

Character scalars (hex colour strings).

An object of class `character` of length 1.

An object of class `character` of length 1.

An object of class `character` of length 1.

An object of class `character` of length 1.

An object of class `character` of length 1.

## Details

- \`TRISK_HEX_RED\` — primary red, for shock / negative / worse-off
  fills.

- \`TRISK_HEX_GREEN\` — primary green, for baseline / better-off fills.

- \`TRISK_HEX_GREY\` — neutral grey, for reference / neutral series.

- \`TRISK_HEX_ADJUSTED\` — dark-red blend, for adjusted PD/EL series.

- \`STATUS_GREEN\` — muted green (from \`trisk.r.docker\`), for positive
  / better-off status fills.
