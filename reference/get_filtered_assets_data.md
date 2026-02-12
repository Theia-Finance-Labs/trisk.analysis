# Filter assets based on provided criteria

This function filters the assets data based on criteria such as country,
sector, technology, and company name.

## Usage

``` r
get_filtered_assets_data(
  assets_data,
  country_iso2 = NULL,
  sector = NULL,
  technology = NULL,
  company_name = NULL
)
```

## Arguments

- assets_data:

  The assets data to be filtered.

- country_iso2:

  A character vector of ISO2 country codes to filter the assets.
  Defaults to NULL.

- sector:

  A character vector of sectors to filter the assets. Defaults to NULL.

- technology:

  A character vector of technologies to filter the assets. Defaults to
  NULL.

- company_name:

  A character vector of company names to filter the assets. Defaults to
  NULL.

## Value

A tibble containing the filtered assets data.
