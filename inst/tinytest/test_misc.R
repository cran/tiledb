
library(tinytest)
library(tiledb)

isOldWindows <- Sys.info()[["sysname"]] == "Windows" && grepl('Windows Server 2008', osVersion)
if (isOldWindows) exit_file("skip this file on old Windows releases")

ctx <- tiledb_ctx(limitTileDBCores())

if (tiledb_version(TRUE) < "2.6.0") exit_file("These tests require TileDB 2.6.0 or newer")

if (is.null(get0("tiledb_error_message"))) exit_file("No 'tiledb_error_message'")
expect_true(inherits(tiledb_error_message(), "character"))
expect_true(is.character(tiledb_error_message()))