## -*- mode: autoconf; autoconf-indentation: 4; -*-

##  MIT License
##
##  Copyright (c) 2017-2024 TileDB Inc.
##
##  Permission is hereby granted, free of charge, to any person obtaining a copy
##  of this software and associated documentation files (the "Software"), to deal
##  in the Software without restriction, including without limitation the rights
##  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
##  copies of the Software, and to permit persons to whom the Software is
##  furnished to do so, subject to the following conditions:
##
##  The above copyright notice and this permission notice shall be included in all
##  copies or substantial portions of the Software.
##
##  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
##  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
##  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
##  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
##  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
##  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
##  SOFTWARE.

## require at least autoconf 2.69
AC_PREREQ([2.69])
AC_INIT([TileDB-R],[0.28.0])

## -- Part 1: Setup -------------------------------------------------------------
##
## this has to come early to affect other queries involving R
: ${R_HOME=`R RHOME`}
if test -z "${R_HOME}"; then
    echo "could not determine R_HOME"
    exit 1
fi

CXX=`"${R_HOME}/bin/R" CMD config CXX`
if test -z "${CXX}"; then
    AC_MSG_ERROR([No C++ compiler available])
fi
CXXFLAGS=`"${R_HOME}/bin/R" CMD config CXXFLAGS`
CPPFLAGS=`"${R_HOME}/bin/R" CMD config CPPFLAGS`
CXX11FLAGS=`"${R_HOME}/bin/R" CMD config CXX11FLAGS`
CXX17FLAGS=`"${R_HOME}/bin/R" CMD config CXX17FLAGS`
DYLIB_EXT=`"${R_HOME}/bin/R" CMD config DYLIB_EXT`

AC_LANG(C++)
AC_REQUIRE_CPP
AC_PROG_CXX
m4_include([tools/m4/ax_cxx_compile_stdcxx.m4])
AX_CXX_COMPILE_STDCXX([17])

## Can we use pkg-config?
AC_PATH_PROG(have_pkg_config, pkg-config, no)
## If yes, also check for whether pkg-config knows tiledb
if test x"${have_pkg_config}" != x"no"; then
    AC_MSG_CHECKING([if pkg-config knows TileDB])
    if pkg-config --exists tiledb; then
        AC_MSG_RESULT([yes])
        tiledb_include=$(pkg-config --cflags tiledb)
        tiledb_libs=$(pkg-config --libs tiledb)
        AC_SUBST([TILEDB_INCLUDE], "${tiledb_include}")
        AC_SUBST([TILEDB_LIBS],    "${tiledb_libs}")
        AC_SUBST([TILEDB_RPATH],   "")
    else
        AC_MSG_RESULT([no])
        have_pkg_config="no"
    fi
fi

## Otherwise use fallback values
if test x"${have_pkg_config}" = x"no"; then
    ## Default values suitable for system install, overridde as needed below
    AC_SUBST([TILEDB_INCLUDE], "")
    AC_SUBST([TILEDB_LIBS], "-ltiledb")
    AC_SUBST([TILEDB_RPATH], "")
    ## For TileDB older than 2.15 we use this to silence a deprecation warning
    AC_SUBST([TILEDB_SILENT_BUILD], "-DTILEDB_SILENT_BUILD")
fi

## If we have pkg-config, use it to test minimal version
if test x"${have_pkg_config}" != x"no"; then
    AC_MSG_CHECKING([for pkg-config checking TileDB version])
    if pkg-config --atleast-version=2.7.0 tiledb; then
        AC_MSG_RESULT([>= 2.7.0])
    else
        AC_MSG_RESULT([insufficient])
        AC_MSG_ERROR([TileDB Embedded 2.7.0 or later is required.])
    fi
    AC_MSG_CHECKING([for pkg-config checking TileDB deprecation silencer])
    if pkg-config --atleast-version=2.15.0 tiledb; then
        ## For TileDB 2.15 or newer are fine
        AC_MSG_RESULT([not required])
        AC_SUBST([TILEDB_SILENT_BUILD], "")
    else
        ## For TileDB older than 2.15 we use this to silence a deprecation warning
        AC_MSG_RESULT([enabled])
        AC_SUBST([TILEDB_SILENT_BUILD], "-DTILEDB_SILENT_BUILD")
    fi
fi


## Top-level system, possible values SunOS (Solaris), Darwin (macOS), Linux, ...
## Note that SunOS is not currently building; we would welcome help from anyone
## with access to such a system.
## Various Linux distribution have been tested and work, as do various macOS releases
uname=`uname`
#AC_MSG_RESULT([running on ${uname} (${on_macos})...])
## Also look at hardware platform aka 'machine' description
machine=`uname -m`

## -- Part 2: User preferences --------------------------------------------------
##
## Allow forced build override, value of 'yes' or 'no' set in enable_building variable
## (and sets by autoconf standards the 'enable_building' variable to 'yes' if selected
## otherwise the default is "" ie empty string and not 'no')
AC_ARG_ENABLE([building],
          AS_HELP_STRING([--enable-building],[build TileDB library instead of downloading prebuilt]))
          #[building="${enable_building}"
          # AC_MSG_RESULT([Enabled chosen])],
          #[building="${enable_building}"
          # AC_MSG_RESULT([Enabled NOT chosen])]
          #)

## Allow --with-tiledb if given (though system location is found too)
## (and sets by autconf standards the 'with_tiledb' variable)
AC_ARG_WITH([tiledb],
            AS_HELP_STRING([--with-tiledb=PATH],[absolute path to installed built of TileDB]),
            [TILEDB_INCLUDE="-I${with_tiledb}/include ${TILEDB_INCLUDE}"
             TILEDB_LIBS="-L${with_tiledb}/lib ${TILEDB_LIBS}"
             TILEDB_RPATH="-Wl,-rpath,${with_tiledb}/lib"],
            [])
#echo "enable_building: ${enable_building}"
#echo "with_tiledb: ${with_tiledb}"

## Sanity check
if test ! -z "${with_tiledb}" && test x"${enable_building}" = x"yes"; then
    AC_MSG_ERROR([Conflicting choice of preinstalled TileDB and enabling building TileDB.])
fi

## Allow --with-download if given (though system location is found too)
## (and sets by autconf standards the 'with_download' variable)
AC_ARG_WITH([download],
            AS_HELP_STRING([--with-download=URL],[URL override for TileDB library to download]),
            [TILEDB_LIB_URL="${with_download}"
	     enable_building="yes"],
            [])

## Sanity checks
if test ! -z "${with_tiledb}" && test x"${with_download}" = x"yes"; then
    AC_MSG_ERROR([Conflicting choice of preinstalled TileDB and enabling download of TileDB library.])
fi
## -- We allow this now as --with-download implies enable_building
##if test ! -z "${with_download}" -a x"${enable_building}" = x"yes"; then
##    AC_MSG_ERROR([Conflicting choice of enabling download of TileDB and enabling building of TileDB.])
##fi
AC_SUBST([TILEDB_LIB_URL], "${with_download}")

## Setup
origCPPFLAGS="${CPPFLAGS}"
origLDFLAGS="${LDFLAGS}"
CPPFLAGS="${origCPPFLAGS} ${TILEDB_INCLUDE}"
LDFLAGS="${origLDFLAGS} ${TILEDB_LIBS} ${TILEDB_RPATH}"

## Take care of 11 (aka 'Big Sur') requirement for macOS
if test x"${uname}" = x"Darwin"; then
    AC_MSG_CHECKING([for Darwin use minimum version override])
    CXX17_MACOS="-mmacosx-version-min=11"
    AC_MSG_RESULT([${CXX17_MACOS}])
    ## Obscure but important override: we may have gotten .dylib, but we prefer .so -- unless it is Conda
    if test x"${CONDA_BUILD}" != x"1"; then
       DYLIB_EXT=".so"
    fi
fi

## Take care of riscv64 machines and need for -latomic
if test x"${machine}" = x"riscv64"; then
    AC_MSG_CHECKING([for riscv64 linker adjustment])
    TILEDB_LIBS="${TILEDB_LIBS} -latomic"
    AC_MSG_RESULT([${TILEDB_LIBS}])
fi

## Take care of need for 'filesystem' (C++17, and g++ 8.*-ish or newer)
if test x"${uname}" = x"Linux"; then
   AC_CHECK_HEADER([filesystem], [have_filesystem="yes"], [have_filesystem="no"])
   if test x"${have_filesystem}" = x"no"; then
       AC_MSG_CHECKING([use of filesystem header])
       FILESYSTEM_HEADER_MISSSING="-DLACKING_FILESYSTEM"
       AC_MSG_RESULT([${FILESYSTEM_HEADER_MISSSING}])
   fi
fi


## -- Part 3: Check for TileDB --------------------------------------------------
##
## Check for TileDB -- either just probing the header, or by compilations (~ 1 second)
checkTileDBViaHeader="yes"

## Use either one of the tests
if test x"${checkTileDBViaHeader}" = x"yes"; then
    ## simply check for tiledb C-api header
    AC_CHECK_HEADER([tiledb/tiledb], [have_tiledb="yes"], [have_tiledb="no"])
else
    ## formally check we can build
    AC_MSG_CHECKING([compilation with TileDB])
    AC_COMPILE_IFELSE([AC_LANG_PROGRAM([#include <tiledb/tiledb>
                                        tiledb::Context ctx;])],
                                       [have_tiledb="yes"; AC_MSG_RESULT(yes); ],
                                       [have_tiledb="no"; AC_MSG_RESULT(no, need to install TileDB)])
fi

## -- Part 4: Branch on Setup and Choices ---------------------------------------
##
## to test one can force some selections here
#have_tiledb="no"
#enable_building="no"
#echo "have_tiledb=${have_tiledb}"
#echo "enable_building=${enable_building}"
if test x"${have_tiledb}" = x"no"; then

    ## case one: build is selected (or forced) so try building TileDB
    if test x"${enable_building}" = x"yes"; then
        AC_DEFUN([AC_PROG_CMAKE], [AC_CHECK_PROG(have_cmake,cmake,yes)])
        AC_PROG_CMAKE
        if test x"${have_cmake}" != x"yes"; then
            AC_MSG_ERROR([please install 'cmake'])
        fi
        AC_DEFUN([AC_PROG_CURL], [AC_CHECK_PROG(have_curl,curl,yes)])
        AC_PROG_CURL
        if test x"${have_curl}" != x"yes"; then
            AC_MSG_ERROR([please install 'curl'])
        fi
        AC_DEFUN([AC_PROG_GIT], [AC_CHECK_PROG(have_git,git,yes)])
        AC_PROG_GIT
        if test x"${have_git}" != x"yes"; then
            AC_MSG_ERROR([please install 'git'])
        fi
        AC_MSG_RESULT([installing TileDB via building locally...])
        if test x"${TILEDB_LIB_URL}" != x; then
            #AC_MSG_RESULT([using ${TILEDB_LIB_URL} ...])
            ## Important: unset LDFLAGS to not leak -ltiledb from pkg-config
            LDFLAGS="${origLDFLAGS}" tools/buildTileDB.sh ${TILEDB_LIB_URL}
        else
            #AC_MSG_RESULT([using default url ...])
            ## Important: unset LDFLAGS to not leak -ltiledb from pkg-config
            LDFLAGS="${origLDFLAGS}" tools/buildTileDB.sh default
        fi

    ## case two: download considered
    ##   - on macOS or Linux a 'fast and slim' build with external (pinned) library
    ##   - but if a download URL given, use it
    ##   - otherwise error
    ##   - but also check we're on x86_64 before downloading
    else

        if test x"${machine}" = x"x86_64" && (test x"${uname}" = x"Linux" || test x"${uname}" = x"Darwin"); then
            AC_MSG_RESULT([downloading x86_64 TileDB library...])

            osrel=`tools/getOsRelease.sh`
            AC_MSG_RESULT([installing TileDB for ${osrel}...])
            if test x"${uname}" = x"Darwin"; then
                os="macos"
            else
                os="linux"
            fi
            cd inst && ../tools/fetchTileDB.sh "${os}" "${machine}" && cd ..

        elif test x"${machine}" = x"arm64" && test x"${uname}" = x"Darwin"; then
            AC_MSG_RESULT([downloading arm64 TileDB library...])
            osrel=`tools/getOsRelease.sh`
            AC_MSG_RESULT([installing TileDB for ${osrel}...])
            os="macos"
            cd inst && ../tools/fetchTileDB.sh "${os}" "${machine}" && cd ..

        ## default case: be unhappy
        else
            AC_MSG_ERROR([currently unsupported system ${uname} on ${machine}])
        fi

    fi

    #AC_SUBST([TILEDB_INCLUDE], "-Itiledb-inst/include")
    AC_MSG_RESULT([using inst/tiledb/{lib,include}])
    RPATH=" -Wl,-rpath,'\$\$ORIGIN/../tiledb/lib'"
    AC_SUBST([TILEDB_INCLUDE], "-I../inst/tiledb/include ${CXX17_MACOS} ${FILESYSTEM_HEADER_MISSSING}")
    AC_SUBST([TILEDB_LIBS], "-ltiledb -L../inst/tiledb/lib")
    AC_SUBST([TILEDB_RPATH], "${RPATH}")

    CPPFLAGS="${origCPPFLAGS} ${TILEDB_INCLUDE}"
    LDFLAGS="${origLDFLAGS} ${TILEDB_LIBS} ${TILEDB_RPATH}"

fi


AC_SUBST([CXX17_MACOS])
AC_SUBST([FILESYSTEM_HEADER_MISSSING])
AC_SUBST([DYLIB_EXT])

AC_CONFIG_FILES([src/Makevars])
AC_OUTPUT
