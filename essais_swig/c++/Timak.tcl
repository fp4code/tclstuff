set INCLUDES $TCLINCLUDEDIR

set rien {
  swig-1.3 -c++ -tcl8 -namespace rectangle.swig
  timak
  tclsh
  load /home/fab/C/fidev-SparcSolarisForte7-optim/Tcl/essais_swig/src/libswigrectangle.so Rectangle

}

set SOURCES(libswigrectangle) {rectangle_wrap.cxx rectangle.cc}
set LIBS(libswigrectangle) [list $TCLLIB GLOBLIBS(c)]


do -create lib libswigrectangle

