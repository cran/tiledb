% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/ArraySchema.R
\name{filter_list,tiledb_array_schema-method}
\alias{filter_list,tiledb_array_schema-method}
\title{Returns the offsets and coordinate filter_lists associated with the \code{tiledb_array_schema}}
\usage{
\S4method{filter_list}{tiledb_array_schema}(object)
}
\arguments{
\item{object}{A TileDB Schema object}
}
\value{
A list of \code{tiledb_filter_list} objects
}
\description{
Returns the offsets and coordinate filter_lists associated with the \code{tiledb_array_schema}
}
