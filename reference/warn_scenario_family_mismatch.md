# Warn when baseline and target scenarios are from different families (NM1)

Scenario names encode a model/year vintage plus a scenario type, e.g.
\`NGFS2023GCAM_CP\` (family \`NGFS2023GCAM\`, type \`CP\`). Baseline and
target should share the family and differ only in type; mixing families
(or the near-identical \`NGFS2023GCAM\_\*\` vs \`NGFS2023_GCAM\_\*\`)
compares incompatible vintages/horizons. This surfaces that as a
warning.

## Usage

``` r
warn_scenario_family_mismatch(baseline_scenario, target_scenario)
```

## Arguments

- baseline_scenario, target_scenario:

  Scenario name strings.

## Value

Invisibly \`TRUE\` if families match, \`FALSE\` otherwise.
