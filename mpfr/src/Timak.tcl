set INCLUDES [concat ../../../c/mpfr/src $env(P10PROG)/gmp/include $TCLINCLUDEDIR]
#set INCLUDES [concat $env(P10PROG)/gmp/include $TCLINCLUDEDIR]

set rien {
  swig-1.3 -c -I../../../c/mpfr/src -tcl8 -namespace mpfr.swig
  timak
}

set SOURCES(libswigmpfr) {mpfr_wrap.c mainTcl.c}
set LIBS(libswigmpfr) [concat ../../../c/mpfr/src/libmpfr $env(P10PROG)/gmp/$env(P10ARCH)/lib/libgmp $TCLLIB]

set SOURCES(tmpfr) {mpfr_wrap.c mainTcl.c}
set LIBS(tmpfr) [concat ./libswigmpfr $LIBS(libswigmpfr)]

do -create program tmpfr

