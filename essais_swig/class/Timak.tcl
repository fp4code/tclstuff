set INCLUDES $TCLINCLUDEDIR

set rien {
  swig-1.3 -c++ -tcl8 -namespace example.i
  timak
  tclsh
  load /home/fab/C/fidev-SparcSolarisForte7-optim/Tcl/essais_swig/class/libswigclass.so Example
}

set SOURCES(libswigclass) {example_wrap.cxx example.cxx}
set LIBS(libswigclass) [list $TCLLIB libCrun $GLOBLIBS(c)]

do -create lib libswigclass
