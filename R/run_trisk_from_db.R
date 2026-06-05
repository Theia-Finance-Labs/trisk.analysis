#' Fetch Data from PostgreSQL and Run Transition Risk Aggregation
#'
#' Connects to a PostgreSQL database, retrieves the required datasets, and runs
#' [run_trisk_agg()].
#'
#' @details
#' Credentials are **never** hardcoded. Supply the connection one of two ways:
#' \itemize{
#'   \item Pass an open DBI connection via `conn` (recommended — the caller owns
#'     secret management and connection lifetime); or
#'   \item Leave `conn = NULL` and set environment variables, which are read at
#'     call time: `TRISK_DB_NAME`, `TRISK_DB_HOST`, `TRISK_DB_USER`,
#'     `TRISK_DB_PASSWORD`, and optional `TRISK_DB_PORT` (default `5432`).
#'     Missing required variables raise an error before any connection attempt.
#' }
#' When `conn = NULL`, the connection opened here is closed on exit. A
#' caller-supplied `conn` is left open for the caller to manage.
#'
#' The following datasets are fetched: assets (`public_marts.assets`), scenarios
#' (`public_marts.scenarios`), financial features
#' (`public_marts.financial_features`), and carbon prices
#' (`public_marts.ngfs_carbon_prices`).
#'
#' @param baseline_scenario A character string representing the baseline scenario.
#' @param target_scenario A character string representing the target scenario.
#' @param conn Optional open DBI connection. When `NULL` (default), a connection
#'   is built from the `TRISK_DB_*` environment variables and closed on exit.
#' @param ... Additional parameters passed to [run_trisk_agg()].
#'
#' @return A list with `npv_results`, `pd_results`, and `company_trajectories`.
#'
#' @importFrom DBI dbConnect dbDisconnect dbGetQuery
#' @importFrom RPostgres Postgres
#' @export
run_trisk_from_db <- function(
    baseline_scenario,
    target_scenario,
    conn = NULL,
    ...) {
  if (is.null(conn)) {
    db_connection <- connect_trisk_db_from_env()
    on.exit(DBI::dbDisconnect(db_connection), add = TRUE)
  } else {
    db_connection <- conn
  }

  # Fetch datasets from the database
  assets_data <- DBI::dbGetQuery(db_connection, "SELECT * FROM public_marts.assets")
  scenarios_data <- DBI::dbGetQuery(db_connection, "SELECT * FROM public_marts.scenarios")
  financial_data <- DBI::dbGetQuery(db_connection, "SELECT * FROM public_marts.financial_features")
  carbon_data <- DBI::dbGetQuery(db_connection, "SELECT * FROM public_marts.ngfs_carbon_prices")

  run_trisk_agg(
    assets_data = assets_data,
    scenarios_data = scenarios_data,
    financial_data = financial_data,
    carbon_data = carbon_data,
    baseline_scenario = baseline_scenario,
    target_scenario = target_scenario,
    ...
  )
}

# Internal — open a PostgreSQL connection from TRISK_DB_* environment variables.
# Fails fast (before connecting) if any required secret is missing. No credential
# is ever hardcoded or logged.
connect_trisk_db_from_env <- function() {
  dbname   <- Sys.getenv("TRISK_DB_NAME")
  host     <- Sys.getenv("TRISK_DB_HOST")
  user     <- Sys.getenv("TRISK_DB_USER")
  password <- Sys.getenv("TRISK_DB_PASSWORD")
  port     <- Sys.getenv("TRISK_DB_PORT", unset = "5432")

  required <- c(
    TRISK_DB_NAME = dbname, TRISK_DB_HOST = host,
    TRISK_DB_USER = user,   TRISK_DB_PASSWORD = password
  )
  missing <- names(required)[!nzchar(required)]
  if (length(missing) > 0) {
    stop(
      "run_trisk_from_db(): missing database credentials. Set the environment ",
      "variable(s): ", paste(missing, collapse = ", "),
      ", or pass an open DBI connection via `conn`.",
      call. = FALSE
    )
  }

  port_int <- suppressWarnings(as.integer(port))
  if (is.na(port_int) || port_int <= 0L) {
    stop("run_trisk_from_db(): TRISK_DB_PORT must be a positive integer (got '",
         port, "').", call. = FALSE)
  }

  DBI::dbConnect(
    RPostgres::Postgres(),
    dbname = dbname, host = host, port = port_int,
    user = user, password = password
  )
}
