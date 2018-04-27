set INCLUDES [list /prog/Tcl/snack2.1.4/generic $TCLINCLUDEDIR]

set SOURCES(libfidev_snack) {damposc.c synthesis.c snack.c}
set    LIBS(libfidev_snack) [list /prog/Tcl/lib/snack2.0/libsnack $TCLLIB libc libm]

set SOURCES(libsnack_ext_square) {square.c}
set    LIBS(libsnack_ext_square) [list /prog/Tcl/lib/snack2.1/libsnack $TCLLIB libc libm]

set SOURCES(dsh) mainTk.c
set    LIBS(dsh) [list ./libfidev_snack /prog/Tcl/lib/snack2.0/libsnack $TCLLIB $TKLIB]

# do -case lib -create lib libdamposc
do -case lib -create lib libsnack_ext_square
do -case bin -create program dsh
do lib bin
