<!--
%\VignetteIndexEntry{TileDB RMariaDB Examples}
%\VignetteEngine{simplermarkdown::mdweave_to_html}
%\VignetteEncoding{UTF-8}
-->
---
title: "TileDB and (R)MariaDB Examples"
css: "water.css"
---

## Introduction

[TileDB](https://www.tiledb.com/) provides the _Universal Data Engine_ that
can be accessed in a variety of ways. The C/C++ library offered by [TileDB
Embedded](https://www.tiledb.com/embedded) is one approach, and the [R
package](https://github.com/TileDB-Inc/TileDB-R), as well as the [Python
package](https://github.com/TileDB-Inc/TileDB-Py) and other language
bindings use it. Another interface is provided by the [MariaDB Integration
via the MyTile storage plugin](https://docs.tiledb.com/mariadb/).

This provides TileDB integration with any frontend that interfaces with
MariaDB---such as the
[RMariaDB](https://cran.r-project.org/package=RMariaDB) package for R.  So
this vignette illustrates the use of TileDB via MariaDB using R and the
RMariaDB packages.

## Installation or Using Docker

In order to use the MyTile storage plugin, one has to compile both the
storage plugin itself and the MariaDB server with consistent compiler flags.
As the build also requires the TileDB Embedded library and headers, using a
Docker container may be easiest.  The Dockerfile also provides a concrete
example of the build setup.

So here we will use the [`tiledb/tiledb-mariadb-r`](https://hub.docker.com/r/tiledb/tiledb-mariadb-r) container.

#### Launch Container in Background

We launch the container 'tiledb/tiledb-mariadb-r' as a daemon, allowing
MariaDB to accept an empty password (using an older MySQL variable setting), and
name the running image 'tiledb-mariadb-r':

```sh
docker run --name tiledb-mariadb-r -it -d --rm \
       -e MYSQL_ALLOW_EMPTY_PASSWORD=1 tiledb/tiledb-mariadb-r
```

#### Access Container Once to Write via TileDB

Using the name given to the running instance, we start an R session to write
data with TileDB:

```sh
docker exec -it -u root tiledb-mariadb-r R
```

## Examples

### Palmer Penguins

With the sessions started as in the previous section, we start an R session.

```r
> library(tiledb)
> library(palmerpenguins)
> praw <- penguins_raw
> fromDataFrame(praw, "/tmp/penguinsraw")
```


#### Access Container Again to Read via RMariaDB

In another shell, we can access the container once more and launch another R
process:

```sh
docker exec -it -u root tiledb-mariadb-r R
```

where we use RMariaDB to access the data via a `tibble` object and `magrittr` pipe

```r
> library(RMariaDB)
> library(dplyr, warn.conflicts=FALSE)
> con <- DBI::dbConnect(RMariaDB::MariaDB(), dbname="test")
> tbl(con, "/tmp/penguinsraw") %>%
+        dplyr::select(contains("Length"))
# Source:   lazy query [?? x 2]
# Database: mysql [@localhost:NA/test]
   `Culmen Length (mm)` `Flipper Length (mm)`
                  <dbl>                 <dbl>
 1                 39.1                   181
 2                 39.5                   186
 3                 40.3                   195
 4                 NA                      NA
 5                 36.7                   193
 6                 39.3                   190
 7                 38.9                   181
 8                 39.2                   195
 9                 34.1                   193
10                 42                     190
# ... with more rows
```

Note that this R session uses TileDB only via the MyTile plugin which is
activated implicitly via the 'table location' (here `/tmp/penguinsraw`) of
the test database enabling plugins.

Also note that the query is still 'lazy': only column names
and the first ten observations have been retrieved, and the total size is still
unknown as indicated by `lazy query [?? x 2]`.  Adding a `collect()` verb
materialized the full subset.

```r
> tbl(con, "/tmp/penguinsraw")  %>%
+     dplyr::select(contains("Length")) %>%
+     collect()
# A tibble: 344 x 2
   `Culmen Length (mm)` `Flipper Length (mm)`
                  <dbl>                 <dbl>
 1                 39.1                   181
 2                 39.5                   186
 3                 40.3                   195
 4                 NA                      NA
 5                 36.7                   193
 6                 39.3                   190
 7                 38.9                   181
 8                 39.2                   195
 9                 34.1                   193
10                 42                     190
# ... with 334 more rows
>
```

We now see that all 344 rows of this particular result set have been accessed.

Similarly, we can also run summaries on selected column:

```r
> tbl(con, "/tmp/penguinsraw") %>%
+     group_by(Species) %>%
+     summarise(across(starts_with("Flipper"),
+                      list(~mean(.x, na.rm=TRUE), ~sd(.x, na.rm=TRUE))))
# Source:   lazy query [?? x 3]
# Database: mysql [@localhost:NA/test]
  Species              `\`Flipper Length (mm)\`_~me~ `\`Flipper Length (mm)\`_~~
  <chr>                                        <dbl>                       <dbl>
1 Adelie Penguin (Pyg~                          190.                        6.54
2 Chinstrap penguin (~                          196.                        7.13
3 Gentoo penguin (Pyg~                          217.                        6.48
>
```

### DBI

We can connect directly using the `DBI` package along with the `RMariaDB`
package and its MyTile bindings:

```r
library(DBI)
con <- dbConnect(RMariaDB::MariaDB(), dbname="test")
res <- dbSendQuery(con, "select * from `/work/penguins` as `q91` limit 10")
df <- dbFetch(res, n = 10)
dbClearResult(res)
print(df)
dbDisconnect(con)
```

### S3

When using Docker, the container setup needs to be modified to include the required AWS access environment variables:

```sh
docker run --name tiledb-mariadb-r \
       -it -d --rm \
       -v $PWD:/work -w /work \
       -e MYSQL_ALLOW_EMPTY_PASSWORD=1 \
       -e AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY} \
       -e AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID} \
       tiledb/tiledb-mariadb-r
```

This exports the current working directory (accessed as `$PWD` in the shell)
as `/work` inside the container (via the `-v` switch), and instructs the
container to start in directory `/work` (via the `-w` switch).

In the following example we also set a TileDB configuration option to switch
AWS regions.

```r
> library(dplyr, warn.conflicts=FALSE)
> # connect as usual
> con <- DBI::dbConnect(RMariaDB::MariaDB(), dbname="test")
> # use connection to update config in order to switch s3 regions
> res1 <- DBI::dbSendQuery(con, "set mytile_tiledb_config=\"vfs.s3.region=us-west-1\";")
> DBI::dbClearResult(res1)
> # run simple query
> tbl(con, "s3://tiledb-public-us-west-1/test-array-4x4") %>% collect()
# A tibble: 16 x 3
   `__dim_0` `__dim_1` `__attr`
     <int64>   <int64>    <dbl>
 1         0         0   0.397
 2         0         1   0.432
 3         0         2   0.617
 4         0         3   0.403
 5         1         0   0.837
 6         1         1   0.670
 7         1         2   0.235
 8         1         3   0.841
 9         2         0   0.222
10         2         1   0.468
11         2         2   0.970
12         2         3   0.551
13         3         0   0.628
14         3         1   0.0149
15         3         2   0.0540
16         3         3   0.445
>
> DBI::dbDisconnect(con)  # close connection
```

### NYC Taxis

We can write the New York taxi data into TileDB (in the current directory)
after reading it as a csv:

```r
> nyc <- data.table::fread("trip_data_1.csv")
> tiledb::fromDataFrame(nyc, "trip_data_1")
```

Then we can access it via the path `/work/trip_data_1` via RMariaDB.

```r
> library(dplyr, warn.conflicts=FALSE)
> con <- DBI::dbConnect(RMariaDB::MariaDB(), dbname="test")
> # list column names
> tbl(con, "/work/trip_data_1") %>% colnames()
> tbl(con, "/work/trip_data_1") %>% colnames()
 [1] "__tiledb_rows"      "dropoff_latitude"   "medallion"
 [4] "hack_license"       "dropoff_longitude"  "vendor_id"
 [7] "rate_code"          "store_and_fwd_flag" "pickup_datetime"
[10] "dropoff_datetime"   "trip_time_in_secs"  "pickup_latitude"
[13] "passenger_count"    "trip_distance"      "pickup_longitude"
> # extract one column (here passenger_count) completely and tabulate in R
> tbl(con, "/work/trip_data_1") %>% select(passenger_count) %>% collect() %>% table()
.
       0        1        2        3        4        5        6        9
     166 10471701  1986196   597485   280992   920006   520066        1
     208      255
       1        1
> # alternatively, run a lazy query
> tbl(con, "/work/trip_data_1") %>% group_by(passenger_count) %>% summarize(nobs = n())
# Source:   lazy query [?? x 2]
# Database: mysql [@localhost:NA/test]
   passenger_count     nobs
             <int>  <int64>
 1               0      166
 2               1 10471701
 3               2  1986196
 4               3   597485
 5               4   280992
 6               5   920006
 7               6   520066
 8               9        1
 9             208        1
10             255        1
> # here the request is actually sent as SQL and the computation is done in the SQL layer
> tbl(con, "/work/trip_data_1")  %>%
+      group_by(passenger_count) %>%
+      summarize(nobs = n())     %>%
+      show_query()
<SQL>
SELECT `passenger_count`, COUNT(*) AS `nobs`
FROM `/work/trip_data_1`
GROUP BY `passenger_count`
> # naturally we can also send the query directly to the SQL backend
> sql <- "SELECT passenger_count, count(*) AS n FROM `/work/trip_data_1` GROUP BY passenger_count;"
> DBI::dbGetQuery(con, sql)
   passenger_count        n
1                0      166
2                1 10471701
3                2  1986196
4                3   597485
5                4   280992
6                5   920006
7                6   520066
8                9        1
9              208        1
10             255        1
>
> DBI::dbDisconnect(con)  # close connection
```

## Summary

This short vignette demonstrates the use of TileDB-stored data from R using
RMariaDB via the MyTile storage extension to MariaBD.
