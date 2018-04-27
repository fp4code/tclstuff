# tclsh casaNetShiftSSH.01.tcl machineSSH portLocal

if {$argc != 2} {
    puts stderr "syntaxe $argv0 machineSSH portLocal"
    exit 1
}
set casaNet_machineSSH [lindex $argv 0]
set casaNet_portLocal  [lindex $argv 2]

proc casaNet_transmet {sockA sockB} {
    global casaNet_TERMINE

    set lu [gets $sockA]
    if {[eof $sockA]} {
        puts stderr "EOF [fconfigure $sockA -peername]"
        close $sockB
        set casaNet_TERMINE "terminé"
    } else {
        puts $sockB $lu
    }
}

proc casaNet_liaisonAcceptee {socketVersSSH adresseClient portClient} {

    puts stderr "Liaison acceptée de [fconfigure $socketVersB -peername]"

    fconfigure $socketVersB -blocking 0
    fileevent $socketVersB readable [list casaNet_litSocket $socketVersB casaNet_TERMINE]
    
    puts $socketVersB "$adresseB:$portB, connection établie !"
    set date [clock format [clock seconds]]
    puts $socketVersB "Il est $date"
    
    puts stderr "Connection de $adresseB à $date"
    puts stderr "Tapez sur le clavier"

    puts $socketVersB START
    fileevent stdin readable [list casaNet_sendB $socketVersB]
}

set casaNet_SOCKET_SERVEUR [socket -server casaNet_liaisonAcceptee $casaNet_PORT_SERVEUR]

puts "Serveur lancé"
puts "Lancez sur n'importe quelle machine \"tclsh casaNetB.05.tcl [info hostname] $casaNet_PORT_SERVEUR\""

vwait casaNet_TERMINE
