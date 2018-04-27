# simulation de commandes asyst

proc installIn {xeq pro} {
    if {![string match *.xeq $xeq]} {
        error "installIn ne peut modifier qu'une commande *.xeq"
    }
    
    set args [info args $xeq]
    if {$args != [info args $pro]} {
        error "Les commandes $xeq et $pro n'on pas les mêmes arguments"
    }
    
    set bobo $pro
    foreach a $args {
        append bobo " \$$a"
    }
    proc $xeq $args $bobo
}

set HELP(installIn) {
installIn commande.xeq commande_a_installer
}


