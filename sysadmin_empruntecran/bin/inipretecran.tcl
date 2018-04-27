#!/prog/Tcl/bin/tclsh

if {$argc != 0} {
    puts stderr "Syntaxe : [info script]"
    exit 1
}


set home $env(HOME)
set fichier $home/.XauthorityDONS
puts "exec touch $fichier"
exec touch $fichier
exec chmod 622 $fichier

exit 0
