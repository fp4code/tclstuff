set INCLUDES [list ../../../c/dcdflib/src/ $TCLINCLUDEDIR]

set SOURCES(libtcldcdf.0.1) {dcdflib.c}
set LIBS(libtcldcdf.0.1) [concat\
        ../../../c/dcdflib/src/libdcdf\
	$TCLLIB $GLOBLIBS(math) $GLOBLIBS(dynload) $GLOBLIBS(c)]

#        $TCLLIB $GLOBLIBS(math) $GLOBLIBS(dynload) $GLOBLIBS(c)]


do -create lib libtcldcdf.0.1
