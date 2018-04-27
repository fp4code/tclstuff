set INCLUDES [list ../../../c/sunInterval/src/ ../../sunInterval/src/ ../../fidevObj/src/ ../../../c/oplan/src/ $TCLINCLUDEDIR]

set SOURCES(libtcloplan.0.1) {oplan.c}
set LIBS(libtcloplan.0.1) [concat\
        ../../fidevObj/src/libtclfidevobj.0.1\
        ../../sunInterval/src/libtclscplxi.0.1\
        ../../sunInterval/src/libtclsuninterval.0.1\
        ../../../c/sunInterval/src/libscplxi.0.1\
        ../../../c/sunInterval/src/libdifuncs.0.1\
        ../../../c/oplan/src/liboplan.0.1\
        libsunimath $TCLLIB $GLOBLIBS(math) $GLOBLIBS(dynload) $GLOBLIBS(c)]

set SOURCES(opsh) {mainTcl.c}
set LIBS(opsh) [concat ./libtcloplan.0.1 $LIBS(libtcloplan.0.1)]

do -case lib -create lib libtcloplan.0.1
do -case bin -create program opsh
do lib bin
