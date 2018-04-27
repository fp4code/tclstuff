set INCLUDES $TCLINCLUDEDIR

set SOURCES(libessai) {essaiCarre.c}
set    LIBS(libessai) [concat $TCLLIB libc libm]

set SOURCES(esh) mainTcl.c
set    LIBS(esh) [concat ./libessai $LIBS(libessai)]

do -case lib -create lib libessai
do -case bin -create program esh
do lib bin
