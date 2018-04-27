set INCLUDES [list ../../fidevObj/src ../../blasObj/src $TCLINCLUDEDIR]
#	../../sunmath/src/libfidev_sunmath\

set SOURCES(libtcl_slatec) {slatec.c}
set    LIBS(libtcl_slatec) [list\
        ../../../fortran/slatec/src/libslatec\
        ../../../fortran/slatec_fnlib/src/libslatec_fnlib\
        ../../../fortran/blas_mach/src/libblas_mach\
        ../../blasMath/src/libtclblasmath\
        ../../blasObj/src/libtclblasObj\
        $TCLLIB libc]

set SOURCES(libtclslatec.0.2) {slatec.0.2.c}
set    LIBS(libtclslatec.0.2) [list\
        ../../fidevObj/src/libtclfidevobj.0.1\
        ../../blasObj/src/libtclblasobj.0.2\
        ../../blasMath/src/libtclblasmath.0.2\
        ../../../fortran/slatec/src/libslatec\
        ../../../fortran/slatec_fnlib/src/libslatec_fnlib\
        ../../../fortran/blas_mach/src/libblas_mach\
        ../../../c/supercomplex/src/libfidev_supercomplex\
        ../../../c/sunmath/src/libfidev_sunmath\
        $TCLLIB libc]

set SOURCES(slsh) mainTcl.c
set    LIBS(slsh) [concat ./libtclslatec.0.2 $LIBS(libtclslatec.0.2)]

do -case lib -create lib libtclslatec.0.2
do -case bin -create program slsh

do lib bin
