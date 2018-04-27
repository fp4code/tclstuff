set INCLUDES [list ../../fidevObj/src ../../blasObj/src $TCLINCLUDEDIR]

set SOURCES(libtcl_dblas2) {dblas2.c}
set    LIBS(libtcl_dblas2) [list\
     ../../blasObj/src/libtclblasObj\
     ../../../fortran/dblas2/src/libdblas2\
     $TCLLIB libc libm]

set SOURCES(libtcl_dblas2.0.2) {dblas2.0.2.c}
set    LIBS(libtcl_dblas2.0.2) [list\
     ../../blasObj/src/libtclblasobj.0.2\
     ../../fidevObj/src/libtclfidevobj.0.1\
     ../../../fortran/dblas2/src/libdblas2\
     $TCLLIB libc libm]


set SOURCES(msh) mainTcl.c
set    LIBS(msh) [concat ./libtcl_dblas2.0.2 $LIBS(libtcl_dblas2.0.2)]

do -case lib -create lib libtcl_dblas2.0.2
do -case bin -create program msh
do lib bin
