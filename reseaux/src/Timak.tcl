set INCLUDES $TCLINCLUDEDIR

set SOURCES(ressh) mainTcl.c
set    LIBS(ressh) [concat\
        ../../blasMath/src/libtclblasmath\
        ../../blasObj/src/libtclblasObj\
        ../../supercomplex/src/libfidev_tcl_supercomplex\
        ../../../c/supercomplex/src/libfidev_supercomplex\
        $TCLLIB libc libm]

do -case bin -create program ressh

do bin
