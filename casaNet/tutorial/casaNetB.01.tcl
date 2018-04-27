# casaNetB.01.tcl

if {$argc != 2} {
    puts stderr "syntaxe $argv0 machineServeur portServeur"
    exit 1
}

set casaNet_MACHINE_A    [lindex $argv 0]
set casaNet_PORT_SERVEUR [lindex $argv 1]

set socketVersA [socket $casaNet_MACHINE_A $casaNet_PORT_SERVEUR]

puts "caract�ristiques de la liaison : [fconfigure $socketVersA]"

