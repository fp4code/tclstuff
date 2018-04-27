# Mathématique formelle

# lettre = [list 0 "n'importe quoi"]
# signes = [list 1 {\vee}] [list 1 {\neg}] [list lien {\tau}] [list lien {\box}]
# assemblage = liste de signes ou de lettres
#      les assemblages sont normalisés, c'est à dire que les liens sont des nombres
# croissants à partir de 2 au fur et à mesure où l'on rencontre {\tau} 

figureDans {assemblage lettre} {
    foreach x $assemblage {
        if {[lindex $x] != 0} continue
        if {[lindex $x 1] == $lettre} {
            return true
        }
    }
    return false
}

substitution {assemblage lettre subst} {
    set new [list]
    set actualIndex 2
    set incrIndex 0
    foreach x $assemblage {
        set indice [lindex $x 0]
        set contenu [lindex $x 1]
        if {$indice >= 2} {
            incr indice $incrIndex
            lappend new [list $indice $contenu]
        } elseif {$indice != 0 || $contenu != $lettre} {
            lappend new $x
        } else {
            set sincrIndex ....
            foreach s $subst {
                set indice [lindex $s 0]
                set contenu [lindex $s 1]
                if {$indice >= 2} {
                    incr indice $sincrIndex
                lappend new [list $indice $contenu]
            } else {
                lappend new $x
            }
        }
  
}

CS1a {A B x y} {
    


