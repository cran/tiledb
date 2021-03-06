% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/TileDBArray.R
\name{array_vacuum}
\alias{array_vacuum}
\title{After consolidation, remove consilidated fragments of a TileDB Array}
\usage{
array_vacuum(uri, cfg = NULL, ctx = tiledb_get_context())
}
\arguments{
\item{uri}{A character value with the URI of a TileDB Array}

\item{cfg}{An optional TileDB Configuration object}

\item{ctx}{An option TileDB Context object}
}
\value{
\code{NULL} is returned invisibly
}
\description{
This function can remove fragments following a consolidation step. Note that vacuuming
should \emph{not} be run if one intends to use the TileDB \emph{time-traveling} feature
of opening arrays at particular timestamps
}
