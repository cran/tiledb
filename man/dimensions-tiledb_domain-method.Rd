% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/Domain.R
\name{dimensions,tiledb_domain-method}
\alias{dimensions,tiledb_domain-method}
\title{Returns a list of the tiledb_domain dimension objects}
\usage{
\S4method{dimensions}{tiledb_domain}(object)
}
\arguments{
\item{object}{tiledb_domain}
}
\value{
a list of tiledb_dim
}
\description{
Returns a list of the tiledb_domain dimension objects
}
\examples{
\dontshow{
ctx <- tiledb_ctx(limitTileDBCores())
}
dom <- tiledb_domain(dims = c(
  tiledb_dim("d1", c(1L, 100L), type = "INT32"),
  tiledb_dim("d2", c(1L, 50L), type = "INT32")
))
dimensions(dom)

lapply(dimensions(dom), name)

}
