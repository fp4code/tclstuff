# casaNetA.01.tcl

if {$argc != 1} {
    puts stderr "syntaxe $argv0 portServeur"
    exit 1
}
set casaNet_PORT_SERVEUR [lindex $argv 0]

proc casaNet_liaisonAcceptee {socketVersB adresseB portB} {
    puts "liaisonAcceptee $socketVersB $adresseB $portB"
    puts "caractéristiques de la liaison : [fconfigure $socketVersB]"
}

socket -server casaNet_liaisonAcceptee $casaNet_PORT_SERVEUR

puts "Serveur lancé"
puts "Lancez sur n'importe quelle machine \"tclsh casaNetB.01.tcl [info hostname] $casaNet_PORT_SERVEUR\""

vwait casaNet_TERMINE
