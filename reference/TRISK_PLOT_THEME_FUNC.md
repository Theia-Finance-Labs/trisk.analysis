# TRISK plot theme

Standard ggplot2 theme used across trisk.analysis plots. Exported so
users can apply it to custom plots (e.g. vignette chunks) for visual
consistency with the built-in \`pipeline_crispy\_\*\` functions.

## Usage

``` r
TRISK_PLOT_THEME_FUNC(
  base_size = 12,
  base_family = "Helvetica",
  base_line_size = base_size/22,
  base_rect_size = base_size/22
)
```

## Arguments

- base_size:

  Base font size. Default 12.

- base_family:

  Base font family. Default "Helvetica".

- base_line_size:

  Line thickness. Default \`base_size / 22\`.

- base_rect_size:

  Rectangle border thickness. Default \`base_size / 22\`.

## Value

A ggplot2 theme object.
