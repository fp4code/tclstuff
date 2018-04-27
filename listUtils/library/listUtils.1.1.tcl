package provide listUtils 1.1

# 1 juin 2001 (FP)

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

set HELP(::listUtils::scindeMonotone) {
    # 1 juin 2001 (FP)

    #               0  1  2  3  4  5  6  7  8  9 10 11 12 13 14 15 16 17 18
    scindeMonotone {1  1  1  2  3  4  5  5  5  6  6  7  8  8  5  6  6  1  1}
    # -> {{0 13} {12 14} {14 16} {15 18}}

}

proc ::listUtils::scindeMonotone {xlist} {
    if {[llength $xlist] < 2} {
        return -code error "la liste a moins de 2 éléments"
    }
    # liste de paires d'indices délimitant les listes monotones
    set nxlists [list]

    set i0 0
    set x0 [lindex $xlist 0]
    set x1 [lindex $xlist 1]

    if {$x0 < $x1} {
        set sens 1
    } elseif {$x0 > $x1} {
        set sens -1
    } else {
        set sens 0
    }
    set xa $x1
    set ia 1
    set ic {}

    for {set ib 2} {$ib < [llength $xlist]} {set ia $ib ; set xa $xb ; incr ib} {
        set xb [lindex $xlist $ib]
        if {$xa < $xb} {
            set nsens 1
        } elseif {$xa > $xb} {
            set nsens -1
        } else {
            set nsens 0
        }
        if {$sens == 0} {
            # cela n'arrive qu'au début, on attend d'embrayer sur une rampe
            if {$nsens != 0} {
                set sens $nsens
            }
        } elseif {$nsens == $sens} {
            # on continue la rampe, le cas échéant, le plateau est oublié
            set ic {}
        } elseif {$nsens == 0} {
            if {$ic == {}} {
                set ic $ia
            }
        } else {
            # la rampe change
            lappend nxlists [list $i0 $ia]
            set sens $nsens 
            if {$ic != {}} {
                set i0 $ic
                set ic {}
            } else {
                set i0 $ia
            }
        }
    }
    lappend nxlists [list $i0 $ia]
    return $nxlists
}


#############################
set HELP(listUtils::liminf) {
    (C) CNRS-LPN 2002.07.02 FP
    # trouve l'élément le plus petit borné par $val dans la liste $list
}

proc listUtils::liminf {list val} {
    set e {}
    foreach l $list {
        if {$l <= $val} {
            if {$e == {} || $e < $l} {
                set e $l
            }
        }
    }
    return $e
}

##############################
set HELP(listUtils::liminf2) {
    (C) CNRS-LPN 2002.07.02 FP
    # trouve l'élément le plus petit borné par $val dans la liste double $list
}

proc listUtils::liminf2 {list val} {
    set e {}
    set f {}
    foreach {l m} $list {
        if {$l <= $val} {
            if {$e == {} || $e < $l} {
                set e $l
		set f $m 
            }
        }
    }
    return [list $e $f]
}

###########################
set HELP(listUtils::limsup) {
    (C) CNRS-LPN 2002.07.02 FP
    # trouve l'élément le plus grand borné par $val dans la liste $list
}

proc listUtils::limsup {list val} {
    set e {}
    foreach l $list {
        if {$l >= $val} {
            if {$e == {} || $e > $l} {
                set e $l
            }
        }
    }
    return $e
}

############################
set HELP(listUtils::limsup2) {
    (C) CNRS-LPN 2002.07.02 FP
    # trouve l'élément le plus grand borné par $val dans la liste double $list
}

proc listUtils::limsup2 {list val} {
    set e {}
    set f {}
    foreach {l m} $list {
        if {$l >= $val} {
            if {$e == {} || $e > $l} {
                set e $l
		set f $m
            }
        }
    }
    return [list $e $f]
}

####################################
set HELP(listUtils::interpole) {
    (C) CNRS-LPN 2002.07.02 FP
    # interpole $val dans la liste double $list 
}

proc listUtils::interpole {list val} {
    set xy1 [liminf2 $list $val]
    set xy2 [limsup2 $list $val]
    set x1 [lindex $xy1 0]
    set y1 [lindex $xy1 1]
    set x2 [lindex $xy2 0]
    set y2 [lindex $xy2 1]

    if {$x1 == $val} {
	return $y1
    }
    if {$x2 == $val} {
	return $y2
    }
    if {$x1 == {} || $x2 == {}} {
        return -code error "Pas dans un intervalle : $val"
    }
    set y [expr {$y1*double($val-$x2)/double($x1-$x2) + $y2*double($val-$x1)/double($x2-$x1)}]
    return $y
}
