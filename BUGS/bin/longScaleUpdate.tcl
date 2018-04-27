#!/bin/sh
# the next line restarts using wish \
exec wish "$0" ${1+"$@"}

proc longProc {} {
    global I
    set x 0.0
    for {set i $I} {$i > 0} {incr i -1} {
        set x [expr {$x + sin($i)}]
    }
    return $x
}

proc scaleUpdate {x} {
    puts stderr "$x [time longProc]"
}

scale .s -command scaleUpdate ;# workaround pour éviter double click: -repeatdelay 0
entry .e -textvariable I
pack .s .e

set I 100000

# régler I pour dépasser 280000 microseconds per iteration