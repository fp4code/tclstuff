#!/bin/sh
# \
exec tclsh "$0" ${1+"$@"}


package require fidev
package require parport

parport::open

proc sonnette {periode} {
    parport::testio
    set errAndPins [parport::geterr]
    if {[lindex $errAndPins 2] == 1} {
        puts vu
        exec /home/fab/A/fidev/Tcl/parport/bin/train.tcl > /dev/null &
        exec rsh -n fab /home/fab/A/fidev/Tcl/parport/bin/train.tcl > /dev/null &
        exec rsh -n scollin /home/fab/A/fidev/Tcl/parport/bin/train.tcl > /dev/null &
        exec rsh -n lijadi /home/fab/A/fidev/Tcl/parport/bin/train.tcl > /dev/null &
        exec rsh -n nathalie /home/fab/A/fidev/Tcl/parport/bin/train.tcl > /dev/null &
        exec rsh -n dupuis /home/fab/A/fidev/Tcl/parport/bin/train.tcl > /dev/null &
        exec rsh -n fab /home/fab/A/fidev/Tcl/parport/bin/train.tcl > /dev/null &
        exec rsh -n jluc /home/fab/A/fidev/Tcl/parport/bin/train.tcl > /dev/null &
    }
    after $periode "sonnette $periode"
}

set fini 0
sonnette 100

vwait fini
