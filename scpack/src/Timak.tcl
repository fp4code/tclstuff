set INCLUDES [list ../../fidevObj/src ../../blasObj/src $TCLINCLUDEDIR]

set SOURCES(libtcl_scpack) {scpack.c}
set    LIBS(libtcl_scpack) [list\
     ../../blasObj/src/libtclblasObj\
     ../../../fortran/conformal_scpack_double/src/libconformal_scpack_double\
     $TCLLIB libc libm]

set SOURCES(libtclscpack.0.2) {scpack.0.2.c}
set    LIBS(libtclscpack.0.2) [list\
     ../../fidevObj/src/libtclfidevobj.0.1\
     ../../blasObj/src/libtclblasobj.0.2\
     ../../../fortran/conformal_scpack_double/src/libconformal_scpack_double\
     $TCLLIB libc libm]

set SOURCES(scsh) mainTcl.c
set    LIBS(scsh) [concat ./libtclscpack.0.2 $LIBS(libtclscpack.0.2)]

do -case lib -create lib libtclscpack.0.2
do -case bin -create program scsh
do lib bin
