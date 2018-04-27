set INCLUDES [list ${TCLINCLUDEDIR} . ../../blas/src ../../trig_sun/src]

set SOURCES(libtclcomplexes) {complexes.c gdsqrt.f}
set LIBS(libtclcomplexes) [concat\
        ../../../c/sunmath/src/libfidev_sunmath\
        ../../../fortran/trig_sun/src/libfidev_trig_sun\
        $TCLLIB\
        $GLOBLIBS(complexmath) $GLOBLIBS(math)]
set SOURCES(cosh) {mainTcl.c}
set LIBS(cosh) [concat\
        ./libtclcomplexes\
        ../../../c/sunmath/src/libfidev_sunmath\
        ../../../fortran/trig_sun/src/libfidev_trig_sun\
        $TCLLIB\
        $GLOBLIBS(complexmath) $GLOBLIBS(math)]
parray GLOBLIBS

do -case lib -create lib libtclcomplexes
do -case bin -create program cosh
do lib bin

