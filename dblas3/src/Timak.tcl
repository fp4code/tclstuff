set INCLUDES [list ../../blasObj/src $TCLINCLUDEDIR]

set SOURCES(libtcl_dblas1) {dblas3.c}
set    LIBS(libtcl_dblas1) [list\
     ../../blasObj/src/libtclblasObj\
     ../../../fortran/dblas3/src/libdblas3\
     $TCLLIB libc libm]

set SOURCES(vsh) mainTcl.c
set    LIBS(vsh) [list\
    ./libtcl_dblas3\
    ../../blasObj/src/libtclblasObj\
    ../../../fortran/dblas1/src/libdblas3\
    $TCLLIB]

do -case lib -create lib libtcl_dblas3
do -case bin -create program vsh
do lib bin
