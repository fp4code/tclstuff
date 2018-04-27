set INCLUDES $TCLINCLUDEDIR

set rien {
  swig-1.1 -tcl8 -namespace tpg.0.1.swig
  timak
  tclsh
  load /home/fab/C/fidev-SparcSolarisForte7-optim/Tcl/essais_swig/src/libtpg.0.1.so Example
}


set SOURCES(libtpg.0.1) {tpg.0.1_wrap.c point.0.1.c util.0.1.c}
set LIBS(libtpg.0.1) [list $TCLLIB libc libm]


do -create lib libtpg.0.1

