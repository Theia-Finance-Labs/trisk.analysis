# Fuzzy Match Company IDs

This function performs a fuzzy match between portfolio company names and
asset company names to assign company IDs to the portfolio data.

## Usage

``` r
fuzzy_match_company_ids(
  portfolio_data,
  assets_data,
  threshold = 0.5,
  method = "lcs"
)
```

## Arguments

- portfolio_data:

  Data frame containing portfolio information.

- assets_data:

  Data frame containing asset information with company IDs.

- threshold:

  Numeric value for the matching threshold. Default is 0.2.

- method:

  tring specifying method to use for fuzzy matching. See help of
  stringdist::stringdistmatrix for possible values.

## Value

A data frame of portfolio data with fuzzy-matched company IDs.
