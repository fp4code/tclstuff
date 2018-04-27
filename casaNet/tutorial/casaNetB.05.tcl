# casaNetB.05.tcl

source casaNetC.05.tcl

if {$argc != 2} {
    puts stderr "syntaxe $argv0 machineServeur portServeur"
    exit 1
}

proc casaNet_connecteA {casaNet_MACHINE_A casaNet_PORT_SERVEUR} {

    set socketVersA [socket $casaNet_MACHINE_A $casaNet_PORT_SERVEUR]
    
    fconfigure $socketVersA -blocking 0
    fileevent $socketVersA readable [list casaNet_litSocket $socketVersA casaNet_TERMINE]
    
    puts $socketVersA "Le client parle au serveur"
    flush $socketVersA
}    

casaNet_connecteA [lindex $argv 0] [lindex $argv 1]

vwait casaNet_TERMINE


