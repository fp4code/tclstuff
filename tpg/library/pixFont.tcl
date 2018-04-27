package provide tpgPixFont 0.1

set HELP(tpg::FontCode) {
    remplit le tableau $arrayName avec une liste de points
    Les points sont des 0, les vides des espaces ou des .
}
proc tpg::FixedFontCode {arrayName largeur haut bas image names} {
    upvar $arrayName array
    set image [split $image \n]
    set l [llength $image]
    if {$l != 1 + $haut + $bas + 1} {
        return -code error "tpg::FontCode $arrayName : attendu 1 + $haut + $bas + 1 lignes, reçu $l"
    }
    set image [lrange $image 1 end-1]
    set y $haut
    foreach ligne $image {
        incr y -1
        set co 0
        foreach name $names {
            for {set x 0} {$x < $largeur} {incr x} {
                set char [string index $ligne $co]
                incr co
                if {$char == "0"} {
                    lappend array($name) $x $y
                } elseif {$char != " " && $char != "." && $char != ""} {
                    return -code error "tpg::FontCode $arrayName : caractère \"$char\" inattendu"
                }
            }
            incr co
        }
    }
}

proc tpg::createPixFont {arrayName sPrefix pixStep pixSize} {
    upvar $arrayName array
    foreach name [array names array] {
        tpg::Struct::new $sPrefix$name
        foreach {x y} $array($name) {
            ::tpg::brxy [expr {$x*$pixStep}] [expr {$y*$pixStep}] $pixSize $pixSize
        }
    }
}
