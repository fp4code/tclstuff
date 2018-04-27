set INCLUDES [list ../../fidevObj/src ../../blasObj/src $TCLINCLUDEDIR]

set SOURCES(libtclport3nl2opt) {port3nl2opt.c}
set    LIBS(libtclport3nl2opt) [list\
     ../../../fortran/port3_nl2opt/src/libport3nl2opt\
     ../../../fortran/port3_nl3opt/src/libport3nl3opt\
     ../../../fortran/port3_nl4opt/src/libport3nl4opt\
     ../../../fortran/port3_frame/src/libport3frame\
     ../../blasObj/src/libtclblasObj\
     $TCLLIB libc libm]

set SOURCES(libtclport3nl2opt.0.2) {port3nl2opt.0.2.c}
set    LIBS(libtclport3nl2opt.0.2) [list\
     ../../fidevObj/src/libtclfidevobj.0.2\
     ../../blasObj/src/libtclblasobj.0.2\
     ../../blasMath/src/libtclblasmath.0.2\
     ../../dblas1/src/libtcldblas1.0.2\
     ../../../fortran/port3_nl2opt/src/libport3nl2opt\
     ../../../fortran/port3_nl3opt/src/libport3nl3opt\
     ../../../fortran/port3_nl4opt/src/libport3nl4opt\
     ../../../fortran/port3_frame/src/libport3frame\
     $TCLLIB libc libm]


set SOURCES(psh) mainTcl.c
set    LIBS(psh) [concat ./libtclport3nl2opt.0.2 $LIBS(libtclport3nl2opt.0.2)]

do -case lib -create lib libtclport3nl2opt.0.2
do -case bin -create program psh
do lib bin

