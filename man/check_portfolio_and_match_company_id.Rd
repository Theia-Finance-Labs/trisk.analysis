% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/run_trisk_on_portfolio.R
\name{check_portfolio_and_match_company_id}
\alias{check_portfolio_and_match_company_id}
\title{Check Portfolio and Match Company IDs}
\usage{
check_portfolio_and_match_company_id(portfolio_data, assets_data)
}
\arguments{
\item{portfolio_data}{Data frame containing portfolio information.}

\item{assets_data}{Data frame containing asset information with company IDs.}
}
\value{
A data frame of portfolio data with matched company IDs.
}
\description{
This function checks if the portfolio data contains all required columns and
performs a fuzzy match to assign company IDs based on company names.
}
