#!/bin/sh
# the next line restarts using tclsh \
exec tclsh "$0" "$@"

package require fidev

set lignes [split [read -nonewline stdin] \n]

proc tri {a b} {
    set d [expr {[lindex $a 3] - [lindex $b 3]}]
    if {$d != 0} {
	return $d
    }
    return [string compare [lindex $a 1] [lindex $b 1]]
}

if {! [catch {lsort -command tri $lignes} retour]} {
    set lignes $retour
} else {
    puts stdout "# $retour"
}

foreach l $lignes {
    puts stdout $l
}


