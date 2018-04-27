#!/bin/sh

# the next line restarts using wish \
LD_LIBRARY_PATH=$LD_LIBRARY_PATH":"/opt/NICgpib/lib ; export LD_LIBRARY_PATH ; exec wish "$0" "$@"

if {[info tclversion] < 8.4} {
    error "Version ([info tclversion]) should be >= 8.4 (64 bits integers)"
}

#
# package require hyperhelp 1.2.999
# set jstools_library /prog/Tcl/lib/jstools-4.5
# lappend auto_path $jstools_library

# puts stderr $env(LD_LIBRARY_PATH)

set tcl_traceExec 0
set tcl_traceCompile 0

package require fidev


set AsdexTclDir $FIDEV_TCL_ROOT
cd $AsdexTclDir

package require gpibLowLevel
package require gpib

proc iniGlobals {} {
    global variable_SRQ
    set variable_SRQ {}

    global GPIB_board GPIB_boardAddress
    GPIB::newGPIB 2400 k2400 $GPIB_board 27
}

puts "### GPIB::main"
GPIB::main
iniGlobals
