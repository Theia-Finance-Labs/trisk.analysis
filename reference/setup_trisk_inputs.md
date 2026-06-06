# Scaffold a local TRISK input-data folder

Creates a project-level \`trisk_inputs/\` folder that a bank populates
with its own data, pre-seeded with \*\*blank templates\*\* (header-only
CSVs to fill in) and \*\*filled samples\*\* (the bundled example data,
as a worked reference), plus a \`README.md\` documenting the required
files, their schemas, and the three portfolio-matching modes.

## Usage

``` r
setup_trisk_inputs(path = "trisk_inputs", overwrite = FALSE)
```

## Arguments

- path:

  Directory to create. Defaults to \`"trisk_inputs"\` in the working
  directory.

- overwrite:

  If \`FALSE\` (default), existing files are left untouched so a re-run
  never clobbers data you have already filled in. If \`TRUE\`,
  templates, samples and the README are regenerated.

## Value

The \`path\`, invisibly.

## Details

The folder is created in your \*\*working directory\*\* (or wherever
\`path\` points), never inside the installed package: the package
library is read-only on many systems and is overwritten on every update,
so input data must live in your own project. The vignettes load bundled
sample data as placeholders; once you have filled the templates, save
your files as \`trisk_inputs/\<input\>.csv\` and point the analysis
reads there.

TRISK takes five inputs. Four describe the world; the fifth is your
portfolio:

- assets:

  Physical/production assets per company. You supply this.

- scenarios:

  Climate-scenario price and production pathways. The full set is
  fetched with \[download_trisk_inputs()\]; a small sample is bundled.

- ngfs_carbon_price:

  Carbon-price trajectories. A sample is bundled.

- financial_features:

  Per-company financials (PD, margins, leverage, volatility). You supply
  this.

- portfolio_ids:

  \*\*Your loan book\*\*, keyed by \`company_id\` - the main,
  recommended portfolio input. You can instead match by company name
  (\`portfolio_names\`) or by country only (\`portfolio_countries\`);
  both are options. Add an \`internal_pd\` column for the
  PD/EL-integration workflows.
