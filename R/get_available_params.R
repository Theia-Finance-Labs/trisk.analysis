#' Get the possible parameters values for Trisk from the scenario data
#'
#' @param scenarios scenarios dataframe
#'
#' @return Available scenarios parameters
#' @export
get_available_parameters <- function(scenarios) {
  # Fetch all distinct scenarios
  scenarios_df <- scenarios %>% dplyr::distinct(
    .data$scenario, .data$scenario_type, .data$scenario_geography, .data$scenario_provider
  )

  combinations <- list()

  if (nrow(scenarios_df) > 0) {
    # Separate baseline and target scenarios
    baseline_scenarios <- scenarios_df %>%
      dplyr::filter(.data$scenario_type == "baseline") %>%
      dplyr::select(.data$scenario_provider, .data$scenario_geography, .data$scenario) %>%
      dplyr::rename(baseline_scenario = .data$scenario) %>%
      dplyr::distinct()

    target_scenarios <- scenarios_df %>%
      dplyr::filter(.data$scenario_type == "target") %>%
      dplyr::select(.data$scenario_provider, .data$scenario_geography, .data$scenario) %>%
      dplyr::rename(target_scenario = .data$scenario) %>%
      dplyr::distinct()

    # Merge baseline and target scenarios based on scenario_provider and geography
    possible_combinations <- dplyr::inner_join(
      baseline_scenarios, target_scenarios,
      by = c("scenario_provider", "scenario_geography")
    )
  }

  return(possible_combinations)
}
