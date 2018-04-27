set INCLUDES $TCLINCLUDEDIR

set SOURCES(libfidevtcl) {tclObj.c}
set    LIBS(libfidevtcl) $TCLLIB

do -create lib libfidevtcl
