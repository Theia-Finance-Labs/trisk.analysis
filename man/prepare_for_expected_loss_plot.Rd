% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/plot_expected_loss.R
\name{prepare_for_expected_loss_plot}
\alias{prepare_for_expected_loss_plot}
\title{Data Preparation for Financial Risk Visualization}
\usage{
prepare_for_expected_loss_plot(analysis_data, facet_var)
}
\arguments{
\item{analysis_data}{Dataset including detailed financial risk metrics, to be transformed for visualization.}

\item{facet_var}{Segmentation variable used to categorize and analyze financial risk across different divisions.}
}
\value{
Dataframe optimized for visualizing financial risk, with aggregated metrics for each segment.
}
\description{
Prepares dataset for plotting by transforming financial risk data, including expected losses and exposure values, into a format that allows for aggregated analysis across specified segments. Essential for highlighting financial vulnerabilities and focusing risk management efforts.
}
