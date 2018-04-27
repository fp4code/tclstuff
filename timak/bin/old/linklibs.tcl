#!/bin/sh
# \
exec tclsh "$0" ${1+"$@"}

if {$argc > 0} {
    set dirs $argv
} else {
    set dirs [glob /home/fab/C/*/lib]
}

foreach d $dirs {
    puts stderr "\ncd $d"
    cd $d
    foreach f [glob -nocomplain ../*/*/src/*.so] {
        puts -nonewline stderr "ln -s $f ."
        if {[catch {exec ln -s $f .} message]} {
            puts stderr "-> $message"
        } else {
            puts stderr "-> OK"
        }
    }
}
