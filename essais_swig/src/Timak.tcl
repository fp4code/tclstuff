set INCLUDES $TCLINCLUDEDIR

set rien {
  swig-1.1 -tcl8 -namespace example.i
  timak
  tclsh
  load /home/fab/C/fidev-SparcSolarisForte7-optim/Tcl/essais_swig/src/libswigexample.so Example
  example::pow 2 3


  swig-1.1 -tcl8 -namespace mc.i
  timak
  tclsh
  load /home/fab/C/fidev-SparcSolarisForte7-optim/Tcl/essais_swig/src/libswigexample.so Example
  example::pow 2 3

  swig-1.3 -c++ -tcl8 -namespace list.swig
  timak
  tclsh
  load /home/fab/C/fidev-SparcSolarisForte7-optim/Tcl/essais_swig/src/libswiglist.so Example

<<<<<<< variant A
  swig-1.3 -c++ -tcl8 -namespace listsimple.swig
  timak
  tclsh
  load /home/fab/C/fidev-SparcSolarisForte7-optim/Tcl/essais_swig/src/libswiglistsimple.so Example



>>>>>>> variant B
======= end
  swig-1.3 -c++ -tcl8 -namespace vector.swig
  timak
  tclsh
  load /home/fab/C/fidev-SparcSolarisForte7-optim/Tcl/essais_swig/src/libswigvector.so Example


}

set SOURCES(libswiglist) {list_wrap.cxx}
set LIBS(libswiglist) [list $TCLLIB libc libm]

set SOURCES(libswiglistsimple) {listsimple_wrap.cxx}
set LIBS(libswiglistsimple) [list $TCLLIB libc]

set SOURCES(libswigvector) {vector_wrap.cxx vector.cc}
set LIBS(libswigvector) [list $TCLLIB libc libm]

set SOURCES(libswigexample) {example_wrap.c}
set LIBS(libswigexample) [list $TCLLIB libc libm]

set SOURCES(libswigmc) {mc_wrap.c mc.c}
set LIBS(libswigmc) [list $TCLLIB libc]


#do -create lib libswigexample
#do -create lib libswigmc
#do -create lib libswigvector
do -create lib libswiglistsimple

