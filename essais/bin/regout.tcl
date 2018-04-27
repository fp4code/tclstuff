#!/bin/sh
# \
exec tclsh "$0" ${1+"$@"}

set STOP 0

proc put5 {i} {
    global STOP
    puts ${i}1
    puts ${i}2
    puts ${i}3
    puts ${i}4
    puts ${i}5
    puts {}
    flush stdout
    incr i
    if {$i > 10} {
        set STOP 1
    }
    after 2000 "put5 $i"
}

put5 1
vwait STOP
