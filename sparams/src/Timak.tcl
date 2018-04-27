set INCLUDES [list ../../fidevObj/src ../../blasObj/src $TCLINCLUDEDIR]

set SOURCES(libtclsparams) {sparams.c}
set    LIBS(libtclsparams) [concat\
        ../../dblas1/src/libtcl_dblas1\
        ../../zblas1/src/libtcl_zblas1\
        ../../../fortran/dblas1/src/libdblas1\
        ../../../fortran/zblas1/src/libzblas1\
        ../../slatec/src/libtcl_slatec\
        ../../blasMath/src/libtclblasmath\
        ../../blasObj/src/libtclblasObj\
        $TCLLIB libc libm]

set SOURCES(libtclsparams.0.2) {sparams.0.2.c}
set    LIBS(libtclsparams.0.2) [concat\
        ../../dblas1/src/libtcldblas1.0.2\
        ../../zblas1/src/libtclzblas1.0.2\
        ../../../fortran/dblas1/src/libdblas1\
        ../../../fortran/zblas1/src/libzblas1\
        ../../slatec/src/libtclslatec.0.2\
        ../../blasMath/src/libtclblasmath.0.2\
        ../../blasObj/src/libtclblasobj.0.2\
        ../../fidevObj/src/libtclfidevobj.0.2\
        $TCLLIB libc libm]

set SOURCES(spsh) mainTcl.c
set    LIBS(spsh) [concat ./libtclsparams.0.2 $LIBS(libtclsparams.0.2)]
set rien {        ../../dblas1/src/libtcl_dblas1\
        ../../zblas1/src/libtcl_zblas1\
        ../../../fortran/dblas1/src/libdblas1\
        ../../../fortran/zblas1/src/libzblas1\
        ../../slatec/src/libtcl_slatec\
        ../../../fortran/slatec/src/libslatec\
        ../../../fortran/slatec_fnlib/src/libslatec_fnlib\
        ../../../fortran/blas_mach/src/libblas_mach\
        ../../blasMath/src/libtclblasmath\
        ../../blasObj/src/libtclblasObj\
        $TCLLIB $GLOBLIBS(dynload) libc libm]}

set SOURCES(spwish) mainTk.c
set    LIBS(spwish) [concat  ./libtclsparams.0.2 $LIBS(libtclsparams.0.2)\
        ../../port3_nl2opt/src/libtclport3nl2opt.0.2\
        ../../hsplot/src/libhsp.0.5 $TKLIB]

set rien {        ../../dblas1/src/libtcl_dblas1\
        ../../zblas1/src/libtcl_zblas1\
        ../../../fortran/dblas1/src/libdblas1\
        ../../../fortran/zblas1/src/libzblas1\
        ../../slatec/src/libtcl_slatec\
        ../../../fortran/slatec/src/libslatec\
        ../../../fortran/slatec_fnlib/src/libslatec_fnlib\
        ../../../fortran/blas_mach/src/libblas_mach\
        ../../blasMath/src/libtclblasmath\
        ../../blasObj/src/libtclblasObj\
        ../../hsplot/src/libhsp\
        $TCLLIB $TKLIB $GLOBLIBS(dynload) libc libm]}


do -case lib -create lib libtclsparams.0.2
do -case bin -create program spsh
do -case bin -create program spwish
do lib bin
