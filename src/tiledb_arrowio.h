/**      -*-C++-*-
 * vim: set ft=cpp:
 * @file   arrowio
 *
 * @section LICENSE
 *
 * The MIT License
 *
 * @copyright Copyright (c) 2020-2021 TileDB, Inc.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 * @section DESCRIPTION
 *
 * This file defines the experimental TileDB interoperation with Apache Arrow.
 */

#include <memory>

//#include "tiledb"

namespace tiledb {
namespace arrow {

class ArrowImporter;
class ArrowExporter;

/**
 * Adapter to export TileDB (read) Query results to Apache Arrow buffers
 * and import Arrow buffers into a TileDB (write) Query.
 *
 * This adapter exports buffers conforming to the Arrow C Data Interface
 * as documented at:
 *
 *   https://arrow.apache.org/docs/format/CDataInterface.html
 *
 */

class ArrowAdapter {
public:
  /* Constructs an ArrowAdapter wrapping the given TileDB C++ Query */
  ArrowAdapter(Context *ctx, Query *query);
  ~ArrowAdapter();

  /**
   * Exports named Query buffer to ArrowArray/ArrowSchema struct pair,
   * as defined in the Arrow C Data Interface.
   *
   * @param name The name of the buffer to export.
   * @param arrow_array Pointer to pre-allocated ArrowArray struct
   * @param arrow_schema Pointer to pre-allocated ArrowSchema struct
   * @throws tiledb::TileDBError with error-specific message.
   */
  void export_buffer(const char *name, void *arrow_array, void *arrow_schema);

  /**
   * Set named Query buffer from ArrowArray/ArrowSchema struct pair
   * representing external data buffers conforming to the
   * Arrow C Data Interface.
   *
   * @param name The name of the buffer to export.
   * @param arrow_array Pointer to pre-allocated ArrowArray struct
   * @param arrow_schema Pointer to pre-allocated ArrowSchema struct
   * @throws tiledb::TileDBError with error-specific message.
   */
  void import_buffer(const char *name, void *arrow_array, void *arrow_schema);

private:
  ArrowImporter *importer_;
  ArrowExporter *exporter_;
};

} // end namespace arrow
} // end namespace tiledb

#include "updated_arrow_io_impl.h"
