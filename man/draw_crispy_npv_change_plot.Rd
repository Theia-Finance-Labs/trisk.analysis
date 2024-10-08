% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/plot_npv_change.R
\name{draw_crispy_npv_change_plot}
\alias{draw_crispy_npv_change_plot}
\title{Construct NPV Change Visualization Plot}
\usage{
draw_crispy_npv_change_plot(data_crispy_npv_change_plot, x_var, y_var)
}
\arguments{
\item{data_crispy_npv_change_plot}{Prepared dataframe for plotting.}

\item{x_var}{Unified sector categorization variable.}

\item{y_var}{NPV change percentage variable.}
}
\value{
A ggplot object depicting NPV changes across sectors, crucial for assessing financial impact and strategic direction.
}
\description{
Creates the final visualization for NPV percentage changes across sectors using a color gradient to represent increase, decrease, or no change. This function applies a gradient scale to highlight variations in NPV change, facilitating an intuitive understanding of financial performance across sectors.
}
