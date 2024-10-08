% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/plot_multi_trajectories.R
\name{draw_trisk_line_plot}
\alias{draw_trisk_line_plot}
\title{Draw Line Plot for Risk Trajectories}
\usage{
draw_trisk_line_plot(
  data_trisk_line_plot,
  x_var,
  facet_var,
  linecolor,
  y_in_percent
)
}
\arguments{
\item{data_trisk_line_plot}{Prepared data for plotting, with production percentages.}

\item{x_var}{Time variable for the x-axis.}

\item{facet_var}{Variable for faceting plots by business units.}

\item{linecolor}{Variable for coloring lines by sector.}

\item{y_in_percent}{plots in percent or absolute}
}
\value{
A ggplot object illustrating risk trajectories over time, aiding in the analysis of production risk and scenario planning.
}
\description{
Creates a line plot to depict the "production_shock_scenario" risk trajectories as a percentage of the maximum value, offering a visual comparison within business units and sectors.
}
