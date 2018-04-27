package provide listUtils 1.0

namespace eval listUtils {}

set HELP(listUtils::reorderList) {
    retourne une liste ordonnée par une autre liste
    
    ex : listUtils::reorderList {q r v e} {e z r} 	renvoie {e r q v}

}

proc listUtils::reorderList {list model} {
    foreach e $list {
        if {[info exists elems($e)]} {
            error "element \"$e\" already exists in list"
        }
        set elems($e) {}
    }
    set ret [list]
    set ret2 [list]
    foreach e $model {
        if {[info exists elems($e)]} {
            lappend ret $e
            unset elems($e)
        }
    }
    foreach e $list {
        if {[info exists elems($e)]} {
            lappend ret $e
            unset elems($e)
        }
    }
    return $ret
}

set HELP(listUtils::calcMoy) {
    INTRO {calcul de la moyenne de la liste $liste}
}

proc listUtils::calcMoy {list} {
    set moy [expr 0.0]
    set i 0
    foreach v $list {
	set moy [expr {$moy+$v}]
	incr i
    }
    set moy [expr {$moy/$i}]
    return $moy
}

