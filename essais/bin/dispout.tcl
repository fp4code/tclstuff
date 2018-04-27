#!/bin/sh
# \
exec wish "$0" ${1+"$@"}

set f [open |./regout.tcl r]
fconfigure $f -buffering line

proc readALine {f &lines t} {
    upvar &lines lines
    if [eof $f] {
        fileevent $f readable {}
        $t insert end END
        return
    }
    set l [gets $f]
    if {$l == {}} {
        $t delete 1.0 end
        $t insert end $lines
        set lines {}
    } else {
        append lines $l\n
    }
}

text .t -width 30 -height 8
pack .t

set lines ""
fileevent $f readable "readALine $f lines .t"
