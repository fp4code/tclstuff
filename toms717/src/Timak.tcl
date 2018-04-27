set INCLUDES [list ../../blasObj/src $TCLINCLUDEDIR]

set SOURCES(libtcltoms717) {toms717.c}
set    LIBS(libtcltoms717) [list\
     ../../blasObj/src/libtclblasObj\
     ../../../fortran/toms717/src/libtoms717\
     $TCLLIB libc libm]

set SOURCES(tsh) mainTcl.c
set    LIBS(tsh) [concat ./libtcltoms717 $LIBS(libtcltoms717)]

do -case lib -create lib libtcltoms717
do -case bin -create program tsh
do lib bin
