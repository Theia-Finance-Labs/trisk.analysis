test_that("setup_trisk_inputs scaffolds templates, samples and README", {
  dir <- file.path(tempdir(), paste0("trisk_inputs_", as.integer(runif(1, 1, 1e9))))
  on.exit(unlink(dir, recursive = TRUE), add = TRUE)

  res <- setup_trisk_inputs(path = dir)
  expect_identical(res, dir)

  # README present
  expect_true(file.exists(file.path(dir, "README.md")))

  # Both template and sample subfolders exist
  expect_true(dir.exists(file.path(dir, "templates")))
  expect_true(dir.exists(file.path(dir, "samples")))

  inputs <- c("assets", "scenarios", "ngfs_carbon_price",
              "financial_features", "portfolio_ids")

  for (nm in inputs) {
    tmpl <- file.path(dir, "templates", paste0(nm, ".csv"))
    samp <- file.path(dir, "samples", paste0(nm, ".csv"))
    expect_true(file.exists(tmpl), info = paste("template", nm))
    expect_true(file.exists(samp), info = paste("sample", nm))

    tmpl_df <- utils::read.csv(tmpl, check.names = FALSE)
    samp_df <- utils::read.csv(samp, check.names = FALSE)

    # Blank template: headers only, zero data rows
    expect_equal(nrow(tmpl_df), 0L, info = paste("blank template", nm))
    # Filled sample: at least one data row
    expect_gt(nrow(samp_df), 0L)
    # Template and sample share the same columns
    expect_identical(colnames(tmpl_df), colnames(samp_df))
  }
})

test_that("portfolio_ids template carries the canonical portfolio columns", {
  dir <- file.path(tempdir(), paste0("trisk_inputs_pf_", as.integer(runif(1, 1, 1e9))))
  on.exit(unlink(dir, recursive = TRUE), add = TRUE)

  setup_trisk_inputs(path = dir)
  cols <- colnames(utils::read.csv(file.path(dir, "templates", "portfolio_ids.csv"),
                                   check.names = FALSE))
  expect_true(all(c("company_id", "company_name", "country_iso2",
                    "exposure_value_usd", "term", "loss_given_default") %in% cols))
})

test_that("setup_trisk_inputs does not clobber bank files unless overwrite = TRUE", {
  dir <- file.path(tempdir(), paste0("trisk_inputs_ow_", as.integer(runif(1, 1, 1e9))))
  on.exit(unlink(dir, recursive = TRUE), add = TRUE)

  setup_trisk_inputs(path = dir)
  sample_assets <- file.path(dir, "samples", "assets.csv")

  # Bank edits a file
  writeLines("SENTINEL", sample_assets)

  # Default re-run must preserve the edit
  setup_trisk_inputs(path = dir)
  expect_identical(readLines(sample_assets)[1], "SENTINEL")

  # overwrite = TRUE resets it
  setup_trisk_inputs(path = dir, overwrite = TRUE)
  expect_false(identical(readLines(sample_assets)[1], "SENTINEL"))
})
