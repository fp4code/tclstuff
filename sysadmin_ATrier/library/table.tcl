set HELP(tableau) {
    crée une table de nom $aresul à partir des lignes $lignes
    
# OLD    La première de ces lignes contient le nom des colonnes
    entete est la ligne qui contient la liste des colonnes
    Cette ligne correspond à la liste des colonnes aresul(COLONNES)
    
    La première colonne sert d'index. La liste des index se retrouve
    dans aresul(LIGNES)
    
    Les valeurs de la table se retrouvent dans
        aresul(nom_de_ligne,nom_de_colonne)
}

proc tableau {aresul entete lignes {split {}}} {
    upvar $aresul resul
    if {$split == {}} { 
        set colonnes [eval list $entete]
    } else {
        set colonnes [split $entete $split]
    }
#    set lignes [lrange $lignes 1 end]
    set resul(COLONNES) $colonnes
    
    set Names {}

    foreach l $lignes {
        if {$split == {}} { 
            set vals [eval list $l]
        } else {
            set vals [split $l $split]
        }
        set name [lindex $vals 0]
        lappend Names $name
        set ic 0
        foreach c $colonnes {
            set resul($name,$c) [lindex $vals $ic]
            incr ic
        }
    }

    set resul(LIGNES) $Names
}


set HELP(imprimeTable) {
    Imprime sur stdout la table $at

}
proc imprimeTable at {
    upvar $at t
    foreach c $t(COLONNES) {
        set lala0 [string length $c]
        foreach l $t(LIGNES) {
            set lala [string length $t($l,$c)]
            if {$lala0 < $lala} {
                set lala0 $lala
            }
        }
        set largeur($c) $lala0
    }

    foreach c $t(COLONNES) {
        puts -nonewline " [format %$largeur($c)s $c]"
    }
    puts ""
    foreach l [lsort $t(LIGNES)] {
        foreach c $t(COLONNES) {
            puts -nonewline " [format %$largeur($c)s $t($l,$c)]"
        }
        puts ""
    }
}
