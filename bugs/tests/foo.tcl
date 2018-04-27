#!/bin/sh

#\
exec /home/fab/C/fidev-unknown-Linux-2.2.16-3-cc-static-debug/Tcl/bugs/src/foosh "$0" ${1+"$@"}

proc bff {w} {
    set i 3
    incr i
    return [nextfoo $w]
}

bff 1 ;# OK
bff 3 ;# bug

