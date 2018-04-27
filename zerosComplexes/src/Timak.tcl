set INCLUDES [list ../../fidevObj/src ../../supercomplex/src ../../../c/supercomplex/src ../../blas/src $TCLINCLUDEDIR ]

set SOURCES(libfidev_tcl_zeroscomplexes.0.3) [list plot.0.3.c eqvp.f]
set SOURCES(libtclzeroscomplexes.0.4) [list plot.0.4.c eqvp.f]
set SOURCES(libtclzeroscomplexes.0.5) [list plot.0.5.c eqvp.0.5.f]
set SOURCES(zcsh) mainTk.0.5.c

set LIBS(libfidev_tcl_zeroscomplexes.0.3) [concat\
     ../../horreur/src/libtcl_horreur\
     ../../supercomplex/src/libfidev_tcl_supercomplex\
     ../../blasObj/src/libtclblasObj\
     ../../../fortran/fidev_complex/src/libfidevfcomplex\
     ../../../fortran/trig_sun/src/libfidev_trig_sun\
     $TCLLIB  $GLOBLIBS(complexmath) $GLOBLIBS(math)]

set LIBS(libtclzeroscomplexes.0.4) [concat\
     ../../horreur/src/libtcl_horreur\
     ../../supercomplex/src/libtclsupercomplex.0.2\
     ../../blasObj/src/libtclblasobj.0.2\
     ../../fidevObj/src/libtclfidevobj.0.1\
     ../../../fortran/fidev_complex/src/libfidevfcomplex\
     ../../../fortran/trig_sun/src/libfidev_trig_sun\
     $TCLLIB  $GLOBLIBS(complexmath) $GLOBLIBS(math)]

set LIBS(libtclzeroscomplexes.0.5) [concat\
     ../../horreur/src/libtcl_horreur\
     ../../supercomplex/src/libtclsupercomplex.0.2\
     ../../blasObj/src/libtclblasobj.0.2\
     ../../fidevObj/src/libtclfidevobj.0.1\
     ../../../fortran/fidev_complex/src/libfidevfcomplex\
     ../../../fortran/trig_sun/src/libfidev_trig_sun\
     $TKLIB $TCLLIB $GLOBLIBS(X11) $GLOBLIBS(complexmath) $GLOBLIBS(math) $GLOBLIBS(c)]

set LIBS(zcsh) [concat\
     ./libtclzeroscomplexes.0.5\
     $LIBS(libtclzeroscomplexes.0.5) $TKLIB]

do -create lib libtclzeroscomplexes.0.5
do -create program zcsh
