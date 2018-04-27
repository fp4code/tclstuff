# Motifs de pre-alignement : Grand L et barre a 45 degres
# ========================================================

# Grand L de pre-alignement en bas a gauche du masque

namespace eval tpg {
    Struct::new grand_l
    setLayer 10 ;# Pour tous les niveaux

    boundary {;^180000;<10000;v190000;>190000;^10000;<180000;}

# Barre orientee a 45 degres pour orientation du substrat

    Struct::new barre_a_45
    setLayer 10 ;# Pour tous les niveaux
    
    set c [Chemin::rectangleCentre 5000 5000]
    set c [Chemin::translated -110000 90000 $c]
    for {set i 0} {$i<20} {incr i} {
        set c [Chemin::translated 10000 -10000 $c]
        bfc $c
    }
}
