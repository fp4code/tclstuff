#!/usr/local/bin/tclsh

proc positive {i} {
    return [expr $i >= 0]
}

set i 2
while [getIt $i] {
    puts $i
    incr i -1
    if {$i == 0} {
	puts "Arret ici avec la version <= 8.0"
    if {$i < 0} {
	puts stderr "La version $tcl_version continue"
	break
    }
}
