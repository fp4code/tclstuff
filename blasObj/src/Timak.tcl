set INCLUDES [list $TCLINCLUDEDIR . ../../fidevObj/src]

set SOURCES(libtclblasObj) {utils.0.1.c blasObj.c tclBlas0Cmd.0.1.c blasVector.0.1.c blasSubVector.0.1.c blasMatrix.0.1.c}
set    LIBS(libtclblasObj) [concat $TCLLIB $GLOBLIBS(math) $GLOBLIBS(c)]

set SOURCES(libtclblasobj.0.2) {utils.0.1.c tclBlas0Cmd.0.2.c blasVector.0.2.c blasSubVector.0.2.c blasMatrix.0.2.c blasTensor.0.2.c}
set    LIBS(libtclblasobj.0.2) [concat ../../fidevObj/src/libtclfidevobj.0.2 $TCLLIB $GLOBLIBS(math) $GLOBLIBS(c)]

set SOURCES(vsh) mainTcl.c
set    LIBS(vsh) [concat ./libtclblasobj.0.2 $LIBS(libtclblasobj.0.2) $TCLLIB $GLOBLIBS(math) $GLOBLIBS(dynload) $GLOBLIBS(c)]


# do -case lib -create lib libtclblasObj
do -case lib -create lib libtclblasobj.0.2
do -case bin -create program vsh

do lib bin
