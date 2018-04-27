# RCS: @(#) $Id: Timak.tcl,v 1.5 2002/06/07 13:22:28 fab Exp $

set INCLUDES [list $TCLINCLUDEDIR ../../horreur/src]

set SOURCES(libtcl_blas) {tclBlas1Cmd.c tclBlas0Cmd.c tclBlasUtil.c tclBlasInit.c}
set    LIBS(libtcl_blas) [concat \
     ../../../fortran/dblas1/src/libdblas1\
     ../../../fortran/zblas1/src/libzblas1\
     ../../../fortran/sblas1/src/libsblas1\
     ../../../fortran/cblas1/src/libcblas1\
     $TCLLIB $GLOBLIBS(c)]

set SOURCES(blassh) mainTcl.c
set    LIBS(blassh) [concat \
     ../../../fortran/dblas1/src/libdblas1\
     ../../../fortran/zblas1/src/libzblas1\
     ../../../fortran/sblas1/src/libsblas1\
     ../../../fortran/cblas1/src/libcblas1\
      ./libtcl_blas $TCLLIB]

do -case lib -create lib libtcl_blas
do -case bin -create program blassh
do -case default -do lib               ;# idem "do -do lib"
do -case default -do bin
do -case doc -in doc -do default ;# ou   do -case doc -in doc
do -case doc2 -in doc -do doc2   ;# ou   do -case doc2 -in doc -do {}
#
