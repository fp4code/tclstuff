set INCLUDES $TCLINCLUDEDIR

set rien {

  swig-1.3 -c -tcl8 example.i
  timak
  tclsh
  load /home/fab/C/fidev-SparcSolarisForte7-optim/Tcl/essais_swig/src/libswiglist.so Example

}

set SOURCES(libswig) {example_wrap.c example.c}
set LIBS(libswig) [list $TCLLIB libc ]

do -create lib libswig
