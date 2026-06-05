# Phase 2 (S1) — run_trisk_from_db() must never carry hardcoded credentials and
# must fail fast with a clear message when DB secrets are absent.

test_that("S1: errors clearly when DB credentials are absent", {
  vars <- c("TRISK_DB_NAME", "TRISK_DB_HOST", "TRISK_DB_USER", "TRISK_DB_PASSWORD")
  old <- Sys.getenv(vars)
  Sys.unsetenv(vars)
  on.exit(if (any(nzchar(old))) do.call(Sys.setenv, as.list(old[nzchar(old)])), add = TRUE)

  expect_error(
    run_trisk_from_db("baseline", "target"),
    "missing database credentials"
  )
})

test_that("S1: no hardcoded password remains; credentials come from env", {
  body_txt <- paste(deparse(body(connect_trisk_db_from_env)), collapse = "\n")
  expect_false(grepl("crispypassword", body_txt, fixed = TRUE))
  expect_true(grepl("TRISK_DB_PASSWORD", body_txt, fixed = TRUE))
})
