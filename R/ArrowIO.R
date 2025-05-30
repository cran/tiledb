#  MIT License
#
#  Copyright (c) 2017-2024 TileDB Inc.
#
#  Permission is hereby granted, free of charge, to any person obtaining a copy
#  of this software and associated documentation files (the "Software"), to deal
#  in the Software without restriction, including without limitation the rights
#  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#  copies of the Software, and to permit persons to whom the Software is
#  furnished to do so, subject to the following conditions:
#
#  The above copyright notice and this permission notice shall be included in all
#  copies or substantial portions of the Software.
#
#  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
#  SOFTWARE.

##' Export Query Buffer to Pair of Arrow IO Pointers
##'
##' This function exports the named buffer from a \sQuote{READ} query
##' to two Arrow C pointers.
##' @param query A TileDB Query object
##' @param name A character variable identifying the buffer
##' @param ctx tiledb_ctx object (optional)
##' @return A \code{nanoarrow} object (which is an external pointer to an Arrow Array
##' with the Arrow Schema stored as the external pointer tag) classed as an S3 object
##' @export
tiledb_query_export_buffer <- function(query, name, ctx = tiledb_get_context()) {
  stopifnot(
    "The 'query' argument must be a tiledb query" = is(query, "tiledb_query"),
    "The 'name' argument must be character" = is.character(name)
  )
  res <- libtiledb_query_export_buffer(ctx@ptr, query@ptr, name)
  res
}

##' Import to Query Buffer from Pair of Arrow IO Pointers
##'
##' This function imports to the named buffer for a \sQuote{WRITE} query
##' from two Arrow exerternal pointers.
##' @param query A TileDB Query object
##' @param name A character variable identifying the buffer
##' @param nanoarrowptr A \code{nanoarrow} object (which is an external pointer to an Arrow Array
##' with the Arrow Schema stored as the external pointer tag) classed as an S3 object
##' @param ctx tiledb_ctx object (optional)
##' @return The update Query external pointer is returned
##' @export
tiledb_query_import_buffer <- function(query, name, nanoarrowptr, ctx = tiledb_get_context()) {
  stopifnot(
    "The 'query' argument must be a tiledb query" = is(query, "tiledb_query"),
    "The 'name' argument must be character" = is.character(name),
    "The 'nanoarrowptr' argument must be an 'nanoarrow' array object" =
      inherits(nanoarrowptr, "nanoarrow_array")
  )
  query@ptr <- libtiledb_query_import_buffer(ctx@ptr, query@ptr, name, nanoarrowptr)
  query
}

##' (Deprecated) Allocate (or Release) Arrow Array and Schema Pointers
##'
##' These functions allocate (and free) appropriate pointer objects
##' for, respectively, Arrow array and schema objects. These functions are
##' deprecated and will be removed, it is recommended to rely directly on
##' the `nanoarrow` replacements.
##' @param ptr A external pointer object previously allocated with these functions
##' @return The allocating functions return the requested pointer
##' @export
tiledb_arrow_array_ptr <- function() {
  .Deprecated(msg = "tiledb_arrow_array_ptr() is deprecated, please use nanoarrow::nanoarrow_allocate_array() instead.")
  res <- nanoarrow::nanoarrow_allocate_array()
}

##' @rdname tiledb_arrow_array_ptr
##' @export
tiledb_arrow_schema_ptr <- function() {
  .Deprecated(msg = "tiledb_arrow_schema_ptr() is deprecated, please use nanoarrow::nanoarrow_allocate_schema() instead.")
  res <- nanoarrow::nanoarrow_allocate_schema()
}

##' @rdname tiledb_arrow_array_ptr
##' @export
tiledb_arrow_array_del <- function(ptr) {
  .Deprecated(msg = "tiledb_arrow_array_del() is deprecated, please use nanoarrow::nanoarrow_pointer_release() instead.")
  nanoarrow::nanoarrow_pointer_release(ptr)
}

##' @rdname tiledb_arrow_array_ptr
##' @export
tiledb_arrow_schema_del <- function(ptr) {
  .Deprecated(msg = "tiledb_arrow_schema_del() is deprecated, please use nanoarrow::nanoarrow_pointer_release() instead.")
  nanoarrow::nanoarrow_pointer_release(ptr)
}

##' @noRd
.tiledb_set_arrow_config <- function(ctx = tiledb_get_context()) {
  cfg <- tiledb_config() # for var-num columns such as char we need these
  cfg["sm.var_offsets.bitsize"] <- "64"
  cfg["sm.var_offsets.mode"] <- "elements"
  cfg["sm.var_offsets.extra_element"] <- "true"
  ctx <- tiledb_ctx(cfg)
}

##' @noRd
.tiledb_unset_arrow_config <- function(ctx = tiledb_get_context()) {
  cfg <- tiledb_config() # for var-num columns such as char we need these
  cfg["sm.var_offsets.bitsize"] <- "64"
  cfg["sm.var_offsets.mode"] <- "bytes"
  cfg["sm.var_offsets.extra_element"] <- "false"
  ctx <- tiledb_ctx(cfg)
}
