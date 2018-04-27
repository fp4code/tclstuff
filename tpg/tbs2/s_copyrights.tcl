# Copyrights : Nom du masque, date, CNRS...
# ===========================================


namespace eval tpg {
    Struct::new copyrights

    setLayer 0  ;# Niveau de debugging (a ne pas fabriquer)

    brxy 0 0 4500 3000

    proc caractere {c} {
        binary scan AZaz09 cccccc iA iZ ia iz i0 i9
        binary scan $c c icar
        if {$icar >= $iA && $icar <= $iZ} {
            set icar [expr $icar + $ia - $iA]
            set nom [binary format c $icar]_maj
        } elseif {$icar >= $ia && $icar <= $iz} {
            set nom ${c}_min
        } elseif {$icar >= $i0 && $icar <= $i9} {
            set nom ch_$c
        } elseif {$c == ":"} {
            set nom deux_points
        } elseif {$c == "/"} {
            set nom slash
        } elseif {$c == "-"} {
            set nom tiret
        } else {
            erreur "\"caractere $c\" pas defini"
        }
        return $nom
    }

    proc imprimeLettres {chaine x y dx} {
        foreach c [split $chaine {}] {
            sref [caractere $c] $x $y
            set x [expr $x + $dx]
        }
    }

    imprimeLettres "MASQUE:TBS2" 625 2150 300
    imprimeLettres "30/01/95" 1075 1400 300
    sref fico 500 650
    imprimeLettres "CNRS-L2M" 1650 650 300

#    displayWinStruct copyrights 0.1
}

