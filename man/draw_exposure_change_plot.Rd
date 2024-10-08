% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/plot_exposure_change.R
\name{draw_exposure_change_plot}
\alias{draw_exposure_change_plot}
\title{Generate Exposure Change and Value Loss Plot}
\usage{
draw_exposure_change_plot(
  data_exposure_change,
  x_var,
  y_exposure_var,
  y_value_loss_var,
  facet_var = NULL
)
}
\arguments{
\item{data_exposure_change}{Prepared dataframe for plotting.}

\item{x_var}{Category or sector variable for the x-axis.}

\item{y_exposure_var}{Metric for exposure value.}

\item{y_value_loss_var}{Metric for crispy value loss.}

\item{facet_var}{Optional; variable to facet the plot by.}
}
\value{
A ggplot object depicting exposure changes and value losses, crucial for detailed financial impact analysis.
}
\description{
Constructs the final plot visualizing sector/category-wise changes in financial exposure and value losses, using a combination of bar and tile geoms to represent data points and their positive/negative changes. Faceting can be applied for more detailed analysis. This function integrates aesthetic elements and scales to effectively communicate the financial impact.
}
