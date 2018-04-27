#!/usr/local/bin/tclsh

# ----------------------------------------------------------------------
# nisTo3col : 
# ----------------------------------------------------------------------

proc nisTo3col {racine table liste} {
    # contenu de la table NIS+ (clé-valeur) transformé en liste plate l
    set l [exec niscat $table]
    set l [split $l \n]
    # l transformée en tableau T(clé) = valeur
    foreach ll $l {
        foreach {nom mp} $ll {}
        set T($nom) $mp
    }
    # 
    set ret [list]
    foreach nom $liste {
        if {![info exists T($nom)]} {
            puts stderr "$table : pas de cle $nom"
        } else {
            set mp [split $T($nom) :]
            foreach {ou quoi} $mp {}
            lappend ret [list $racine/$nom $ou $quoi]
        }
    }
    return $ret
}

# ----------------------------------------------------------------------
# Programme principal
# ----------------------------------------------------------------------

set HOMEDIR /export/home
cd $HOMEDIR
set homes [glob \[a-z\]*]
set homes [lsort $homes]

puts [nisTo3col /home auto_home.org_dir $homes]