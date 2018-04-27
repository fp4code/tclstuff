set INCLUDES [list . ../../fidevObj/src ../../blasObj/src ../../supercomplex/src ../../../c/supercomplex/src $TCLINCLUDEDIR]

set SOURCES(libtclblasmath) {math.0.4.c dsvop.0.4.c zsvop.0.4.c i16svop.0.4.c i32svop.0.4.c dscalop.0.3.c op.0.4.c}
set    LIBS(libtclblasmath) [concat\
        ../../blasObj/src/libtclblasObj\
        ../../supercomplex/src/libfidev_tcl_supercomplex\
        ../../../c/supercomplex/src/libfidev_supercomplex\
        $TCLLIB libc libm]

set SOURCES(libtclblasmath.0.2) {math.0.5.c dsvop.0.5.c zsvop.0.5.c i16svop.0.5.c i32svop.0.5.c dscalop.0.4.c op.0.5.c}
# choisir
#        ../../fidevObj/src/libtclfidevobj.0.1
set    LIBS(libtclblasmath.0.2) [concat\
        ../../fidevObj/src/libtclfidevobj.0.2\
        ../../blasObj/src/libtclblasobj.0.2\
        ../../supercomplex/src/libtclsupercomplex.0.2\
        ../../../c/supercomplex/src/libfidev_supercomplex\
        $TCLLIB libc libm]

set SOURCES(mathsh) mainTcl.c
set    LIBS(mathsh) [concat ./libtclblasmath.0.2 $LIBS(libtclblasmath.0.2)]

do -case lib -create lib libtclblasmath.0.2
do -case bin -create program mathsh

do lib bin
