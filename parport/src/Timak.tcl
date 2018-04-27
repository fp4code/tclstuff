set INCLUDES [concat $TCLINCLUDEDIR]

set SOURCES(libfidevtclparport.0.1) {parport.c}
set    LIBS(libfidevtclparport.0.1) [concat\
	$TCLLIB libc]

set SOURCES(psh) mainTcl.c
set    LIBS(psh) [concat ./libfidevtclparport.0.1 $LIBS(libfidevtclparport.0.1)]

do -case lib -create lib libfidevtclparport.0.1
do -case bin -create program psh

do lib bin
