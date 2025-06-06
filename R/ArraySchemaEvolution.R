#  MIT License
#
#  Copyright (c) 2023 TileDB Inc.
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

#' An S4 class for a TileDB ArraySchemaEvolution object
#'
#' @slot ptr An external pointer to the underlying implementation
#' @exportClass tiledb_array_schema_evolution
setClass("tiledb_array_schema_evolution",
  slots = list(ptr = "externalptr")
)

#' Creates a 'tiledb_array_schema_evolution' object
#'
#' @param ctx (optional) A TileDB Ctx object; if not supplied the default
#' context object is retrieved
#' @return A 'array_schema_evolution' object
#' @export
tiledb_array_schema_evolution <- function(ctx = tiledb_get_context()) {
  stopifnot(`The 'ctx' argument must be a Context object` = is(ctx, "tiledb_ctx"))
  ptr <- libtiledb_array_schema_evolution(ctx@ptr)
  array_schema_evolution <- new("tiledb_array_schema_evolution", ptr = ptr)
  invisible(array_schema_evolution)
}

#' Add an Attribute to a TileDB Array Schema Evolution object
#'
#' @param object A TileDB 'array_schema_evolution' object
#' @param attr A TileDB attribute
#' @return The modified 'array_schema_evolution' object, invisibly
#' @export
tiledb_array_schema_evolution_add_attribute <- function(object, attr) {
  stopifnot(
    `The first argument must be a Array Schema Evolution object` =
      is(object, "tiledb_array_schema_evolution"),
    `The 'attr' argument must be an Attribute object` = is(attr, "tiledb_attr")
  )
  object@ptr <- libtiledb_array_schema_evolution_add_attribute(object@ptr, attr@ptr)
  invisible(object)
}

#' Drop an attribute given by name from a TileDB Array Schema Evolution object
#'
#' @param object A TileDB 'array_schema_evolution' object
#' @param attrname A character variable with an attribute name
#' @return The modified 'array_schema_evolution' object, invisibly
#' @export
tiledb_array_schema_evolution_drop_attribute <- function(object, attrname) {
  stopifnot(
    `The first argument must be a Array Schema Evolution object` =
      is(object, "tiledb_array_schema_evolution"),
    `The 'attrname' argument must be character variable` = is.character(attrname)
  )
  object@ptr <- libtiledb_array_schema_evolution_drop_attribute(object@ptr, attrname)
  invisible(object)
}

#' Evolve an Array Schema
#'
#' @param object A TileDB 'array_schema_evolution' object
#' @param uri A character variable with an URI
#' @return The modified 'array_schema_evolution' object, invisibly
#' @export
tiledb_array_schema_evolution_array_evolve <- function(object, uri) {
  stopifnot(
    `The first argument must be a Array Schema Evolution object` =
      is(object, "tiledb_array_schema_evolution"),
    `The 'uri' argument must be character variable` = is.character(uri)
  )
  object@ptr <- libtiledb_array_schema_evolution_array_evolve(object@ptr, uri)
  invisible(object)
}

#' Add an Enumeration to a TileDB Array Schema Evolution object
#'
#' @param object A TileDB 'array_schema_evolution' object
#' @param name A character value with the name for the Enumeration
#' @param enums A character vector
#' @param ordered (optional) A boolean switch whether the enumeration is ordered
#' @param ctx (optional) A TileDB Ctx object; if not supplied the default
#' context object is retrieved
#' @return The modified 'array_schema_evolution' object, invisibly
#' @export
tiledb_array_schema_evolution_add_enumeration <- function(
  object, 
  name, 
  enums, 
  ordered = FALSE,
  ctx = tiledb_get_context()
) {
  stopifnot(
    "The first argument must be an Array Schema Evolution object" =
      is(object, "tiledb_array_schema_evolution"),
    "The 'name' argument must be a scalar character object" =
      is.character(name) && length(name) == 1,
    "The 'enumlist' argument must be a character object" = is.character(enums),
    "This function needs TileDB 2.17.0 or later" = tiledb_version(TRUE) >= "2.17.0",
    "The 'ctx' argument must be a Context object" = is(ctx, "tiledb_ctx")
  )
  object@ptr <- libtiledb_array_schema_evolution_add_enumeration(
    ctx@ptr, object@ptr, name,
    enums, FALSE, ordered
  )
  invisible(object)
}

#' Drop an Enumeration given by name from a TileDB Array Schema Evolution object
#'
#' @param object A TileDB 'array_schema_evolution' object
#' @param attrname A character variable with an attribute name
#' @return The modified 'array_schema_evolution' object, invisibly
#' @export
tiledb_array_schema_evolution_drop_enumeration <- function(object, attrname) {
  stopifnot(
    "The first argument must be an Array Schema Evolution object" =
      is(object, "tiledb_array_schema_evolution"),
    "The 'attrname' argument must be a character variable" = is.character(attrname),
    "This function needs TileDB 2.17.0 or later" = tiledb_version(TRUE) >= "2.17.0"
  )
  object@ptr <- libtiledb_array_schema_evolution_drop_enumeration(object@ptr, attrname)
  invisible(object)
}

#' Evolve an Array Schema by adding an empty Enumeration
#'
#' @param ase An ArraySchemaEvolution object
#' @param enum_name A character value with the Enumeration name
#' @param type_str A character value with the TileDB type, defaults to \sQuote{ASCII}
#' @param cell_val_num An integer with number values per cell, defaults to \code{NA_integer_} to
#' flag the \code{NA} value use for character values
#' @param ordered A logical value indicating standard \code{factor} (when \code{FALSE}, the default)
#' or \code{ordered} (when \code{TRUE})
#' @param ctx Optional tiledb_ctx object
#' @export
tiledb_array_schema_evolution_add_enumeration_empty <- function(
  ase, 
  enum_name, 
  type_str = "ASCII",
  cell_val_num = NA_integer_,
  ordered = FALSE,
  ctx = tiledb_get_context()
) {
  stopifnot(
    "Argument 'ase' must be an Array Schema Evolution object" =
      is(ase, "tiledb_array_schema_evolution"),
    "Argument 'enum_name' must be character" = is.character(enum_name),
    "Argument 'type_str' must be character" = is.character(type_str),
    "Argument 'cell_val_num' must be integer" = is.integer(cell_val_num),
    "Argument 'ordered' must be logical" = is.logical(ordered),
    "Argument 'ctx' must be a 'tiledb_ctx'" = is(ctx, "tiledb_ctx")
  )
  ase@ptr <- libtiledb_array_schema_evolution_add_enumeration_empty(
    ctx@ptr, ase@ptr,
    enum_name, type_str, cell_val_num,
    ordered
  )
  ase
}

#' Extend an Evolution via Array Schema Evolution
#'
#' @param ase An ArraySchemaEvolution object
#' @param array A TileDB Array object
#' @param enum_name A character value with the Enumeration name
#' @param new_values A character vector with the new Enumeration values
#' @param nullable A logical value indicating if the Enumeration can contain missing values
#' (with a default of \code{FALSE})
#' @param ordered A logical value indicating standard \code{factor} (when \code{FALSE}, the default)
#' or \code{ordered} (when \code{TRUE})
#' @param ctx Optional tiledb_ctx object
#' @return The modified ArraySchemaEvolution object
#' @export
tiledb_array_schema_evolution_extend_enumeration <- function(
  ase, 
  array, 
  enum_name,
  new_values, 
  nullable = FALSE,
  ordered = FALSE,
  ctx = tiledb_get_context()
) {
  stopifnot(
    "Argument 'ase' must be an Array Schema Evolution object" =
      is(ase, "tiledb_array_schema_evolution"),
    "Argument 'array' must be a TileDB Array" = is(array, "tiledb_array"),
    "Argument 'enum_name' must be character" = is.character(enum_name),
    "Argument 'new_values' must be character" = is.character(new_values),
    "Argument 'nullable' must be logical" = is.logical(nullable),
    "Argument 'ordered' must be logical" = is.logical(ordered),
    "Argument 'ctx' must be a 'tiledb_ctx'" = is(ctx, "tiledb_ctx")
  )
  ase@ptr <- libtiledb_array_schema_evolution_extend_enumeration(
    ctx@ptr, ase@ptr, array@ptr,
    enum_name, new_values,
    nullable, ordered
  )
  ase
}

#' Expand an the Current Domain of an Array via Array Schema Evolution
#'
#' @param ase An ArraySchemaEvolution object
#' @param cd A CurrentDomain object
#' @return The modified ArraySchemaEvolution object
#' @export
tiledb_array_schema_evolution_expand_current_domain <- function(ase, cd) {
  stopifnot(
    "Argument 'ase' must be an Array Schema Evolution object" =
      is(ase, "tiledb_array_schema_evolution"),
    "Argument 'cd' must be a CurrentDomain object" = is(cd, "tiledb_current_domain"),
    "This function needs TileDB 2.26.0 or later" = tiledb_version(TRUE) >= "2.26.0"
  )
  ase@ptr <- libtiledb_array_schema_evolution_expand_current_domain(ase@ptr, cd@ptr)
  ase
}
