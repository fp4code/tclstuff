# casaNetA.04.tcl

source casaNetC.04.tcl

if {$argc != 1} {
    puts stderr "syntaxe $argv0 portServeur"
    exit 1
}
set casaNet_PORT_SERVEUR [lindex $argv 0]

proc casaNet_liaisonAcceptee {socketVersB adresseB portB} {
    fconfigure $socketVersB -blocking 0
    fileevent $socketVersB readable [list casaNet_litSocket $socketVersB]
    
    puts $socketVersB "Le serveur parle au client"
    flush $socketVersB
}

socket -server casaNet_liaisonAcceptee $casaNet_PORT_SERVEUR

puts "Serveur lancé"
puts "Lancez sur n'importe quelle machine \"tclsh casaNetB.04.tcl [info hostname] $casaNet_PORT_SERVEUR\""

vwait casaNet_TERMINE
