set INCLUDES [list ../../fidevObj/src ../../blasObj/src $TCLINCLUDEDIR]

set SOURCES(libtclport3root_np) {port3root_np.c}
set    LIBS(libtclport3root_np) [list\
     ../../../fortran/port3_root/non_public_src/libport3root_np\
     ../../../fortran/port3_frame/src/libport3frame\
     ../../blasObj/src/libtclblasObj\
     $TCLLIB libc libm]

set SOURCES(libtclport3root_np.0.2) {port3root_np.0.2.c}
set    LIBS(libtclport3root_np.0.2) [list\
     ../../fidevObj/src/libtclfidevobj.0.2\
     ../../blasObj/src/libtclblasobj.0.2\
     ../../../fortran/port3_root/non_public_src/libport3root_np\
     ../../../fortran/port3_frame/src/libport3frame\
     $TCLLIB libc libm]

set SOURCES(psh) mainTcl.c
set    LIBS(psh) [concat ./libtclport3root_np.0.2 $LIBS(libtclport3root_np.0.2)]

do -case lib -create lib libtclport3root_np.0.2
do -case bin -create program psh
do lib bin

