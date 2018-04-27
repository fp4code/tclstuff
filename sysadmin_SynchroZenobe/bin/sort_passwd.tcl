#!/bin/sh
# \
exec tclsh "$0" ${1+"$@@"}

set f [open ~/Z/passwd r]
set lines [split [read -nonewline $f] \n]
close $f
foreach l $lines {
    set ll [split $l :]
    set ll [lreplace $ll 1 1 *]
    set uid [lindex $ll 2]
    if {[info exists L($uid)]} {
        puts stderr "doublon uid $uid : [lindex $ll 0] et $L($uid)"
    }
    set L($uid) [join $ll :]
}
foreach l [lsort -integer [array names L]] {
    puts $L($l)
}
