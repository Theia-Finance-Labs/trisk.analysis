# Convert an annual PD to a cumulative lifetime PD over a horizon

Inverse of \[pd_lifetime_to_annual()\] under the same constant-hazard
assumption: \\1 - (1 - pd\\annual)^{term}\\. The caller is responsible
for asserting that the input is genuinely an annual PD — the package
does not (and cannot) infer the horizon of an internal PD. Typical use:
lift a 12-month internal PD onto TRISK's \`term\` horizon so the two are
comparable before integration (see "Choosing a direction" in
\[pd_lifetime_to_annual()\]).

## Usage

``` r
pd_annual_to_lifetime(pd_annual, term)
```

## Arguments

- pd_annual:

  Numeric vector of annual PDs in \`\[0, 1\]\`.

- term:

  Numeric vector (recycled) of horizons in years, \`\>= 0\`.

## Value

Numeric vector of cumulative lifetime PDs in \`\[0, 1\]\`.

## See also

\[pd_lifetime_to_annual()\]

## Examples

``` r
pd_annual_to_lifetime(0.02, term = 5)   # ~0.0961
#> [1] 0.0960792
```
