set INCLUDES $TCLINCLUDEDIR

set rien {
  swig-1.3 -c++ -tcl8 -namespace example.i
  timak
  tclsh
  load /home/fab/C/fidev-SparcSolarisForte7-optim/Tcl/essais_swig/template/libswigtemplate.so Example
}

set SOURCES(libswigtemplate) {example_wrap.cxx}
set LIBS(libswigtemplate) [list $TCLLIB libCrun $GLOBLIBS(c)]

do -create lib libswigtemplate
