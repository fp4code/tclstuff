#!/bin/sh
# \
exec tclsh "$0" ${1+"$@"}

# 15 janvier 2002 (FP) bricole pour extraire les hosts de marsupilami.lpn.prive
# 27 octobre 2003 (FP) modif -silent

for {set vlan 4} {$vlan <= 10} {incr vlan} {
    for {set h 1} {$h < 255} {incr h} {
	puts stderr "nslookup 10.$vlan.0.$h"
        set err [catch {exec nslookup -silent 10.$vlan.0.$h} r]
        set r [split $r \n]
        if {[llength $r] == 6} {
            set Name [lindex $r 3]
            set Address [lindex $r 4]
            if {![regexp {^Name:[ 	]+(.+)$} $Name tout name]} {
                puts stderr "cannot regexp \"$Name\""
            }
            if {![regexp {^Address:[ 	]+(.+)$} $Address tout address]} {
                puts stderr "cannot regexp \"$Address\""
            }
            puts "$address $name [lindex [split $name .] 0]"
        }
    }
}