#!/usr/local/bin/tclsh

set f [open /home/scollin/gratings/AllMat r]
set fichier [read -nonewline $f] ; close $f
if {![regexp {^\\!\\\((.*)\\\)$} $fichier tout reste]} {
    error "cannot regexp"
}

set liste [list]
set ip 0
while {[regexp -indices {[^\\]([\{\},])|^([\{\},])} [string range $reste $ip end] tout i j]} {
    set ia [lindex $i 0]
    if {$ia == -1} {
	set ia [lindex $j 0]
    }
    incr ip $ia
    lappend liste $ip
    incr ip 1
}

puts [list reste [string range $reste $ip end]]


