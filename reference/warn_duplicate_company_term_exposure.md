# Warn on likely duplicate per-technology entry of one company loan (X1 guard)

A loan is exposure to a company, but the full runner joins on
`technology`. A user capturing a whole company therefore sometimes
enters the same loan once per technology, each carrying the *full*
exposure - which the runner sums into inflated EL/EAD. The signature is
the same `(company_id, term)` with an identical `exposure_value_usd`
repeated across rows. This surfaces it and points to the simple runner
(which allocates a company loan across technologies by NPV share). It
does not modify the data.

## Usage

``` r
warn_duplicate_company_term_exposure(portfolio_data)
```

## Arguments

- portfolio_data:

  Portfolio data frame.

## Value

Invisibly, the duplicated \`(company_id, term, exposure)\` groups.
