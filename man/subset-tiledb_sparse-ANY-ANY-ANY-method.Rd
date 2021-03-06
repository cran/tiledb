% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/SparseArray.R
\name{[<-,tiledb_sparse,ANY,ANY,ANY-method}
\alias{[<-,tiledb_sparse,ANY,ANY,ANY-method}
\alias{[<-,tiledb_sparse}
\alias{[<-,tiledb_sparse-method}
\alias{[<-,tiledb_sparse,ANY,tiledb_sparse-method}
\alias{[<-,tiledb_sparse,ANY,ANY,tiledb_sparse-method}
\title{Sets a sparse array value}
\usage{
\S4method{[}{tiledb_sparse,ANY,ANY,ANY}(x, i, j, ...) <- value
}
\arguments{
\item{x}{sparse array object}

\item{i}{parameter key string}

\item{j}{parameter key string, currently unused.}

\item{...}{Extra parameter for method signature, currently unused.}

\item{value}{The value being assigned}
}
\value{
The modified object
}
\description{
Sets a sparse array value
}
