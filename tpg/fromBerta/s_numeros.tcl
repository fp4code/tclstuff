# Numerotation des blocs
# =======================

# Ligne des numeros de colonnes : colonne 0 a gauche

namespace eval tpg {

    Struct::new lig_des_num_col

    for {set co 0} {$co <= 8} {incr co} {
        sref ch_$co [expr 1800 + $co*20000] 19150
        sref slash [expr 1800 + $co*20000 + 300] 19150
    }

    setLayer 0  ;# Niveau de debugging (a ne pas fabriquer)
    
    brxy 0 0 180000 20000

# Colonne des numeros de lignes : ligne 0 en haut

    Struct::new col_des_num_lig

    for {set li 0} {$li <= 8} {incr li} {
        sref ch_$li 2400 [expr 19150 + (8 - $li)*20000]
    }

    setLayer 0  ;# Niveau de debugging (a ne pas fabriquer)

    brxy 0 0 20000 180000

    Struct::new numeros                            ;# Matrice 9 x 9

    for {set co 0} {$co <=8} {incr co} {
        sref col_des_num_lig [expr $co*20000] 0
    }

    for {set li 0} {$li <=8} {incr li} {
        sref lig_des_num_col 0 [expr $li*20000]
    }

}
