if {![info exists TCLINCLUDEDIR]} {
    set TCLINCLUDEDIR /usr/include/tcl8.6
}

if {![info exists TCLLIB]} {
    global env
    switch $EXEC(libType) {
        "static" {
            global env
            return -code error "\"static à écrire\""
#            set env(LD_LIBRARY_PATH) /home/fab/C/fidev-sparc-SunOS-5.7-cc-gprof/lib
        }
        "debug" {
            set TCLLIB $env(P10PROG)/Tcl/$env(P10ARCH)_debug/lib/libtcl8.3g
            set TKLIB  $env(P10PROG)/Tcl/$env(P10ARCH)_debug/lib/libtk8.3g
        }
        "optim8.4" {
            set TCLLIB $env(P10PROG)/Tcl/$env(P10ARCH)/lib/libtcl8.4
            set TKLIB  $env(P10PROG)/Tcl/$env(P10ARCH)/lib/libtk8.4
        }
        "debug8.4" {
            set TCLLIB $env(P10PROG)/Tcl/$env(P10ARCH)_debug/lib/libtcl8.4g
            set TKLIB  $env(P10PROG)/Tcl/$env(P10ARCH)_debug/lib/libtk8.4g
        }
        default {
            set TCLLIB $env(P10PROG)/Tcl/$env(P10ARCH)/lib/libtcl8.4
            set TKLIB  $env(P10PROG)/Tcl/$env(P10ARCH)/lib/libtk8.4
        }
    }
}

# on peut aussi utiliser un "foreach d ... {do subdir $d}

do -in blas
do -in dblas0
do -in dblas1
do -in blasMath
# do -in dblas2
do -in asdex
do -in complexes
do -in minpack
do -in slatec
# do -in fctlm
do -in fichUtils
do -in horreur
# do -in multicouche
#do -in ni488
do -in trig_sun
do -in unix
#do -in zerosComplexes
do -in sparams
# do -in pvm
# do -in scilab
do -in slatec_fnlib

# do -in toms717
do -in port3_fft
do -in port3_nl2opt

# do -in essaiGcc
# do -in essais
# do -in essais_f77
# do -in lapack
