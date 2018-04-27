set INCLUDES [concat ../../fidevObj/src ../../../c/sunmath/src ../../../c/supercomplex/src $TCLINCLUDEDIR]

set SOURCES(libfidev_tcl_supercomplex) {supercomplex.c}
set    LIBS(libfidev_tcl_supercomplex) [concat\
	../../../c/supercomplex/src/libfidev_supercomplex\
	../../../c/sunmath/src/libfidev_sunmath\
	$TCLLIB libc libm]

set SOURCES(libtclsupercomplex.0.2) {supercomplex.0.2.c}
set    LIBS(libtclsupercomplex.0.2) [concat\
        ../../fidevObj/src/libtclfidevobj.0.2\
	../../../c/supercomplex/src/libfidev_supercomplex\
	../../../c/sunmath/src/libfidev_sunmath\
	$TCLLIB libc libm]

set SOURCES(scsh) mainTcl.c
set    LIBS(scsh) [concat ./libtclsupercomplex.0.2 $LIBS(libtclsupercomplex.0.2)]
#        $GLOBLIBS(dynload)]

do -case lib -create lib libtclsupercomplex.0.2
do -case bin -create program scsh

do lib bin
