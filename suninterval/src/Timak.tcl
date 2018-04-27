set INCLUDES $TCLINCLUDEDIR
set CFLAGS -xia
set LDFLAGS -xia

set rien {
  swig-1.3 -c++ -tcl8 -namespace suninterval.swig
  timak
  tclsh
  load /home/fab/C/fidev-SparcSolarisForte7-optim/Tcl/suninterval/src/libswigsuninterval.so Suninterval
}

set SOURCES(libswigsuninterval) {suninterval_wrap.cxx}
set LIBS(libswigsuninterval) [concat $TCLLIB libCrun libc]

set SOURCES(tsi) {suninterval_wrap.cxx mainTcl.c}
set LIBS(tsi) [concat $TCLLIB libCrun libc libm]


# libcx

# do -create lib libswigsuninterval
do -create program tsi
