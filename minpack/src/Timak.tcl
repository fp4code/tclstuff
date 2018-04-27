set INCLUDES [list ../../fidevObj/src ../../blasObj/src ${TCLINCLUDEDIR}]

set SOURCES(libtclminpack.0.2) "minpack.0.2.c dummy.f"
set LIBS(libtclminpack.0.2) [list ../../../fortran/minpack/src/libminpack  ../../blasObj/src/libtclblasObj $TCLLIB libc libm]

set SOURCES(libtclminpack.0.3) "minpack.0.3.c dummy.f"
set LIBS(libtclminpack.0.3) [list \
        ../../fidevObj/src/libtclfidevobj.0.1 \
        ../../blasObj/src/libtclblasobj.0.2 \
        ../../../fortran/minpack/src/libminpack \
        $TCLLIB \
        libc libm]

set SOURCES(minpsh) mainTcl.c
set    LIBS(minpsh) [concat ./libtclminpack.0.3 $LIBS(libtclminpack.0.3)]

do -case lib -create lib libtclminpack.0.3
do -case bin -create program minpsh
do lib bin
