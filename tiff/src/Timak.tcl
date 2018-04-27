set INCLUDES [list $TCLINCLUDEDIR /prog/tiff/include]

set SOURCES(libtcltiff) {tiff.c}
set    LIBS(libtcltiff) [list $TCLLIB /prog/tiff/lib/libtiff libc]

set SOURCES(tiffsh) mainTcl.c
set    LIBS(tiffsh) [list ./libtcltiff $TCLLIB  /prog/tiff/lib/libtiff libc]

do -case lib -create lib libtcltiff
do -case bin -create program tiffsh
do lib bin
