# casaNetShiftPort.01.tcl

if {$argc != 3} {
    puts stderr "syntaxe $argv0 machineServeur portServeur portLocal"
    exit 1
}
set casaNet_machineServeur [lindex $argv 0]
set casaNet_portServeur    [lindex $argv 1]
set casaNet_portLocal      [lindex $argv 2]

proc casaNet_transmet {sockA sockB} {
    global casaNet_TERMINE

    set bytes [read $sockA 4096]
    if {[string length $bytes] != 0} {
        puts -nonewline $sockB $bytes
        flush $sockB
        # puts "$bytes"
    }

    if {[eof $sockA]} {
        puts stderr "EOF $sockA ([fconfigure $sockA -peername])"
        fileevent $sockA readable {}
        fileevent $sockB readable {}
        close $sockA
        close $sockB
    }
}

proc casaNet_liaisonAcceptee {machineServeur portServeur socketClient adresseClient portClient} {

    puts stderr "Liaison acceptée de [fconfigure $socketClient -peername]"

    set err [catch {socket $machineServeur $portServeur} socketServeur]
    if {$err} {
        puts stderr "connexion refusée vers $machineServeur:$portServeur ($socketServeur)"
        return
    }

    puts stderr "Liaison acceptée vers [fconfigure $socketServeur -peername]"

    fconfigure $socketClient \
            -blocking 0 -buffering full -buffersize 4096 -translation binary -encoding binary
    fileevent $socketClient readable [list casaNet_transmet $socketClient $socketServeur]

    fconfigure $socketServeur \
            -blocking 0 -buffering full -buffersize 4096 -translation binary -encoding binary
    fileevent $socketServeur readable [list casaNet_transmet $socketServeur $socketClient]
}

socket -server [list casaNet_liaisonAcceptee $casaNet_machineServeur $casaNet_portServeur] $casaNet_portLocal
puts "Serveur lancé"
vwait casaNet_TERMINE
