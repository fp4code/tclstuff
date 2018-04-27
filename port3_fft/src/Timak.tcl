set INCLUDES [list ../../fidevObj/src ../../blasObj/src $TCLINCLUDEDIR]

set SOURCES(libtclport3fft.0.1) {port3fft.0.1.c}
set    LIBS(libtclport3fft.0.1) [list\
     ../../blasObj/src/libtclblasObj\
     ../../../fortran/port3_fft/src/libport3fft\
     ../../../fortran/port3_frame/src/libport3frame\
     $TCLLIB libc libm]

set SOURCES(libtclport3fft.0.2) {port3fft.0.2.c}
set    LIBS(libtclport3fft.0.2) [list \
     ../../fidevObj/src/libtclfidevobj.0.2 \
     ../../blasObj/src/libtclblasobj.0.2 \
     ../../../fortran/port3_fft/src/libport3fft \
     ../../../fortran/port3_frame/src/libport3frame \
     $TCLLIB libc libm]

set SOURCES(psh) mainTcl.c
set    LIBS(psh) [concat ./libtclport3fft.0.2 $LIBS(libtclport3fft.0.2)]

do -case lib -create lib libtclport3fft.0.2
do -case bin -create program psh
do lib bin

