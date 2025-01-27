#' Fetch Data from PostgreSQL and Run Transition Risk Aggregation
#'
#' This function connects to a PostgreSQL database, retrieves required datasets,
#' and runs the `run_trisk_agg` function to perform transition risk aggregation.
#'
#' @details The database connection parameters are hardcoded within the function:
#' - `dbname`: "crispydb"
#' - `host`: "localhost"
#' - `port`: 5432
#' - `user`: "crispydb_user"
#' - `password`: "crispypassword"
#'
#' The function fetches the following datasets from the database:
#' - `assets_data` (retrieved from the `assets_data` table)
#' - `scenarios_data` (retrieved from the `scenarios_data` table)
#' - `financial_data` (retrieved from the `financial_data` table)
#' - `carbon_data` (retrieved from the `carbon_data` table)
#'
#' After retrieving the data, it passes them along with additional parameters
#' to the `run_trisk_agg` function and returns the results.
#'
#' @param baseline_scenario A character string representing the baseline scenario.
#' @param target_scenario A character string representing the target scenario.
#' @param ... Additional parameters passed to the `run_trisk_agg` function.
#'
#' @return A list containing the results of the `run_trisk_agg` function:
#' - `npv_results`: Net Present Value results.
#' - `pd_results`: Probability of Default results.
#' - `company_trajectories`: Aggregated company trajectories.
#'
#' @examples
#' # Run the function with example scenarios
#' result <- fetch_and_run_trisk(
#'   baseline_scenario = "BaselineScenarioName",
#'   target_scenario = "TargetScenarioName",
#'   additional_param1 = "value1",
#'   additional_param2 = "value2"
#' )
#'
#' @importFrom DBI dbConnect dbDisconnect dbGetQuery
#' @importFrom RPostgres Postgres
#' @export
run_trisk_from_db <- function(
    baseline_scenario,
    target_scenario,
    ...) {
  # Database connection parameters
  dbname <- "crispydb"
  host <- "localhost"
  port <- 5432
  user <- "crispydb_user"
  password <- "crispypassword"

  # Establish database connection
  db_connection <- DBI::dbConnect(
    RPostgres::Postgres(),
    dbname = dbname,
    host = host,
    port = port,
    user = user,
    password = password
  )

  on.exit(DBI::dbDisconnect(db_connection)) # Ensure connection is closed on exit

  # Fetch datasets from the database
  assets_data <- DBI::dbGetQuery(db_connection, "SELECT * FROM public_marts.assets")
  scenarios_data <- DBI::dbGetQuery(db_connection, "SELECT * FROM public_marts.scenarios")
  financial_data <- DBI::dbGetQuery(db_connection, "SELECT * FROM public_marts.financial_features")
  carbon_data <- DBI::dbGetQuery(db_connection, "SELECT * FROM public_marts.ngfs_carbon_prices")

  # Call the aggregation function
  results <- run_trisk_agg(
    assets_data = assets_data,
    scenarios_data = scenarios_data,
    financial_data = financial_data,
    carbon_data = carbon_data,
    baseline_scenario = baseline_scenario,
    target_scenario = target_scenario,
    ...
  )

  return(results)
}
