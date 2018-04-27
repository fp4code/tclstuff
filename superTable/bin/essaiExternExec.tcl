#!/bin/sh
#\
exec tclsh "$0" ${1+"$@"}

set i 0

while {![eof stdin]} {
    set s [gets stdin]
    if {$s != {}} {
        incr i
        puts stderr [list $i $s]
    } else {
        break
    }
}

puts "pr \"j'ai lu $i lignes\""
flush stdout

