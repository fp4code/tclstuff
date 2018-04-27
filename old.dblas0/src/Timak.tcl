set INCLUDES [list $TCLINCLUDEDIR]

set SOURCES(libtcl_dblas0) {blas.c blasSubVector.c blasVector.c blasMatrix.c blasBandedMatrix.c  blasPackedMatrix.c interpol.c mainTcl.c}
set    LIBS(libtcl_dblas0) [list $TCLLIB libc libm]

set SOURCES(vsh) mainTcl.c
set    LIBS(vsh) [list ./libtcl_dblas0 $TCLLIB]

do -case lib -create lib libtcl_dblas0
do -case bin -create program vsh
do lib bin
