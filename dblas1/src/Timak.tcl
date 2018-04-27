set INCLUDES [list ../../fidevObj/src ../../blasObj/src $TCLINCLUDEDIR]

set SOURCES(libtcl_dblas1.0.1) {dblas1.0.1.c}
set    LIBS(libtcl_dblas1.0.1) [list\
     ../../blasObj/src/libtclblasObj.0.1\
     ../../../fortran/dblas1/src/libdblas1\
     $TCLLIB libc libm]

set SOURCES(libtcldblas1.0.2) {dblas1.0.2.c}
set    LIBS(libtcldblas1.0.2) [list\
     ../../blasObj/src/libtclblasobj.0.2\
     ../../fidevObj/src/libtclfidevobj.0.1\
     ../../../fortran/dblas1/src/libdblas1\
     $TCLLIB libc libm]

set SOURCES(vsh) mainTcl.c
set    LIBS(vsh) [concat ./libtcldblas1.0.2 $LIBS(libtcldblas1.0.2)]

do -case lib -create lib libtcldblas1.0.2
do -case bin -create program vsh
do lib bin
