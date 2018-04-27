set INCLUDES $TCLINCLUDEDIR


set SOURCES(libfidevtcldemos) {demos.c tableaux.c}
set    LIBS(libfidevtcldemos) [list\
     $TCLLIB libc libm libdl libnsl]

set SOURCES(dsh) mainTcl.c
set    LIBS(dsh) [concat ./libfidevtcldemos $LIBS(libfidevtcldemos)]

do -case lib -create lib libfidevtcldemos
do -case bin -create program dsh
do lib bin
