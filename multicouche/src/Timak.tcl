set INCLUDES [list $TCLINCLUDEDIR ../../blas/src ../../complexes/src ../../trig_sun/src]

set SOURCES(libtcl_multicouche) [list mtc.f multicouche.c]
set LIBS(libtcl_multicouche) [list $TCLLIB ../../blas/src/libtcl_blas ../../complexes/src/libtclcomplexes ../../horreur/src/libtcl_horreur libM77 libF77]

do -create lib libtcl_multicouche


