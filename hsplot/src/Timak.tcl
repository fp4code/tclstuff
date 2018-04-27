# RCS: @(#) $Id: Timak.tcl,v 1.3 2002/06/25 13:06:17 fab Exp $

# set INCLUDES [list $TCLINCLUDEDIR C:/prog/msys/prog/Tcl/tcl/generic C:/prog/msys/prog/Tcl/tk/generic C:/prog/msys/prog/Tcl/tk/win ../../fidevObj/src ../../blasObj/src /usr/openwin/include]
set INCLUDES [list $TCLINCLUDEDIR ../../fidevObj/src ../../blasObj/src /usr/openwin/include $TK_SRC_DIR/generic $TCL_SRC_DIR/generic]

set SOURCES(libhsp) {hsplot.0.4.c}
set    LIBS(libhsp) [concat \
        ../../blasObj/src/libtclblasObj \
        $TCLLIB $TKLIB $GLOBLIBS(X11) libc libm]

set SOURCES(libhsp.0.5) {hsplot.0.5.c}
set    LIBS(libhsp.0.5) [concat \
        ../../fidevObj/src/libtclfidevobj.0.2 \
        ../../blasObj/src/libtclblasobj.0.2 \
        $TCLLIB $TKLIB $GLOBLIBS(X11) libc libm]

set SOURCES(hspsh) mainTk.c
set    LIBS(hspsh) [concat ./libhsp.0.5 $LIBS(libhsp.0.5)]

do -case lib -create lib libhsp.0.5
do -case bin -create program hspsh
do lib bin
