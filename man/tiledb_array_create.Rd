% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/Array.R
\name{tiledb_array_create}
\alias{tiledb_array_create}
\title{Creates a new TileDB array given an input schema.}
\usage{
tiledb_array_create(uri, schema, encryption_key)
}
\arguments{
\item{uri}{URI specifying path to create the TileDB array object}

\item{schema}{tiledb_array_schema object}

\item{encryption_key}{optional A character value with an AES-256 encryption key
in case the array should be encrypted.}
}
\description{
Creates a new TileDB array given an input schema.
}
\examples{
\dontshow{
ctx <- tiledb_ctx(limitTileDBCores())
}
\dontrun{
pth <- tempdir()
dom <- tiledb_domain(dims = c(tiledb_dim("d1", c(1L, 10L), type = "INT32")))
sch <- tiledb_array_schema(dom, attrs = c(tiledb_attr("a1", type = "INT32")))
tiledb_array_create(pth, sch)
tiledb_object_type(pth)
}

}
