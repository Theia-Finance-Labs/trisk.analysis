# Build a TRISK run audit-trail / reproducibility record

Captures everything needed to reproduce a runner call: the scenario
pair, the \`run_id\`, the forwarded TRISK arguments, and the versions of
both packages. Attached to runner output as the \`trisk_run_meta\`
attribute (A1).

## Usage

``` r
build_trisk_run_meta(
  baseline_scenario,
  target_scenario,
  run_id,
  extra_args = list()
)
```

## Arguments

- baseline_scenario, target_scenario:

  Scenario names used for the run.

- run_id:

  The TRISK \`run_id\`(s) of the model run.

- extra_args:

  A list of the additional arguments forwarded to
  \[trisk.model::run_trisk_model()\] (typically \`list(...)\` from the
  runner).

## Value

A named list: \`baseline_scenario\`, \`target_scenario\`, \`run_id\`,
\`trisk_args\`, \`package_versions\`, \`created_at\`.
