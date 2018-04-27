set INCLUDES [list ../../../c/sunInterval/src/ ../../fidevObj/src/ $TCLINCLUDEDIR]

set SOURCES(libtclsuninterval.0.1) {sunInterval.c}
set LIBS(libtclsuninterval.0.1) [concat\
        ../../fidevObj/src/libtclfidevobj.0.1\
        ../../../c/sunInterval/src/libdifuncs.0.1\
        libsunimath\
        $TCLLIB $GLOBLIBS(math) $GLOBLIBS(dynload) $GLOBLIBS(c)]

proc linkerCProgram         {prog objs libs} {
    variable LDFLAGS
    if {![info exists LDFLAGS]} {
	set LDFLAGS {}
    }
    return [concat CC -V $LDFLAGS -o $prog $objs $libs]
}
lappend CFLAGS -xia
lappend LDFLAGS -xia



set SOURCES(libtclsuninterval++.0.1) {sunInterval++.c++}
set LIBS(libtclsuninterval++.0.1) [concat\
        ../../fidevObj/src/libtclfidevobj.0.1\
        $TCLLIB $GLOBLIBS(math) $GLOBLIBS(dynload) $GLOBLIBS(c)]


set SOURCES(libtclscplxi.0.1) {scplxi.c scplxiD1.c}
set LIBS(libtclscplxi.0.1) [concat ../../../c/sunInterval/src/libscplxi.0.1 ./libtclsuninterval.0.1 $LIBS(libtclsuninterval.0.1)]

set SOURCES(sish) {mainTcl.c}
set LIBS(sish) [concat ./libtclscplxi.0.1 $LIBS(libtclscplxi.0.1)]

# do -case lib -create lib libtclsuninterval++.0.1
do -case lib -create lib libtclsuninterval.0.1
do -case lib -create lib libtclscplxi.0.1
do -case bin -create program sish
do lib bin
