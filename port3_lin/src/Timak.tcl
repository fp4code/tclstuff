set INCLUDES [list ../../blasObj/src $TCLINCLUDEDIR]

set SOURCES(libtclport3lin_np) {port3lin_np.c}
set    LIBS(libtclport3lin_np) [list\
     ../../../fortran/port3_lin/non_public_src/libport3lin_np\
     ../../../fortran/port3_frame/src/libport3frame\
     ../../blasObj/src/libtclblasObj\
     $TCLLIB libc libm]

set SOURCES(psh) mainTcl.c
set    LIBS(psh) [concat ./libtclport3lin_np $LIBS(libtclport3lin_np)]

do -case lib -create lib libtclport3lin_np
do -case bin -create program psh
do lib bin

