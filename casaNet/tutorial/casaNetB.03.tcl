# casaNetB.03.tcl

source casaNetC.03.tcl

if {$argc != 2} {
    puts stderr "syntaxe $argv0 machineServeur portServeur"
    exit 1
}

set casaNet_MACHINE_A    [lindex $argv 0]
set casaNet_PORT_SERVEUR [lindex $argv 1]

set socketVersA [socket $casaNet_MACHINE_A $casaNet_PORT_SERVEUR]

fconfigure $socketVersA -blocking 0
fileevent $socketVersA readable [list casaNet_litSocket $socketVersA]

puts $socketVersA "Le client parle au serveur"
flush $socketVersA

after 2000 {set casaNet_TERMINE nimportequoi}
vwait casaNet_TERMINE
