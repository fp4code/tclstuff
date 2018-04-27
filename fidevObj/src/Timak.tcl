set INCLUDES [list $TCLINCLUDEDIR]

set SOURCES(libtclfidevobj.0.2) {fidevObj.0.2.c}
set    LIBS(libtclfidevobj.0.2) [concat $TCLLIB libc]

do  -create lib libtclfidevobj.0.2

