# casaNetA.02.tcl

if {$argc != 1} {
    puts stderr "syntaxe $argv0 portServeur"
    exit 1
}
set casaNet_PORT_SERVEUR [lindex $argv 0]

proc casaNet_liaisonAcceptee {socketVersB adresseB portB} {
    puts $socketVersB "Le serveur parle au client"
    flush $socketVersB
    puts stdout "Le client a dit \"[gets $socketVersB]\""
}

socket -server casaNet_liaisonAcceptee $casaNet_PORT_SERVEUR

puts "Serveur lancé"
puts "Lancez sur n'importe quelle machine \"tclsh casaNetB.02.tcl [info hostname] $casaNet_PORT_SERVEUR\""

vwait casaNet_TERMINE
