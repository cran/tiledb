% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/VFS.R
\name{tiledb_vfs_file_size}
\alias{tiledb_vfs_file_size}
\title{Return VFS File Size}
\usage{
tiledb_vfs_file_size(uri, vfs = tiledb_get_vfs())
}
\arguments{
\item{uri}{Character variable with a URI describing a file path}

\item{vfs}{A TileDB VFS object; default is to use a cached value.}
}
\value{
The size of the file
}
\description{
Return VFS File Size
}
