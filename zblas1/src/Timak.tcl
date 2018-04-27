set INCLUDES [list ../../fidevObj/src ../../blasObj/src $TCLINCLUDEDIR]

set SOURCES(libtcl_zblas1) {zblas1.c}
set    LIBS(libtcl_zblas1) [list\
     ../../blasObj/src/libtclblasObj\
     ../../../fortran/zblas1/src/libzblas1\
     $TCLLIB libc libm]

set SOURCES(libtclzblas1.0.2) {zblas1.0.2.c}
set    LIBS(libtclzblas1.0.2) [list\
     ../../fidevObj/src/libtclfidevobj.0.1\
ou
     ../../fidevObj/src/libtclfidevobj.0.2\
     ../../blasObj/src/libtclblasobj.0.2\
     ../../../fortran/zblas1/src/libzblas1\
     $TCLLIB libc libm]

set SOURCES(vsh) mainTcl.c
set    LIBS(vsh) [concat ./libtclzblas1.0.2 $LIBS(libtclzblas1.0.2)]

do -case lib -create lib libtclzblas1.0.2
do -case bin -create program vsh
do lib bin
