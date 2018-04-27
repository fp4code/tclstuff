# $Id 18 février 2003 essais

set BUGS {
    L'infini est affiché par Tcl_PrintDouble comme -Infinity, mais lu

    set tcl_precision 10
    set x [expr {1./3.}]
    set xx [list $x $x]
    format %.20g $x
    format %.20g [lindex $xx 0]
    format %.20g [lindex $xx 1]
    
}

package require fidev
package require oplan

set tcl_precision 17

set di_pi [di atan2 -1 0]
set di_2pi [di mul $di_pi 2]

set lambda [di interval_d 4.0]
set kx0N [di interval_d 0.0]
set k0 [list xy [di div $di_2pi $lambda]  [di interval_d 0.0]]
set d1 [di interval_d 0.5]
set d2 [di interval_d 0.5]
set eps1 [list xy [di interval_d 1.0] [di interval_d 0.0]]
set eps2 [list xy [di interval_d -598.4] [di interval_d 127.920]]
set kappaz [scplxi xy_mul $k0 [list xy [di interval_d 1.05024890425] [di interval_d 10.00521994144639]]]
set kx0 [scplxi xy_scalmul $k0 $kx0N]


##############
# Affichages #
##############

set HELP(putz) {
    affiche l'intervalle $z
}
proc putz {z} {
    set x [scplxi xy_re $z]
    set y [scplxi xy_im $z]
    puts stderr [list [list [format %.20g [di inf $x]] [format %.20g [di sup $x]]] [list [format %.20g [di inf $y]] [format %.20g [di sup $y]]]]
}

###############################
# Calcul de fonction de modes #
###############################

set HELP(fD0) {
    retourne f à partir du carré de z
}
proc fD0 {zC} {
    global k0 kx0 eps1 eps2 d1 d2

    # set z [scplxi xy_sqrt $zC]
    set z $zC
    
    set kappaz [scplxi xy_mul $k0 $z]
    set func [oplan::modetm $k0 $kx0 $kappaz $eps1 $eps2 $d1 $d2]
    set x [scplxi xy_re $func]
    set y [scplxi xy_im $func]
    set xm [di mid $x]
    set ym [di mid $y]
    set xw [di wid $x]
    set yw [di wid $y]
    # puts stderr [list $zx $zy -> [list [format %.5g [lindex $x 0]] [format %.5g [lindex $x 1]]] [list  [format %.5g [lindex $y 0]] [format %.5g [lindex $y 1]]]]
    return $func
} 

set HELP(fz) {
    retourne la valeur de f à partir de $z
}
proc fz {z} {return [fD0 $z]}

set HELP(f) {
    retourne la valeur de f à partir de la partie réelle $zx
    et de la partie imaginaire $zy
}
proc f {zx zy} {
    return [fz [scplxi xy_new $zx $zy]]
    # puts stderr $fz
}


proc fD0D1 {var} {
    global k0 kx0 eps1 eps2 d1 d2

    # set kappazC [scplxi xy_mul $var [scplxi xy_sqr $k0]]
    # set var [scplxi xy_mul $var $k0]

    return [oplan::modetmD1 $d1 $d2 $eps1 $eps2 $k0 $kx0 $var]
}

proc fD0onD1 {zC} {
    set f [fD0D1 $zC]
    set f0 [lindex $f 0]
    set f1 [lindex $f 1]
    return [scplxi xy_div $f0 $f1]
}

proc fD1onD0 {zC} {
    set f [fD0D1 $zC]
    set f0 [lindex $f 0]
    set f1 [lindex $f 1]
    return [scplxi xy_div $f1 $f0]
}

#############
# Quadrants #
#############

proc quadrantXY {x y} {
    if {[di cgt $y 0]} {
        if {[di cgt $x 0]} {
            return ne
        }
        if {[di clt $x 0]} {
            return nw
        }
        return n
    }
    if {[di clt $y 0]} {
        if {[di clt $x 0]} {
            return sw
        }
        if {[di cgt $x 0]} {
            return se
        }
        return s
    }
    if {[di cgt $x 0]} {
        return e
    }
    if {[di clt $x 0]} {
        return w
    }
    return 0
}

proc quadrant {z} {
    set q [quadrantXY [scplxi xy_re $z] [scplxi xy_im $z]]
    # puts stderr "q $z -> $q"
    return $q
}

proc quadrant16XY {x y} {
    if {[di cgt $y 0]} {
        if {[di cgt $x 0]} {
            if {[di cgt $x $y]} {
                return ene
            }
            if {[di cgt $y $x]} {
                return nne
            }
            return ne
        }
        if {[di clt $x 0]} {
            set xabs [di neg $x]
            if {[di cgt $xabs $y]} {
                return wnw
            }
            if {[di cgt $y $xabs]} {
                return nnw
            }
            return nw
        }
        return n
    }
    if {[di clt $y 0]} {
        set yabs [di neg $y]
        if {[di clt $x 0]} {
            set xabs [di neg $x]
            if {[di cgt $xabs $yabs]} {
                return wsw
            }
            if {[di cgt $yabs $xabs]} {
                return ssw
            }
            return sw
        }
        if {[di cgt $x 0]} {
            if {[di cgt $x $yabs]} {
                return ese
            }
            if {[di cgt $yabs $x]} {
                return sse
            }
            return se
        }
        return s
    }
    if {[di cgt $x 0]} {
        return e
    }
    if {[di clt $x 0]} {
        return w
    }
    return 0
}

proc quadrant16 {z} {
    set q [quadrant16XY [scplxi xy_re $z] [scplxi xy_im $z]]
    # puts stderr "q $z -> $q"
    return $q
}


proc q {x y} {
    return [quadrant [f $x $y]]
}

proc quadrantsD0D1 {z} {
    set f [fD0D1 $z]
    return [list [quadrant [lindex $f 0]] [quadrant16  [lindex $f 1]]]
}

proc quadrantsD0D1+ {z} {
    set f [fD0D1 $z]
    return [list [quadrant16 [lindex $f 0]] [quadrant16  [lindex $f 1]]]
}


######################
# Splits basés sur f #
######################

set HELP(splitx) {
    - Découpe un segment parallèle à Ox, de "$x1 $y" à "$x2 $y"
      sur la base de la fonction f
    - Retourne une liste de triplets "$quadrant $xa $xb"
      le premier $xa vaut $x1, le dernier $xb vaut $x2, chaque $x2 est identique au $x1 suivant
      $quadrant vaut [oneOf e ne n nw w sw s se]
}
proc splitx {y x1 x2} {
    # puts -nonewline stderr "**** splitx x=\{$x1 $x2\} y=$y "
    set ret [list]
    if {$x1 < $x2} {
        set xa $x1
        set xb $x2
    } elseif {$x1 > $x2} {
        set xa $x2
        set xb $x1
    } else {
        return -code error "split Point [list $x1 $y] !"
    }
    
    if {[set q [quadrant [f [di interval_d_d $xa $xb] [di interval_d $y]]]] != 0} {
        set ret [list [list $q $x1 $x2]]
        # puts stderr "OKOKOK $q $x1 $x2"
    } else {
        set xx [moy $x1 $x2]
        # puts stderr "SPLIT $x1 $x2 -> $xx"
        if {$xx == $x1 || $xx == $x2} {
            return -code error "precision limit in \{$x1 $x2\} $y"
        }
        set ret [concat [splitx $y $x1 $xx] [splitx $y $xx $x2]]
    }
    return $ret
}

set HELP(splity) {
    - Découpe un segment parallèle à Oy, de "$x $y1" à "$x $y2"
      sur la base de la fonction f
    - Retourne une liste de triplets "$quadrant $ya $yb"
      le premier $ya vaut $y1, le dernier $yb vaut $y2, chaque $y2 est identique au $y1 suivant
      $quadrant vaut [oneOf e ne n nw w sw s se]
      C'est la position de f(segment)
}
proc splity {x y1 y2} {
    # puts -nonewline stderr "*** splity x=$x y=\{$y1 $y2\} "
    set ret [list]
    if {$y1 < $y2} {
        set ya $y1
        set yb $y2
    } elseif {$y1 > $y2} {
        set ya $y2
        set yb $y1
    } else {
        return -code error "split Point [list $x $y1] !"
    }
    
    if {[set q [quadrant [f $x [di interval_d_d $ya $yb]]]] != 0} {
        set ret [list [list $q $y1 $y2]]
        # puts stderr "OKOKOK $q $y1 $y2"
    } else {
        set yy [moy $y1 $y2]
        # puts stderr "SPLIT $yy"
        if {$yy == $y1 || $yy == $y2} {
            return -code error "precision limit in $x \{$y1 $y2\}"
        }
        set ret [concat [splity $x $y1 $yy] [splity $x $yy $y2]]
    }
    return $ret
}

set HELP(sspx) {
    - Découpe un segment parallèle à Ox, de "$x1 $y" à "$x2 $y"
      sur la base de la fonction f
    - Retourne une liste de listes "$quadrant y = $y x = $xa $xb $xc $xd ..."
      le premier $xa vaut $x1, le dernier $xx vaut $x2, chaque dernier $xx est identique au $x1 suivant
      $quadrant vaut [oneOf e ne n nw w sw s se]
      Deux $quadrant sont toujours différents mais se suivent
}
proc sspx {y x1 x2} {
    # puts stderr "*** sspx $y $x1 $x2"
    set prev {}
    set ret [list]
    set elem [list]
    foreach l [splitx $y $x1 $x2] {
        if {[lindex $l 0] != $prev} {
            if {$elem != {}} {
                lappend ret $elem
                set elem [list]
            }
            lappend elem [lindex $l 0] y = $y x = [lindex $l 1]
            set prev [lindex $l 0]
        }
        lappend elem [lindex $l 2]
    }
    lappend ret $elem
    return $ret
}

set HELP(sspy) {
    - Découpe un segment parallèle à Oy, de "$y1 $x" à "$y2 $x"
      sur la base de la fonction f
    - Retourne une liste de listes "$quadrant x = $x y = $ya $yb $yc $yd ..."
      le premier $ya vaut $y1, le dernier $yy vaut $y2, chaque dernier $yy est identique au $y1 suivant
      $quadrant vaut [oneOf e ne n nw w sw s se]
      Deux $quadrant sont toujours différents mais se suivent
}
proc sspy {x y1 y2} {
    # puts stderr "*** sspy $x $y1 $y2"
    set prev {}
    set ret [list]
    set elem [list]
    foreach l [splity $x $y1 $y2] {
        if {[lindex $l 0] != $prev} {
            if {$elem != {}} {
                lappend ret $elem
                set elem [list]
            }
            lappend elem [lindex $l 0] x = $x y = [lindex $l 1]
            set prev [lindex $l 0]
        }
        lappend elem [lindex $l 2]
    }
    lappend ret $elem
    return $ret
}

proc ce {z} {
    set x [scplxi xy_re $z]
    set y [scplxi xy_im $z]
    set x1 [di inf $x]
    set x2 [di sup $x]
    set y1 [di inf $y]
    set y2 [di sup $y]
    return [sspy $x2 $y1 $y2]
}

proc cn {z} {
    set x [scplxi xy_re $z]
    set y [scplxi xy_im $z]
    set x1 [di inf $x]
    set x2 [di sup $x]
    set y1 [di inf $y]
    set y2 [di sup $y]
    return [sspx $y2 $x2 $x1]
}

proc cw {z} {
    set x [scplxi xy_re $z]
    set y [scplxi xy_im $z]
    set x1 [di inf $x]
    set x2 [di sup $x]
    set y1 [di inf $y]
    set y2 [di sup $y]
    return [sspy $x1 $y2 $y1]
}

proc cs {z} {
    set x [scplxi xy_re $z]
    set y [scplxi xy_im $z]
    set x1 [di inf $x]
    set x2 [di sup $x]
    set y1 [di inf $y]
    set y2 [di sup $y]
    return [sspx $y1 $x1 $x2]
}

############################
# Splits basés sur fD0onD1 #
# pas optimal si fD0onD1 est calculé par fD0/fD1 #
############################

set HELP(splitxN) {
    - Découpe un segment parallèle à Ox, de "$x1 $y" à "$x2 $y",
      sur la base de la fonction fD0onD1
    - Retourne une liste de triplets "$quadrant $xa $xb"
      le premier $xa vaut $x1, le dernier $xb vaut $x2, chaque $x2 est identique au $x1 suivant
      $quadrant vaut [oneOf e ne n nw w sw s se]
}
proc splitxN {y x1 x2} {
    # puts -nonewline stderr "**** splitxN x=\{$x1 $x2\} y=$y "
    set ret [list]
    if {$x1 < $x2} {
        set xa $x1
        set xb $x2
    } elseif {$x1 > $x2} {
        set xa $x2
        set xb $x1
    } else {
        return -code error "split Point [list $x1 $y] !"
    }
    
    if {[set q [quadrant [fD0onD1 [scplxi xy_new [di interval_d_d $xa $xb] [di interval_d $y]]]]] != 0} {
        set ret [list [list $q $x1 $x2]]
        # puts stderr "OKOKOK $q $x1 $x2"
    } else {
        set xx [moy $x1 $x2]
        # puts stderr "SPLIT $x1 $x2 -> $xx"
        if {$xx == $x1 || $xx == $x2} {
            return -code error "precision limit in \{$x1 $x2\} $y"
        }
        set ret [concat [splitxN $y $x1 $xx] [splitxN $y $xx $x2]]
    }
    return $ret
}

set HELP(splityN) {
    - Découpe un segment parallèle à Oy, de "$x $y1" à "$x $y2"
      sur la base de la fonction fD0onD1
    - Retourne une liste de triplets "$quadrant $ya $yb"
      le premier $ya vaut $y1, le dernier $yb vaut $y2, chaque $y2 est identique au $y1 suivant
      $quadrant vaut [oneOf e ne n nw w sw s se]
      C'est la position de f(segment)
}
proc splityN {x y1 y2} {
    # puts -nonewline stderr "*** splityN x=$x y=\{$y1 $y2\} "
    set ret [list]
    if {$y1 < $y2} {
        set ya $y1
        set yb $y2
    } elseif {$y1 > $y2} {
        set ya $y2
        set yb $y1
    } else {
        return -code error "split Point [list $x $y1] !"
    }
    
    if {[set q [quadrant [fD0onD1 [scplxi xy_new $x [di interval_d_d $ya $yb]]]]] != 0} {
        set ret [list [list $q $y1 $y2]]
        # puts stderr "OKOKOK $q $y1 $y2"
    } else {
        set yy [moy $y1 $y2]
        # puts stderr "SPLIT $yy"
        if {$yy == $y1 || $yy == $y2} {
            return -code error "precision limit in $x \{$y1 $y2\}"
        }
        set ret [concat [splityN $x $y1 $yy] [splityN $x $yy $y2]]
    }
    return $ret
}


proc sspxN {y x1 x2} {
    # puts stderr "*** sspxN $y $x1 $x2"
    set prev {}
    set ret [list]
    set elem [list]
    foreach l [splitxN $y $x1 $x2] {
        if {[lindex $l 0] != $prev} {
            if {$elem != {}} {
                lappend ret $elem
                set elem [list]
            }
            lappend elem [lindex $l 0] y = $y x = [lindex $l 1]
            set prev [lindex $l 0]
        }
        lappend elem [lindex $l 2]
    }
    lappend ret $elem
    return $ret
}

proc sspyN {x y1 y2} {
    # puts stderr "*** sspyN $x $y1 $y2"
    set prev {}
    set ret [list]
    set elem [list]
    foreach l [splityN $x $y1 $y2] {
        if {[lindex $l 0] != $prev} {
            if {$elem != {}} {
                lappend ret $elem
                set elem [list]
            }
            lappend elem [lindex $l 0] x = $x y = [lindex $l 1]
            set prev [lindex $l 0]
        }
        lappend elem [lindex $l 2]
    }
    lappend ret $elem
    return $ret
}

###############################
# Splits basés sur fD0 et fD1 #
###############################

proc splitxD0D1 {y x1 x2} {
    set ret [list]
    if {$x1 < $x2} {
        set xa $x1
        set xb $x2
    } elseif {$x1 > $x2} {
        set xa $x2
        set xb $x1
    } else {
        return -code error "split Point [list $x1 $y] !"
    }
    
    set q [quadrantsD0D1 [scplxi xy_new [di interval_d_d $xa $xb] [di interval_d $y]]]
    if {[lindex $q 0] != 0 && [lindex $q 1] != 0} {
        set ret [list [list $q $x1 $x2]]
        # puts stderr "OKOKOK $q $x1 $x2"
    } else {
        set xx [moy $x1 $x2]
        # puts stderr "SPLIT $x1 $x2 -> $xx"
        if {$xx == $x1 || $xx == $x2} {
            return -code error "precision limit in \{$x1 $x2\} $y"
        }
        set ret [concat [splitxD0D1 $y $x1 $xx] [splitxD0D1 $y $xx $x2]]
    }
    return $ret
}

proc splityD0D1 {x y1 y2} {
    set ret [list]
    if {$y1 < $y2} {
        set ya $y1
        set yb $y2
    } elseif {$y1 > $y2} {
        set ya $y2
        set yb $y1
    } else {
        return -code error "split Point [list $x $y1] !"
    }
    
    set q [quadrantsD0D1 [scplxi xy_new [di interval_d $x] [di interval_d_d $ya $yb]]]
    if {[lindex $q 0] != 0 && [lindex $q 1] != 0} {
        set ret [list [list $q $y1 $y2]]
        # puts stderr "OKOKOK $q $y1 $y2"
    } else {
        set yy [moy $y1 $y2]
        # puts stderr "SPLIT $y1 $y2 -> $yy"
        if {$yy == $y1 || $yy == $y2} {
            return -code error "precision limit in $x \{$y1 $y2\}"
        }
        set ret [concat [splityD0D1 $x $y1 $yy] [splityD0D1 $x $yy $y2]]
    }
    return $ret
}

proc sspxD0D1 {y x1 x2} {
    # puts stderr "*** sspxD0D1 $y $x1 $x2"
    set prev {}
    set ret [list]
    set elem [list]
    foreach l [splitxD0D1 $y $x1 $x2] {
        if {[lindex $l 0] != $prev} {
            if {$elem != {}} {
                lappend ret $elem
                set elem [list]
            }
            lappend elem [lindex $l 0] y = $y x = [lindex $l 1]
            set prev [lindex $l 0]
        }
        lappend elem [lindex $l 2]
    }
    lappend ret $elem
    return $ret
}

proc sspyD0D1 {x y1 y2} {
    # puts stderr "*** sspyD0D1 $x $y1 $y2"
    set prev {}
    set ret [list]
    set elem [list]
    foreach l [splitxD0D1 $x $y1 $y2] {
        if {[lindex $l 0] != $prev} {
            if {$elem != {}} {
                lappend ret $elem
                set elem [list]
            }
            lappend elem [lindex $l 0] x = $x y = [lindex $l 1]
            set prev [lindex $l 0]
        }
        lappend elem [lindex $l 2]
    }
    lappend ret $elem
    return $ret
}

proc sspxD0D1print {y x1 x2} {
    foreach l [sspxD0D1 $y $x1 $x2] {
        puts [list [lindex $l 0] [lindex $l 3] [list [lindex $l 6] [lindex $l end]]]
    }
}

proc sspyD0D1print {x ys y2} {
    foreach l [sspyD0D1 $x $ys $y2] {
        puts [list [lindex $l 0] [list [lindex $l 6] [lindex $l end]] [lindex $l 3]]
    }
}

# version simplifiée
proc sspxsD0D1 {y x1 x2} {
    set prevD0 {}
    set prevD1 {}
    set retD0 [list]
    set retD1 [list]
    set elemD0 [list]
    set elemD1 [list]
    foreach l [splitxD0D1 $y $x1 $x2] {
	set didi [lindex $l 0]
	set diD0 [lindex $didi 0]
	set diD1 [lindex $didi 1]
        if {$diD0 != $prevD0} {
            if {$elemD0 != {}} {
		lappend elemD0 $last
                lappend retD0 $elemD0
                set elemD0 [list]
            }
            lappend elemD0 $diD0 [lindex $l 1]
            set prevD0 $diD0
        }
        if {$diD1 != $prevD1} {
            if {$elemD1 != {}} {
		lappend elemD1 $last
                lappend retD1 $elemD1
                set elemD1 [list]
            }
            lappend elemD1 $diD1 [lindex $l 1]
            set prevD1 $diD1
        }
	set last [lindex $l 2]
    }
    lappend elemD0 $last
    lappend elemD1 $last
    lappend retD0 $elemD0
    lappend retD1 $elemD1
    return [list $retD0 $retD1]
}

# version simplifiée
proc sspysD0D1 {x y1 y2} {
    set prevD0 {}
    set prevD1 {}
    set retD0 [list]
    set retD1 [list]
    set elemD0 [list]
    set elemD1 [list]
    foreach l [splityD0D1 $x $y1 $y2] {
	set didi [lindex $l 0]
	set diD0 [lindex $didi 0]
	set diD1 [lindex $didi 1]
        if {$diD0 != $prevD0} {
            if {$elemD0 != {}} {
		lappend elemD0 $last
                lappend retD0 $elemD0
                set elemD0 [list]
            }
            lappend elemD0 $diD0 [lindex $l 1]
            set prevD0 $diD0
        }
        if {$diD1 != $prevD1} {
            if {$elemD1 != {}} {
		lappend elemD1 $last
                lappend retD1 $elemD1
                set elemD1 [list]
            }
            lappend elemD1 $diD1 [lindex $l 1]
            set prevD1 $diD1
        }
	set last [lindex $l 2]
    }
    lappend elemD0 $last
    lappend elemD1 $last
    lappend retD0 $elemD0
    lappend retD1 $elemD1
    return [list $retD0 $retD1]
}



#######################
# intégrale partielle #
#######################

proc icount {a b} {
    switch $a {
        e { 
            switch $b {
                e {return 0}
                ne {return 1}
                n {return 2}
                se {return -1}
                s {return -2}
                default {return -code error "icount $a $b interdit" 
                }
            }
        }
        ne { 
            switch $b {
                ne {return 0}
                n {return 1}
                e {return -1}
                default {return -code error "icount $a $b interdit" 
                }
            }
        }
        n { 
            switch $b {
                n {return 0}
                nw {return 1}
                w {return 2}
                ne {return -1}
                e {return -2}
                default {return -code error "icount $a $b interdit" 
                }
            }
        }
        nw { 
            switch $b {
                nw {return 0}
                w {return 1}
                n {return -1}
                default {return -code error "icount $a $b interdit" 
                }
            }
        }
        w { 
            switch $b {
                w {return 0}
                sw {return 1}
                s {return 2}
                nw {return -1}
                n {return -2}
                default {return -code error "icount $a $b interdit" 
                }
            }
        }
        sw { 
            switch $b {
                sw {return 0}
                s {return 1}
                w {return -1}
                default {return -code error "icount $a $b interdit" 
                }
            }
        }
        s { 
            switch $b {
                s {return 0}
                se {return 1}
                e {return 2}
                sw {return -1}
                w {return -2}
                default {return -code error "icount $a $b interdit" 
                }
            }
        }
        se { 
            switch $b {
                se {return 0}
                e {return 1}
                s {return -1}
                default {return -code error "icount $a $b interdit" 
                }
            }
        }
        default {return -code error "icount $a ... inattendu"}
    }
}

############################################
# Calcul de l'intégrale de "f" sur un côté #
############################################

proc nzx {y x1 x2} {
    set tout [sspx $y $x1 $x2]
    set tot 0
    set prev [quadrant [f $x1 $y]]
    foreach t $tout {
        # puts stderr $t
        incr tot [icount $prev [lindex $t 0]]
        set prev [lindex $t 0]
    }
    incr tot [icount $prev [quadrant [f $x2 $y]]]
    return $tot
}

proc nzy {x y1 y2} {
    set tout [sspy $x $y1 $y2]
    set tot 0
    set prev [quadrant [f [di interval_d $x] [di interval_d $y1]]]
    foreach t $tout {
        # puts stderr $t
        incr tot [icount $prev [lindex $t 0]]
        set prev [lindex $t 0]
    }
    incr tot [icount $prev [quadrant [f [di interval_d $x] [di interval_d $y2]]]]
    return $tot
}


proc nz {x1 y1 x2 y2 side} {
    switch $side {
        e {
            return [nzy $x2 $y1 $y2]
        }
        n {
            return [nzx $y2 $x2 $x1]
        }
        w {
            return [nzy $x1 $y2 $y1]
        }
        s {
            return [nzx $y1 $x1 $x2]
        }
        default {
            return -code error {side should be e, n, w or s}
        }
    }
}

############################################
# nombre de zéros de "f" dans un rectangle #
############################################

proc nzeros {x1 y1 x2 y2} {

    set tout [concat [sspy $x2 $y1 $y2] [sspx $y2 $x2 $x1] [sspy $x1 $y2 $y1] [sspx $y1 $x1 $x2]]

    set prev [lindex [lindex $tout end] 0]
    set tot 0
    foreach t $tout {
        # puts stderr $t
        incr tot [icount $prev [lindex $t 0]]
        set prev [lindex $t 0]
    }
    set nzeros [expr {$tot/8.}]
#    puts stderr "Il y a $nzeros zéros"
#    return $tout
    
    return $nzeros
}

set HELP(nzerosBis) {
    idem nzeros, en un peu plus compact
}
proc nzerosBis {x1 y1 x2 y2} {
    set tot 0
    incr tot [nzy $x2 $y1 $y2]
    incr tot [nzx $y2 $x2 $x1]
    incr tot [nzy $x1 $y2 $y1]
    incr tot [nzx $y1 $x1 $x2]
    return [expr {$tot/8.0}]
}

proc nzerosTer {z} {
    set x [scplxi xy_re $z]
    set y [scplxi xy_im $z]
    set x1 [di inf $x]
    set x2 [di sup $x]
    set y1 [di inf $y]
    set y2 [di sup $y]

    puts stderr "$x1 $y1 $x2 $y2 -> [nzerosBis $x1 $y1 $x2 $y2]"

    set e [nzy $x2 $y1 $y2]
    set n [nzx $y2 $x2 $x1]
    set w [nzy $x1 $y2 $y1]
    set s [nzx $y1 $x1 $x2]
    return [expr {($e + $n + $w + $s)/8.0}]
}

#####################
# Dérivée sur carré #
#####################

set INFO {
    f' ~= (fne - fnw)/dx 
       ~= (fse - fsw)/dx
       ~= (fne - fse)/dy
       ~= (fnw - fsw)/dy
    
    ze = (zne/fne - zse/fse)/(1/fne - 1/fse)
    zn = (zne/fne - znw/fnw)/(1/fne - 1/fnw)
    zw = (znw/fnw - zsw/fsw)/(1/fnw - 1/fsw)
    zs = (zse/fse - zsw/fsw)/(1/fse - 1/fsw)
}

proc newz {x1 y1 x2 y2} {
    set zne [scplxi xy_new $x2 $y2]
    set znw [scplxi xy_new $x1 $y2]
    set zsw [scplxi xy_new $x1 $y1]
    set zse [scplxi xy_new $x2 $y1]
    set ifne [scplxi xy_inv [f $x2 $y2]]
    set ifnw [scplxi xy_inv [f $x1 $y2]]
    set ifsw [scplxi xy_inv [f $x1 $y1]]
    set ifse [scplxi xy_inv [f $x2 $y1]]
    set ze [scplxi xy_div [scplxi xy_sub [scplxi xy_mul $zne $ifne] [scplxi xy_mul $zse $ifse]] [scplxi xy_sub $ifne $ifse]]
    set zn [scplxi xy_div [scplxi xy_sub [scplxi xy_mul $znw $ifnw] [scplxi xy_mul $zne $ifne]] [scplxi xy_sub $ifnw $ifne]]
    set zw [scplxi xy_div [scplxi xy_sub [scplxi xy_mul $zsw $ifsw] [scplxi xy_mul $znw $ifnw]] [scplxi xy_sub $ifsw $ifnw]]
    set zs [scplxi xy_div [scplxi xy_sub [scplxi xy_mul $zse $ifse] [scplxi xy_mul $zsw $ifsw]] [scplxi xy_sub $ifse $ifsw]]
    set zd1 [scplxi xy_div [scplxi xy_sub [scplxi xy_mul $zne $ifne] [scplxi xy_mul $zsw $ifsw]] [scplxi xy_sub $ifne $ifsw]]
    set zd2 [scplxi xy_div [scplxi xy_sub [scplxi xy_mul $znw $ifnw] [scplxi xy_mul $zse $ifse]] [scplxi xy_sub $ifnw $ifse]]
    #puts stderr "ze  $ze"
    #puts stderr "zn  $zn"
    #puts stderr "zw  $zw"
    #puts stderr "zs  $zs"
    #puts stderr "zd1 $zd1"
    #puts stderr "zd2 $zd2"
    return [list $ze $zn $zw $zs $zd1 $zd2]
}

##################
# Tri de racines #
##################

proc compareracines {r1 r2} {
    # racine : {commentaire {nracines zbox}}
    set z1 [lindex [lindex $r1 1] 1]
    set z2 [lindex [lindex $r2 1] 1]
    set x1 [di mid [scplxi xy_re $z1]]
    set x2 [di mid [scplxi xy_re $z2]]
    set y1 [di mid [scplxi xy_im $z1]]
    set y2 [di mid [scplxi xy_im $z2]]

    set q1 [expr {abs($x1) > abs($y1)}]
    set q2 [expr {abs($x2) > abs($y2)}]

    if {$q1 && !$q2} {
        # 1 plutôt réel, 2 plutôt imaginaire -> 1<2
        set ret -1
    } elseif {!$q1 && $q2} {
        # 2 plutôt réel, 1 plutôt imaginaire -> 2<1
        set ret 1
    } else {
        # en premier les x grands
        # en dernier les y grands
        set dx [expr {$x2 - $x1}]
        set dy [expr {$y1 - $y2}]
        if {$q1} {
            # plutôt réels
            if {$dx != 0} {
                set ret $dx
            } else {
                set ret $dy
            }
        } else {
            if {$dy != 0} {
                set ret $dy
            } else {
                set ret $dx
            }
        }
    }
    if {$ret < 0} {set ret -1} elseif {$ret > 0} {set ret 1} else {set ret 0}
    # puts stderr "\"$ret\" $r1 $r2"
    return $ret
}

#######################
# Recherche de racine #
#######################

proc nextrac {z} {
    set x [scplxi xy_re $z]
    set y [scplxi xy_im $z]
    set x1 [di inf $x]
    set x2 [di sup $x]
    set y1 [di inf $y]
    set y2 [di sup $y]
    set n [nzerosBis $x1 $y1 $x2 $y2]
    if {int($n) != 1} {
        return -code error "$n racines"
    }
    set ll [newz $x1 $y1 $x2 $y2]
    set h [lindex $ll 0]
    foreach l [lrange $ll 1 end] {
        set h [scplxi xy_ih $h $l]
    }
    if {[scplxi xy_sp $h $z]} {
        return {}
    }
    set h [scplxi xy_ix $h $z]
    return $h
}

proc nextracB {z} {

    set x [scplxi xy_re $z]
    set y [scplxi xy_im $z]
    set x1 [di inf $x]
    set x2 [di sup $x]
    set y1 [di inf $y]
    set y2 [di sup $y]
    
    set fe [f $x2 $y]
    set fn [f $x $y2]
    set fw [f $x1 $y]
    set fs [f $x $y1]
    set mfe [scplxi xy_module $fe]
    set mfn [scplxi xy_module $fn]
    set mfw [scplxi xy_module $fw]
    set mfs [scplxi xy_module $fs]
    set magfe [di mag $mfe]
    set magfn [di mag $mfn]
    set magfw [di mag $mfw]
    set magfs [di mag $mfs]
   # set migfe [di mig $mfe]
   # set migfn [di mig $mfn]
   # set migfw [di mig $mfw]
   # set migfs [di mig $mfs]
    
    set choix {}
    set mag $magfe
    set choix e
    if {$magfn < $mag} {
        set choix n
        set mag $magfn
    }
    if {$magfw < $mag} {
        set choix w
        set mag $magfw
    }
    if {$magfs < $mag} {
        set choix s
    }
    unset mag

    switch $choix {
        e {
            set za [scplxi xy_new $x2 $y1]
            set zb [scplxi xy_new $x2 $y2]
        }
        n {
            set za [scplxi xy_new $x2 $y2]
            set zb [scplxi xy_new $x1 $y2]
        }
        w {
            set za [scplxi xy_new $x1 $y2]
            set zb [scplxi xy_new $x1 $y1]
        }
        s {
            set za [scplxi xy_new $x1 $y1]
            set zb [scplxi xy_new $x2 $y1]
        }
        default {
            return -code error "Erreur de switch"
        }
    }
    
    
    set fa [fz $za]
    set fb [fz $zb]
    set scplxi_zero [scplxi xy_new 0 0]

    if {[scplxi xy_sp $fa $scplxi_zero]} {
        return -code error "Zéro dans le coin $za"
    }
    if {[scplxi xy_sp $fb $scplxi_zero]} {
        return -code error "Zéro dans le coin $zb"
    }
    
    set ifa [scplxi xy_inv $fa]
    set ifb [scplxi xy_inv $fb]
    
    set h [scplxi xy_div [scplxi xy_sub [scplxi xy_mul $za $ifa] [scplxi xy_mul $zb $ifb]] [scplxi xy_sub $ifa $ifb]]

    if {[scplxi xy_sp $h $z]} {
        return {}
    }
    set h [scplxi xy_ix $h $z]
    if {[scplxi xy_isempty $h]} {
        return {}
    }

    return $h
}

##########################################
# Découpages de rectangles basés sur "f" # 
##########################################


set HELP(splitbox) {
    - Découpe en 4 le rectangle $z 
    - Retourne une liste de 4 éléments "$nzeros z"
    - Pas robuste s'il y a un zéro sur un segment
}
proc splitbox {z} {
    set x [scplxi xy_re $z]
    set y [scplxi xy_im $z]
    set x1 [di inf $x]
    set x2 [di sup $x]
    set y1 [di inf $y]
    set y2 [di sup $y]

    set xx [di mid $x]
    set yy [di mid $y]

    set nxnw [nzx $y2 $x1 $xx]
    set nxne [nzx $y2 $xx $x2]
    set nxcw [nzx $yy $x1 $xx]
    set nxce [nzx $yy $xx $x2]
    set nxsw [nzx $y1 $x1 $xx]
    set nxse [nzx $y1 $xx $x2]

    set nysw [nzy $x1 $y1 $yy]
    set nynw [nzy $x1 $yy $y2]
    set nysc [nzy $xx $y1 $yy]
    set nync [nzy $xx $yy $y2]
    set nyse [nzy $x2 $y1 $yy]
    set nyne [nzy $x2 $yy $y2]

    set ne [expr {($nxce + $nyne - $nxne - $nync)/8.0}]
    set nw [expr {($nxcw + $nync - $nxnw - $nynw)/8.0}]
    set sw [expr {($nxsw + $nysc - $nxcw - $nysw)/8.0}]
    set se [expr {($nxse + $nyse - $nxce - $nysc)/8.0}]
    
    set boites [list]
    if {$ne != 0.0} {
        lappend boites [list $ne [scplxi xy_new [list $xx $x2] [list $yy $y2]]]
    }
    if {$nw != 0.0} {
        lappend boites [list $nw [scplxi xy_new [list $x1 $xx] [list $yy $y2]]]
    }
    if {$sw != 0.0} {
        lappend boites [list $sw [scplxi xy_new [list $x1 $xx] [list $y1 $yy]]]
    }
    if {$se != 0.0} {
        lappend boites [list $se [scplxi xy_new [list $xx $x2] [list $y1 $yy]]]
    }

    return $boites
}

proc splitboxv {z} {
    set x [scplxi xy_re $z]
    set y [scplxi xy_im $z]
    set x1 [di inf $x]
    set x2 [di sup $x]
    set y1 [di inf $y]
    set y2 [di sup $y]

    set xx [di mid $x]

    set nxnw [nzx $y2 $x1 $xx]
    set nxne [nzx $y2 $xx $x2]
    set nxsw [nzx $y1 $x1 $xx]
    set nxse [nzx $y1 $xx $x2]

    set nyw [nzy $x1 $y1 $y2]
    set nyc [nzy $xx $y1 $y2]
    set nye [nzy $x2 $y1 $y2]

    set w [expr {($nxsw + $nyc - $nxnw - $nyw)/8.0}]
    set e [expr {($nxse + $nye - $nxne - $nyc)/8.0}]
    
    set boites [list]
    if {$w != 0.0} {
        lappend boites [list $w [scplxi xy_new [di interval_d_d $x1 $xx] [di interval_d_d $y1 $y2]]]
    }
    if {$e != 0.0} {
        lappend boites [list $e [scplxi xy_new [list $xx $x2] [list $y1 $y2]]]
    }

    return $boites
}

proc splitboxh {z} {
    set x [scplxi xy_re $z]
    set y [scplxi xy_im $z]
    set x1 [di inf $x]
    set x2 [di sup $x]
    set y1 [di inf $y]
    set y2 [di sup $y]

    set yy [di mid $y]

    set nxn [nzx $y2 $x1 $x2]
    set nxc [nzx $yy $x1 $x2]
    set nxs [nzx $y1 $x1 $x2]

    set nysw [nzy $x1 $y1 $yy]
    set nynw [nzy $x1 $yy $y2]
    set nyse [nzy $x2 $y1 $yy]
    set nyne [nzy $x2 $yy $y2]

    set n [expr {($nxc + $nyne - $nxn - $nynw)/8.0}]
    set s [expr {($nxs + $nyse - $nxc - $nysw)/8.0}]
    
    set boites [list]
    if {$s != 0.0} {
        lappend boites [list $s [scplxi xy_new [list $x1 $x2] [list $y1 $yy]]]
    }
    if {$n != 0.0} {
        lappend boites [list $n [scplxi xy_new [list $x1 $x2] [list $yy $y2]]]
    }

    return $boites
}


############################################################
# Recherche de rectangles contenant un zéro, basée sur "f" #
############################################################


proc recursplit {netz args} {

    if {[info level] >= 200} {
        puts stderr "[info level] LEVEL RETURN $netz"
        return [list [list L $netz]]
    }

    set n [lindex $netz 0]

    if {$n == 0} {
        return {}
    }
    if {$n == 1 && $args == "-box1"} {
        return [list [list ONE $netz]]
    }

    set z [lindex $netz 1]
    set x [scplxi xy_re $z]
    set y [scplxi xy_im $z]

    set dx [di wid $x]
    set dy [di wid $y]

    set donev 0
    set doneh 0
    set err 0
    if {$dx > 2*$dy} {
        set donev 1
        set err [catch {splitboxv $z} zr]
        if {$err} {
            puts stderr "    ERROR in splitboxv $z -> $zr"
        } else {
            puts stderr "    OK splitboxv $z"
        }
    }
    if {!$donev && $dy > 2*$dx} {
        set doneh 1
        set err [catch {splitboxh $z} zr]
        if {$err} {
            puts stderr "    ERROR in splitboxh $z -> $zr"
        } else {
            puts stderr "    OK splitboxh $z"
        }
        if {$err && !$donev} {
            set donev 1
            set err [catch {splitboxv $z} zr]
            if {$err} {
                puts stderr "    ERROR in splitboxv $z -> $zr"
            } else {
                puts stderr "    OK splitboxv $z"
            }
        }
    }
    if {!$donev && !$doneh} {
        set err [catch {splitbox $z} zr]
        if {$err} {
            puts stderr "    ERROR in splitbox $z -> $zr"
        } else {
            puts stderr "    OK splitbox $z"
        }
        if {$err} {
            set err [catch {splitboxh $z} zr]
            if {$err} {
                puts stderr "    ERROR in splitboxh $z -> $zr"
            } else {
                puts stderr "    OK splitboxh $z"
            }
            if {$err} {
                set err [catch {splitboxv $z} zr]
                if {$err} {
                    puts stderr "    ERROR in splitboxv $z -> $zr"
                } else {
                    puts stderr "    OK splitbov $z"
                }
            }
        }
    }
    if {$err} {
        puts stderr "recursplit: $zr"
        puts stderr "[info level] RETURN $zr $netz"
        return [list [list "E $zr" $netz]]
    }
    puts stderr "[info level] zr = \"$zr\""
    set ret [list]
    foreach l $zr {
        set ret [concat $ret [recursplit $l $args]]
    } 
    # puts stderr "[info level] NORMAL RETURN \"$ret\""
    return $ret
}

proc fulldoz {z} {
    set n [nzerosTer $z]
    puts stderr "$n zeros"
    return [recursplit [list $n $z] -box1]
}

proc fulldo {x1 y1 x2 y2} {
    set z [scplxi xy_new [di interval_d_d $x1 $x2] [di interval_d_d $y1 $y2]]
    return [lsort -command compareracines [fulldoz $z]]
}


#########################################################




proc newton {z} {
    set x [scplxi xy_re $z]
    set y [scplxi xy_im $z]
    set x1 [di inf $x]
    set x2 [di sup $x]
    set y1 [di inf $y]
    set y2 [di sup $y]
    set zne [scplxi xy_new $x2 $y2]
    set znw [scplxi xy_new $x1 $y2]
    set zsw [scplxi xy_new $x1 $y1]
    set zse [scplxi xy_new $x2 $y1]
    set zne [scplxi xy_sub $zne [fD0onD1 $zne]]
    set znw [scplxi xy_sub $znw [fD0onD1 $znw]]
    set zsw [scplxi xy_sub $zsw [fD0onD1 $zsw]]
    set zse [scplxi xy_sub $zse [fD0onD1 $zse]]
    set nz [scplxi xy_ih [scplxi xy_ih $zne $znw] [scplxi xy_ih $zsw $zse]]
    # ou      if {![scplxi xy_sb $nz $z]}
    if {[scplxi xy_sb $z $nz]} {
        return {}
    } else {
        return [scplxi xy_ix $nz $z]
    }
}

proc moy {a b} {
    return [expr {0.5*($a+$b)}]
}


#####################
# Suivis de vallées #
#####################

# La dérivée n'est pas utilisée : gaspillage
proc onx {q y xs xe} {
    # test perte de temps
    set qs [lindex [quadrantsD0D1 [scplxi xy_new [di interval_d $xs] [di interval_d $y]]] 0]
    if {$qs != $q} {
        return -code error "BadStart \"$qs\" should be \"$q\""
    }

    set again 1
    while {$again} {
        if {$xs <= $xe} {
            set xa $xs
            set xb $xe
        } else {
            set xa $xe
            set xb $xs
        }
        set qs [lindex [quadrantsD0D1 [scplxi xy_new [di interval_d_d $xa $xb] [di interval_d $y]]] 0]
        # puts stderr [list $qs $xs $xe]
        if {$qs == $q} {
            set ret $xe
            set again 0
        } else {
            set xx [moy $xs $xe]
            if {$xx == $xs || $xx == $xe} {
                set ret {}
                set again 0
            } else {
                set xe $xx
            }
        }
    }
    return $ret
}

# La dérivée n'est pas utilisée : gaspillage
proc ony {q x ys ye} {
    # test perte de temps
    set qs [lindex [quadrantsD0D1 [scplxi xy_new [di interval_d $x] [di interval_d $ys]]] 0]
    if {$qs != $q} {
        return -code error "BadStart \"$qs\" should be \"$q\""
    }

    set again 1
    while {$again} {
        if {$ys <= $ye} {
            set ya $ys
            set yb $ye
        } else {
            set ya $ye
            set yb $ys
        }
        set qs [lindex [quadrantsD0D1 [scplxi xy_new [di interval_d $x] [di interval_d_d $ya $yb]]] 0]
        # puts stderr [list $qs $ys $ye]
        if {$qs == $q} {
            set ret $ye
            set again 0
        } else {
            set yy [moy $ys $ye]
            if {$yy == $ys || $yy == $ye} {
                set ret {}
                set again 0
            } else {
                set ye $yy
            }
        }
    }
    return $ret
}

# zon = ne nw sw se
proc valley {x1 y1 x2 y2 zon x y prev args} {
    set z [scplxi xy_new [di interval_d $x] [di interval_d $y]]
    set f [fD0D1 $z]
    set f0 [lindex $f 0]
    set f1 [lindex $f 1]
    set dz [scplxi xy_neg [scplxi xy_div $f0 $f1]]
    set qdz [quadrant16 $dz]
    set qf [quadrant16 $f0]
    if {[string length $qf] == 2} {
        set mf $qf
        set ef {}
    } elseif {[string length $qf] == 3} {
        set mf [string range $qf 1 2]
        switch $qf {
            ene {set ef right}
            nne {set ef left}
            nnw {set ef right}
            wnw {set ef left}
            wsw {set ef right}
            ssw {set ef left}
            sse {set ef right}
            ese {set ef left}
            default {return -code error "Programming error, qf = \"$qz\""}
        }
    } else {
        set mf BAD
    }
    if {$mf != $zon} {
        return -code error "Mauvais départ pour \"valley $zon ...\"" 
    }
    if {[string length $qdz] == 2} {
        set mdz $qdz
        set edz {}
        set notDone 1
    } elseif {[string length $qdz] == 3} {
        set mdz [string range $qdz 1 2]
        set edz [string range $qdz 0 0]
        set notDone 1
    } else {
        set dir $qdz
        set notDone 0
    }
    if {$notDone} {
        if {$ef == {}} {
            # pas d'écart à rattraper
            if {$edz != {}} {
                set dir $edz
            } else {
                set dir [string index $mdz 0]
            }
        } else {
            # écart à rattraper
            switch $mdz+$ef {
                ne+right {set dir e; if {$prev == "w"} {set dir n}}
                ne+left {set dir n; if {$prev == "s"} {set dir e}}
                nw+right {set dir n; if {$prev == "s"} {set dir w}}
                nw+left {set dir w; if {$prev == "e"} {set dir n}}
                sw+right {set dir w; if {$prev == "e"} {set dir s}}
                sw+left {set dir s; if {$prev == "n"} {set dir w}}
                se+right {set dir s; if {$prev == "n"} {set dir e}}
                se+left {set dir e; if {$prev == "w"} {set dir s}}
                default {
                    return -code error "Programming error mdz+ef = \"$mdz+$ef\""
                }
            }
        }
    }
    # puts stderr [list args $args]
    if {[lindex $args 0] == "-step"} {
        set step [lindex $args 1]
        set xinf [expr {$x-$step}]
        set xsup [expr {$x+$step}]
        set yinf [expr {$y-$step}]
        set ysup [expr {$y+$step}]
    } else {
        set xinf $x1
        set xsup $x2
        set yinf $y1
        set ysup $y2
    }
    switch $dir {
        e {
            set x [onx $zon $y $x $xsup]
            if {$x == {}} {
                return {}
            }
        }
        n {
            set y [ony $zon $x $y $ysup]
            if {$y == {}} {
                return {}
            }
        }
        w {
            set x [onx $zon $y $x $xinf]
            if {$x == {}} {
                return {}
            }
        }
        s {
            set y [ony $zon $x $y $yinf]
            if {$y == {}} {
                return {}
            }
        }
        default {
            return -code error "Programming error dir = \"$dir\""
        }
    }
    return [list $x $y $dir]
}

# On a un cadre suffisamment grand pour garantir une succession triginométrique positive
proc startvalleys {x1 y1 x2 y2} {
    set all [list]
    foreach l [sspy $x2 $y1 $y2] {lappend all [list e [lindex $l 0] [lindex $l 3] [lindex $l 6] [lindex $l end]]}
    foreach l [sspx $y2 $x2 $x1] {lappend all [list n [lindex $l 0] [lindex $l 3] [lindex $l 6] [lindex $l end]]}
    foreach l [sspy $x1 $y2 $y1] {lappend all [list w [lindex $l 0] [lindex $l 3] [lindex $l 6] [lindex $l end]]}
    foreach l [sspx $y1 $x1 $x2] {lappend all [list s [lindex $l 0] [lindex $l 3] [lindex $l 6] [lindex $l end]]}
    set starts [list]
    set qp [lindex [lindex $all end] 1]
    foreach l $all {
        # puts stderr $l
        set q [lindex $l 1]
        if {$q == $qp} continue
        switch $q {
            e {
                switch $qp {
                    s {lappend starts [list se [lindex $l 0] [lindex $l 2] [lindex $l 3]]}
                    se {}
                    default {return -code error "succession \"$qp\" \"$q\" inattendue"}
                }
            }
            ne {
                lappend starts [list $q [lindex $l 0] [lindex $l 2] [moy [lindex $l 3] [lindex $l 4]]]
            }
            n {
                switch $qp {
                    e {lappend starts [list ne [lindex $l 0] [lindex $l 2] [lindex $l 3]]}
                    ne {}
                    default {return -code error "succession \"$qp\" \"$q\" inattendue"}
                }
            }
            nw {
                lappend starts [list $q [lindex $l 0] [lindex $l 2] [moy [lindex $l 3] [lindex $l 4]]]
            }
            w {
                switch $qp {
                    n {lappend starts [list nw [lindex $l 0] [lindex $l 2] [lindex $l 3]]}
                    nw {}
                    default {return -code error "succession \"$qp\" \"$q\" inattendue"}
                }
            }
            sw {
                lappend starts [list $q [lindex $l 0] [lindex $l 2] [moy [lindex $l 3] [lindex $l 4]]]
            }
            s {
                switch $qp {
                    w {lappend starts [list sw [lindex $l 0] [lindex $l 2] [lindex $l 3]]}
                    sw {}
                    default {return -code error "succession \"$qp\" \"$q\" inattendue"}
                }
            }
            se {
                lappend starts [list $q [lindex $l 0] [lindex $l 2] [moy [lindex $l 3] [lindex $l 4]]]
            }
            default {return -code error "q \"$q\" inattendu"}
        }
        set qp $q
    }
    return $starts
}

proc displayvalleys {x1 y1 x2 y2 ll args} {
    set log(ne) [open ~/Z/ne.dat w]
    set log(nw) [open ~/Z/nw.dat w]
    set log(sw) [open ~/Z/sw.dat w]
    set log(se) [open ~/Z/se.dat w]
    set fins [list]
    foreach l $ll {
        # puts $l
        set zon [lindex $l 0]
        set side [lindex $l 1]
        switch $side {
            e {
                set x [lindex $l 2]
                set y [lindex $l 3]
                set prev w
            }
            n {
                set x [lindex $l 3]
                set y [lindex $l 2]
                set prev s
            }
            w {
                set x [lindex $l 2]
                set y [lindex $l 3]
                set prev e
            }
            s {
                set x [lindex $l 3]
                set y [lindex $l 2]
                set prev n
            }
            default {return -code error "Side \"$side\" inattendu"}
        }
        puts $log($zon) {}
        puts $log($zon) "$x $y"
        set again 1000
        while {$again} {
            set xy [eval [list valley $x1 $y1 $x2 $y2 $zon $x $y $prev] $args]
            if {$xy == {}} {
                break
            }
            incr again -1
            set x [lindex $xy 0]
            set y [lindex $xy 1]
            set prev [lindex $xy 2]
            puts $log($zon) "$x $y"
            # puts stderr "*********** $x $y"
            flush $log($zon)
        }
        lappend fins [list $zon $x $y]
        puts stderr "$zon $x $y"
    }
    close $log(ne)
    close $log(nw)
    close $log(sw)
    close $log(se)
    return $fins
}

###############################################################
# Suivis de vallée, peut être pas optimaux à cause de fD0onD1 #
###############################################################

proc onxN {q y xs xe} {
    # test perte de temps
    set qs [quadrant [fD0onD1 [scplxi xy_new [di interval_d $xs] [di interval_d $y]]]]
    if {$qs != $q} {
        return -code error "BadStart \"$qs\" should be \"$q\""
    }

    set again 1
    while {$again} {
        if {$xs <= $xe} {
            set xa $xs
            set xb $xe
        } else {
            set xa $xe
            set xb $xs
        }
        set qs [quadrant [fD0onD1 [scplxi xy_new [di interval_d_d $xa $xb] [di interval_d $y]]]]
        # puts stderr [list $qs $xs $xe]
        if {$qs == $q} {
            set ret $xe
            set again 0
        } else {
            set xx [moy $xs $xe]
            if {$xx == $xs || $xx == $xe} {
                set ret {}
                set again 0
            } else {
                set xe $xx
            }
        }
    }
    return $ret
}

proc onyN {q x ys ye} {
    # test perte de temps
    set qs [quadrant [fD0onD1 [scplxi xy_new [di interval_d $x] [di interval_d $ys]]]]
    if {$qs != $q} {
        return -code error "BadStart \"$qs\" should be \"$q\""
    }

    set again 1
    while {$again} {
        if {$ys <= $ye} {
            set ya $ys
            set yb $ye
        } else {
            set ya $ye
            set yb $ys
        }
        set qs [quadrant [fD0onD1 [scplxi xy_new [di interval_d $x] [di interval_d_d $ya $yb]]]]
        # puts stderr [list $qs $ys $ye]
        if {$qs == $q} {
            set ret $ye
            set again 0
        } else {
            set yy [moy $ys $ye]
            if {$yy == $ys || $yy == $ye} {
                set ret {}
                set again 0
            } else {
                set ye $yy
            }
        }
    }
    return $ret
}

# normalisation D0/D1
proc valleyN {x1 y1 x2 y2 zon x y prev args} {
    set z [scplxi xy_new [di interval_d $x] [di interval_d $y]]
    set f [fD0D1 $z]
    set f0 [lindex $f 0]
    set f1 [lindex $f 1]
    set dzNeg [scplxi xy_div $f0 $f1]
    set qdz [quadrant16 $dzNeg]
    if {[string length $qdz] == 2} {
        set mdz $qdz
        set edz right ;# au hasard
        set notDone 1
    } elseif {[string length $qdz] == 3} {
        set mdz [string range $qdz 1 2]
        set edz [string range $qdz 0 0]
        set notDone 1
        switch $qdz {
            ene {set edz right}
            nne {set edz left}
            nnw {set edz right}
            wnw {set edz left}
            wsw {set edz right}
            ssw {set edz left}
            sse {set edz right}
            ese {set edz left}
            default {return -code error "Programming error, qf = \"$qz\""}
        }
    } else {
        set dir $qdz
        set notDone 0
    }
    if {$mdz != $zon} {
        return -code error "Mauvais départ pour \"valleyN $zon: mdz=\"$mdz\" ...\"" 
    }
    if {$notDone} {
        switch $mdz+$edz {
            ne+right {set dir e; if {$prev == "w"} {set dir n}}
            ne+left {set dir n; if {$prev == "s"} {set dir e}}
            nw+right {set dir n; if {$prev == "s"} {set dir w}}
            nw+left {set dir w; if {$prev == "e"} {set dir n}}
            sw+right {set dir w; if {$prev == "e"} {set dir s}}
            sw+left {set dir s; if {$prev == "n"} {set dir w}}
            se+right {set dir s; if {$prev == "n"} {set dir e}}
            se+left {set dir e; if {$prev == "w"} {set dir s}}
            default {
                return -code error "Programming error mdz+edz = \"$mdz+$edz\""
            }
        }
    }
    if {[lindex $args 0] == "-step"} {
        set step [lindex $args 1]
        set xinf [expr {$x-$step}]
        set xsup [expr {$x+$step}]
        set yinf [expr {$y-$step}]
        set ysup [expr {$y+$step}]
    } else {
        set xinf $x1
        set xsup $x2
        set yinf $y1
        set ysup $y2
    }
    switch $dir {
        e {
            set x [onxN $zon $y $x $xsup]
            if {$x == {}} {
                return {}
            }
        }
        n {
            set y [onyN $zon $x $y $ysup]
            if {$y == {}} {
                return {}
            }
        }
        w {
            set x [onxN $zon $y $x $xinf]
            if {$x == {}} {
                return {}
            }
        }
        s {
            set y [onyN $zon $x $y $yinf]
            if {$y == {}} {
                return {}
            }
        }
        default {
            return -code error "Programming error dir = \"$dir\""
        }
    }
    return [list $x $y $dir]
}

# On a un cadre suffisamment grand pour garantir une succession triginométrique positive
proc startvalleysN {x1 y1 x2 y2} {
    set all [list]
    foreach l [sspyN $x2 $y1 $y2] {lappend all [list e [lindex $l 0] [lindex $l 3] [lindex $l 6] [lindex $l end]]}
    foreach l [sspxN $y2 $x2 $x1] {lappend all [list n [lindex $l 0] [lindex $l 3] [lindex $l 6] [lindex $l end]]}
    foreach l [sspyN $x1 $y2 $y1] {lappend all [list w [lindex $l 0] [lindex $l 3] [lindex $l 6] [lindex $l end]]}
    foreach l [sspxN $y1 $x1 $x2] {lappend all [list s [lindex $l 0] [lindex $l 3] [lindex $l 6] [lindex $l end]]}
    set starts [list]
    set qp [lindex [lindex $all end] 1]
    foreach l $all {
        # puts stderr $l
        set q [lindex $l 1]
        if {$q == $qp} continue
        switch $q {
            e {
                switch $qp {
                    s {lappend starts [list se [lindex $l 0] [lindex $l 2] [lindex $l 3]]}
                    se {}
                    default {return -code error "succession \"$qp\" \"$q\" inattendue"}
                }
            }
            ne {
                lappend starts [list $q [lindex $l 0] [lindex $l 2] [moy [lindex $l 3] [lindex $l 4]]]
            }
            n {
                switch $qp {
                    e {lappend starts [list ne [lindex $l 0] [lindex $l 2] [lindex $l 3]]}
                    ne {}
                    default {return -code error "succession \"$qp\" \"$q\" inattendue"}
                }
            }
            nw {
                lappend starts [list $q [lindex $l 0] [lindex $l 2] [moy [lindex $l 3] [lindex $l 4]]]
            }
            w {
                switch $qp {
                    n {lappend starts [list nw [lindex $l 0] [lindex $l 2] [lindex $l 3]]}
                    nw {}
                    default {return -code error "succession \"$qp\" \"$q\" inattendue"}
                }
            }
            sw {
                lappend starts [list $q [lindex $l 0] [lindex $l 2] [moy [lindex $l 3] [lindex $l 4]]]
            }
            s {
                switch $qp {
                    w {lappend starts [list sw [lindex $l 0] [lindex $l 2] [lindex $l 3]]}
                    sw {}
                    default {return -code error "succession \"$qp\" \"$q\" inattendue"}
                }
            }
            se {
                lappend starts [list $q [lindex $l 0] [lindex $l 2] [moy [lindex $l 3] [lindex $l 4]]]
            }
            default {return -code error "q \"$q\" inattendu"}
        }
        set qp $q
    }
    return $starts
}

proc displayvalleysN {x1 y1 x2 y2 ll args} {
    set log(ne) [open ~/Z/ne.dat w]
    set log(nw) [open ~/Z/nw.dat w]
    set log(sw) [open ~/Z/sw.dat w]
    set log(se) [open ~/Z/se.dat w]
    set fins [list]
    foreach l $ll {
        # puts $l
        set zon [lindex $l 0]
        set side [lindex $l 1]
        switch $side {
            e {
                set x [lindex $l 2]
                set y [lindex $l 3]
                set prev w
            }
            n {
                set x [lindex $l 3]
                set y [lindex $l 2]
                set prev s
            }
            w {
                set x [lindex $l 2]
                set y [lindex $l 3]
                set prev e
            }
            s {
                set x [lindex $l 3]
                set y [lindex $l 2]
                set prev n
            }
            default {return -code error "Side \"$side\" inattendu"}
        }
        puts $log($zon) {}
        puts $log($zon) "$x $y"
        set again 1000
        while {$again} {
            set xy [eval [list valleyN $x1 $y1 $x2 $y2 $zon $x $y $prev] $args]
            if {$xy == {}} {
                break
            }
            incr again -1
            set x [lindex $xy 0]
            set y [lindex $xy 1]
            set prev [lindex $xy 2]
            puts $log($zon) "$x $y"
            # puts stderr "*********** $x $y"
            flush $log($zon)
        }
        lappend fins [list $zon $x $y]
        puts stderr "$zon $x $y"
    }
    close $log(ne)
    close $log(nw)
    close $log(sw)
    close $log(se)
    return $fins
}

#########################
# Essais chronologiques #
#########################

set HELP(préliminaires) {
    f 10 {10 10}
    f 10 {10 10.1}
    f 10 53.125

    f 10 {53.125 56.25}

    splity 10 0 1
    set sp [splity 10 0 200]

    nzeros -100 -20 100 100 ;# 28

    nzeros -2 -20 2 100 ;# 26
    nzeros 2 -20 100 100 ;# 2
    nzeros 2 -20 4 100 ;# 2
    
    nzeros 2 -20 4 50 ;# 2
    nzeros 2 -20 4 25 ;# 0
    # nzeros 2 25 4 50 ;# 2
    nzeros 2 25 4 40 ;# 2
    nzeros 2 25 4 30 ;# 2
    nzeros 2 25 4 27 ;# 1
    # nzeros 2 27 4 30 ;# 1
    nzeros 2 28 4 29 ;# 0
    # nzeros 2 29 4 30 ;# 1
    
    # nzeros -2 -20 2 100 ;# 26
    nzeros -2 -20 2 0 ;# split point 1 0
    nzeros -2 -20 2 10 ;# 5
    nzeros -2 -20 2 -1 ;# 2
    nzeros -2 -1 2 1 ;# 2
    nzeros -2 -0.5 2 0.5 ;# 2
    # nzeros -2 -1 2 -0.5 ;# 0
    # nzeros -2 0.5 2 1 ;# 0
    nzeros -2 -0.5 -0.5 0.5 ;# 1
    nzeros -0.5 -0.5 2 0.5 ;# 1
    

    nzeros -2 -20 2 100
    nzeros 2 -20 4 100
    nzeros 4 -20 200 100
    nzeros -200 -20 -2 100
    
    nzeros 2 10 4 100
    nzeros 2 20 4 30
    
    nzeros 2 25 4 27
    nzeros 2 28 4 30
    
    nzeros -2 -20 2 50
    nzeros -2 50 2 100



    nzeros 2 29 4 30
    nzerosBis 2 29 4 30

    nz 2 29 4 30 e
    nz 2 29 4 30 n
    nz 2 29 4 30 w
    nz 2 29 4 30 s

    set x1 2
    set x2 4
    set y1 29
    set y2 30


    q {3.5 4} {29.6 30} se
    
 
   
    nzerosBis 2 29 4 30
    set ll [newz 2 29 4 30] ; foreach l $ll {puts $l}
    

    nzerosBis 2 29 2.3 29.4
    set ll [newz 2 29 2.3 29.4] ; foreach l $ll {puts $l}

    nzerosBis 2.18 29.31 2.19 29.32
    set ll [newz 2.18 29.31 2.19 29.32] ; foreach l $ll {puts $l}
    
    set z [scplxi xy_new {2.18 2.19} {29.31 29.32}]
    set z [nextrac $z]

    nzerosBis 2.18365925772 29.3108391983 2.18366020568 29.3108403068

    set z [lindex [lindex [splitbox $z] 0] 1]
    set ll [lindex $ll 0]
    set ll [splitbox [lindex $ll 1] [lindex $ll 2] [lindex $ll 3] [lindex $ll 4]]

    set ll [list 1.0 2.18365973194 29.3108397523 2.183659732 29.3108397524]
    set ll [splitbox [lindex $ll 1] [lindex $ll 2] [lindex $ll 3] [lindex $ll 4]]
    set ll [lindex $ll 0]
    set ll [splitboxv [lindex $ll 1] [lindex $ll 2] [lindex $ll 3] [lindex $ll 4]]
    set ll [splitboxh [lindex $ll 1] [lindex $ll 2] [lindex $ll 3] [lindex $ll 4]]

    
    set z [scplxi xy_new {-99.2 100} {1.1 200}]

    set z [scplxi xy_new {-2 6} {0.1 200}]
    set z [scplxi xy_new {-2 6} {0.1 20}]


    set ll [fulldo -2 0.1 10 50]

    set z [lindex [lindex $ll 0] 1]
    set z [lindex [lindex [fulldoz $z] 0] 1]
    xy {0.0023154921859713795 0.0023154921861419098} {7.9126742641098549 7.9126742641105636}
    set x [scplxi xy_re $z]
    set y [scplxi xy_im $z]
    set x1 [di inf $x]
    set x2 [di sup $x]
    set y1 [di inf $y]
    set y2 [di sup $y]

    set yy [di mid $y]
    set nxc [nzx $yy $x1 $x2] ;# too many nested calls to Tcl_EvalObj (infinite loop?) (precision limit)
    nzx 7.9126742641102092 0.0023154921859713795 0.0023154921861419098
    splitx 7.9126742641102092 0.0023154921859713795 0.0023154921861419098
    splitx 7.9126742641102092 0.0023154921859846419 0.0023154921859846423
    f 0.0023154921859846419 7.9126742641102092                         ;# {7.6261130743660033e-10 1.2623104339581914e-08} {-3.8717189454473555e-09 8.3905433712061495e-09}
    f 0.0023154921859846423 7.9126742641102092                         ;# {-7.7534423326142132e-11 1.262492332898546e-08} {-4.2755345930345356e-09 8.4701241576112807e-09}
    f {0.0023154921859846419 0.0023154921859846423} 7.9126742641102092 ;# {-7.7534423326142132e-11 1.262492332898546e-08} {-4.2755345930345356e-09 8.4701241576112807e-09}
    q 0.0023154921859846423 7.9126742641102092    ;# -> 0

package require fidevFloating
floatToBinar  0.0023154921859846419 ;#  0 0010111101111111000001100110110100000111011101110101 01111110110
set x [binarToFloat 0 0010111101111111000001100110110100000111011101110110 01111110110]

proc qqx {s m e y} {
    set x [binarToFloat $s $m $e]
    return [list [q $x $y] $x $y]
}

    q 0.0023154921859846419 7.9126742641102092    ;# -> e
    q 0.0023154921859846423 7.9126742641102092    ;# -> 0
    q 0.0023154921859846428 7.9126742641102092    ;# -> 0

    q 0.002315492186 7.9126742641102092    ;# -> 0
    q 0.002315492197 7.9126742641102092    ;# -> sw  


    fulldo 0 1 7 8

    fulldo $x1 $y1 $x2 $y2
    {L {xy {0.0023154921364039183 0.0023154921873356216} {7.9126742640655721 7.9126742641165038}}}

    set ll [fulldo -10 -1 10 100]
    foreach l $ll {puts stderr $l}

    set z [lindex [lindex [lindex $ll 0] 1] 1]

    set ll1 [recursplit [list 1 $z]] ;# {{E precision limit in 1.0979787233085148 0.0099260052978668821} {1.0 {xy {1.0979787233084437 1.0979787233085858} {0.009926005297785423 0.009926005297964835}}}}
    set z [lindex [lindex [lindex $ll1 0] 1] 1]
    
    set z [scplxi xy_new {1 1.1} {0.0001 0.01}] 
    while {[set zr [nextrac $z]] != {}} {
        set z $zr
        puts stderr $z
    }
    set zA $z
    set zB $z

    set z [scplxi xy_new {1 1.1} {0.0001 0.01}] 
    while {[set zr [nextracB $z]] != {}} {
        set z $zr
        puts stderr $z
    }

}

set FIL(2003.02.21.FP) {
    set NOTES {
	- Correction de problèmes graves si tcl_precision!=17 liés
	au passage par une liste et donc par une chaine de caractère
	si on a un simple réel dans SetDiFromAny 
    }
    
    set z {xy {0.0 5.0} {-1.0 5.3125}}

    # Passage de fz z à fz k2

    set ll [fulldo -10000 -2000 100 2000]
    foreach l $ll {puts stderr $l}

    set z [lindex [lindex [lindex $ll 0] 1] 1]

    set z2 {xy -2 0.1}
    set z [scplxi xy_sqrt $z2]
    set kappaz [scplxi xy_mul $k0 $z]
    set func [oplan::modetm $k0 $kx0 $kappaz $eps1 $eps2 $d1 $d2]
    set funcD1 [oplan::modetmD1 $d1 $d2 $eps1 $eps2 $k0 $kx0 [scplxi xy_sqr $kappaz]]

    set z2 {xy {-2.0001 -2} 0.1}
    set z [scplxi xy_sqrt $z2]
    set kappaz [scplxi xy_mul $k0 $z]
    set func [oplan::modetm $k0 $kx0 $kappaz $eps1 $eps2 $d1 $d2]
    set funcD1 [oplan::modetmD1 $d1 $d2 $eps1 $eps2 $k0 $kx0 [scplxi xy_sqr $kappaz]]
    set f0 [lindex $funcD1 0]
    set f1 [lindex $funcD1 1]

    # contrôle 
    set xa 10.0
    set ya 2.0
    set dx 0.001
    set dy 0.01
    set xb [expr {$xa + $dx}]
    set yb [expr {$ya + $dy}]
    set func inv
    set fa [scplxi xy_$func [scplxi xy_new $xa $ya]]
    set fb [scplxi xy_$func [scplxi xy_new $xb $yb]]
    set z [list [scplxi xy_new [di interval_d_d $xa $xb] [di interval_d_d $ya $yb]] [scplxi xy_new 1 0]]
    set f [scplxiD1 $func $z]
    set f0 [lindex $f 0]
    set f1 [lindex $f 1]
    set du [scplxi xy_sub $fb $fa]
    set dv [scplxi xy_mul $f1 [scplxi xy_new $dx $dy]]
    scplxi xy_sb $du $dv

    # contrôle de oplan::modetmD1
    set xa -2.0
    set ya 0.1
    set dx 0.001
    set dy 0.000
    set xb [expr {$xa + $dx}]
    set yb [expr {$ya + $dy}]
    set fa [lindex [oplan::modetmD1 $d1 $d2 $eps1 $eps2 $k0 $kx0 [scplxi xy_new $xa $ya]] 0]
    set fb [lindex [oplan::modetmD1 $d1 $d2 $eps1 $eps2 $k0 $kx0 [scplxi xy_new $xb $yb]] 0]
    set z [scplxi xy_new [di interval_d_d $xa $xb] [di interval_d_d $ya $yb]]
    set f [oplan::modetmD1 $d1 $d2 $eps1 $eps2 $k0 $kx0 $z]
    set f0 [lindex $f 0]
    set f1 [lindex $f 1]
    set du [scplxi xy_sub $fb $fa]
    set dv [scplxi xy_mul $f1 [scplxi xy_new $dx $dy]]
    puts $f0
    puts $f1
    puts $du
    puts $dv
    puts [scplxi xy_sb $du $dv]

    #####################

    set zC {xy -2 0.1}
    fD1onD0 $zC

    set ll [fulldo -10000 -2000 100 2000]
    foreach l $ll {puts stderr $l}

    set zC [lindex [lindex [lindex $ll 0] 1] 1]
    recursplit [list 1 $zC]

    set zC {xy {1.2054587512569985 1.2054587512570687} {0.021797085248964621 0.021797085249075643}}
    fD1onD0 $zC

    set zC {xy 1.2 0.02}
    set dz [fD0onD1 $zC]
    set zC [scplxi xy_sub $zC $dz]

    set zC {xy {-57.8125 100.0} {-2000.0 2000.0}}
    
    fD0onD1 {xy {-57.8125 100} 2000.0}

    fD0D1 {xy {-57.8125 100} 2000.0}

    set x1 1.1
    set x2 1.1
    set y1 0.01
    set y2 0.01
    fD0D1 [scplxi xy_new [di interval_d_d $x1 $x2] [di interval_d_d $y1 $y2]]

    fD1onD0 {xy {-57.8125 0} 2000}
    fD1onD0 {xy {0 100} 2000}
    fD1onD0 {xy {0 50} 2000}
    fD1onD0 {xy {50 100} 2000}
    fD1onD0 {xy 100 {-2000 -1900}}
    fD1onD0 {xy 100 {-1900 -1890}}


    set zC {xy {1.2054587512569985 1.2054587512570687} {0.021797085248964621 0.021797085249075643}}

    # proc fz {zC} {return [lindex [fD0D1 $zC] 1]}

    ##############################
}
    

set FIL(2003.02.24.FP) {

    # recherche grossière des racines
    proc fz {zC} {return [fD0 $zC]}
    set ll [fulldo -10000 -2000 100 2000]
    foreach l $ll {puts stderr $l}
    # 25 zéros
    # choix d'un rectangle
    set n 0
    set rac1 [lindex [lindex [lindex $ll $n] 1] 1] ;# xy {-57.8125 100.0} {-2000.0 2000.0}
    # recherche des zéros de la dérivée
    proc fz {zC} {return [lindex [fD0D1 $zC] 1]}
    set llr1 [fulldo -57.8125 -2000.0 1000 2000.0]
    nzerosTer {xy {-57.8125 100.0} {1. 2000.0}} ;# 0 des deux
    nzerosTer {xy {-57.8125 100.0} {-1 1}} ;# 1 des deux
    nzerosTer {xy {-57.8125 0} {-1 1}} ;# seulement la dérivée
    nzerosTer {xy {0 100} {-1 1}} ;# seulement la fonction
    # Procédure à f(z) ~ z
    proc fz {zC} {return [fD0onD1 $zC]}
    nzerosTer {xy {0 100} {-1 1}} ;# OK
    set x1 0
    set x2 100
    set y1 -1
    set y2 1
    sspy $x2 $y1 $y2 ;# {e x = 100 y = -1 1}
    sspx $y2 $x2 $x1 ;# {e y = 1 x = 100 75.0 50.0 37.5 25.0 18.75 12.5 9.375 6.25 4.6875 3.90625 3.125 2.734375 2.34375 1.953125 1.7578125}
                      # {n y = 1 x = 1.7578125 1.5625 1.3671875 1.171875 0.9765625 0.78125 0.5859375 0.390625 0}
    sspy $x1 $y2 $y1 ;# {n x = 0 y = 1 0.75}
                      # {w x = 0 y = 0.75 0.5 0.0 -0.5 -0.75 -1}
    sspx $y1 $x1 $x2 ;# {w y = -1 x = 0 0.1953125 0.390625 0.5859375}
                      # {s y = -1 x = 0.5859375 0.78125 0.9765625 1.171875 1.3671875 1.5625 1.7578125 1.953125 2.34375 2.734375 3.125}
                      # {e y = -1 x = 3.125 3.515625 3.90625 4.6875 6.25 9.375 12.5 18.75 25.0 37.5 50.0 62.5 75.0 100}
    set x1 0.5859375
    set x2 3.125
    {e x = 3.125 y = -1 -0.5 0.0 1}
    {e y = 1 x = 3.125 2.490234375 2.1728515625 1.85546875}
    {ne y = 1 x = 1.85546875 1.69677734375}
    {n y = 1 x = 1.69677734375 1.5380859375 1.220703125 0.9033203125 0.5859375}
    {n x = 0.5859375 y = 1 0.75 0.625 0.5 0.375}
    {nw x = 0.5859375 y = 0.375 0.3125}
    {w x = 0.5859375 y = 0.3125 0.25 0.0 -0.125 -0.25 -0.375 -0.5 -0.625 -0.75 -0.875}
    {sw x = 0.5859375 y = -0.875 -1}
    {s y = -1 x = 0.5859375 0.74462890625 0.9033203125 1.220703125 1.37939453125 1.5380859375 1.85546875 2.1728515625 2.490234375 2.8076171875}
    {se y = -1 x = 2.8076171875 3.125}
    
    set pasencorebon {
        set z [scplxi xy_new [expr {0.5*($x1+$x2)}] [expr {0.5*($y1+$y2)}]]
        set dz [fD0onD1 $z]
        
        fD0D1 [scplxi xy_new [di interval_d_d $x1 $x2] [di interval_d_d $y1 $y2]]
    }
    set x2 [expr {0.5*(1.85546875 + 1.69677734375)}]
    {s x = 1.776123046875 y = -1 -0.75 -0.5}
    {se x = 1.776123046875 y = -0.5 -0.375 -0.25}
    {e x = 1.776123046875 y = -0.25 0.0 0.25 0.5 0.75}
    {ne x = 1.776123046875 y = 0.75 0.875 1}
    set y1 -0.5
    set y2 0.375
    {e y = 0.375 x = 1.776123046875 1.627349853515625 1.47857666015625}
    {ne y = 0.375 x = 1.47857666015625 1.4041900634765625}
    {n y = 0.375 x = 1.4041900634765625 1.329803466796875 1.2554168701171875 1.1810302734375 1.1066436767578125 1.032257080078125 0.9578704833984375 0.88348388671875 0.8090972900390625 0.734710693359375 0.6603240966796875}
    {nw y = 0.375 x = 0.6603240966796875 0.5859375}

    {w y = -0.5 x = 0.5859375 0.734710693359375 0.8090972900390625}
    {sw y = -0.5 x = 0.8090972900390625 0.88348388671875 0.9578704833984375}
    {s y = -0.5 x = 0.9578704833984375 1.032257080078125 1.1810302734375 1.329803466796875 1.47857666015625 1.627349853515625 1.776123046875}

    set x1 0.9578704833984375
    set x2 1.4041900634765625

    {s x = 1.4041900634765625 y = -0.5 -0.390625 -0.28125 -0.171875}
    {se x = 1.4041900634765625 y = -0.171875 -0.1171875 -0.0625}
    {e x = 1.4041900634765625 y = -0.0625 0.046875 0.15625 0.265625}
    {ne x = 1.4041900634765625 y = 0.265625 0.3203125 0.375}

    {n x = 0.9578704833984375 y = 0.375 0.3203125 0.265625 0.2109375}
    {nw x = 0.9578704833984375 y = 0.2109375 0.18359375 0.15625}
    {w x = 0.9578704833984375 y = 0.15625 0.12890625 0.1015625 0.07421875 0.060546875 0.046875 0.033203125 0.01953125 -0.0078125 -0.021484375 -0.03515625 -0.048828125 -0.0625 -0.076171875 -0.08984375 -0.1171875 -0.14453125 -0.171875 -0.2265625 -0.28125 -0.3359375}
    {sw x = 0.9578704833984375 y = -0.3359375 -0.390625 -0.4453125 -0.5}

    set y1 -0.0625
    set y2 0.15625
    {e y = 0.15625 x = 1.4041900634765625 1.3484001159667969 1.2926101684570312}
    {ne y = 0.15625 x = 1.2926101684570312 1.2647151947021484}
    {n y = 0.15625 x = 1.2647151947021484 1.2368202209472656 1.1810302734375 1.1252403259277344 1.0973453521728516 1.0694503784179688 1.0415554046630859 1.0136604309082031}
    {nw y = 0.15625 x = 1.0136604309082031 0.98576545715332031 0.9578704833984375}

    {w y = -0.0625 x = 0.9578704833984375 0.97181797027587891 0.98576545715332031 0.99971294403076172 1.0136604309082031 1.0276079177856445 1.0415554046630859 1.0555028915405273 1.0694503784179688 1.0973453521728516 1.1252403259277344 1.1531352996826172}
    {s y = -0.0625 x = 1.1531352996826172 1.1810302734375 1.2368202209472656 1.2926101684570312 1.3484001159667969}
    {e y = -0.0625 x = 1.3484001159667969 1.4041900634765625}

    set z [scplxi xy_new [di interval_d_d $x1 $x2] [di interval_d_d $y1 $y2]]

    # méthode de newton
    set max 100
    while {[set nz [newton $z]] != {} && $max > 0} {
        set z $nz
        incr max -1
        puts $z
    }

    xy {1.2054587512569979 1.2054587512570458} {0.021797085249006292 0.021797085249053161}
    xy {1.2054587512569974 1.2054587512570445} {0.021797085249007291 0.02179708524905186}
    xy {1.2054587512569979 1.2054587512570445} {0.021797085249007375 0.021797085249051808}


    set z {xy {0 100} {-1 1}}
    foreach l [concat [ce $z] [cn $z] [cw $z] [cs $z]] {
        puts $l
    }
    e x = 100.0 y = -1.0 1.0
    e y = 1.0 x = 100.0 75.0 50.0 37.5 25.0 18.75 12.5 9.375 6.25 4.6875 3.90625 3.125 2.734375 2.34375 1.953125 1.7578125
    n y = 1.0 x = 1.7578125 1.5625 1.3671875 1.171875 0.9765625 0.78125 0.5859375 0.390625 0.0
    n x = 0.0 y = 1.0 0.75
    w x = 0.0 y = 0.75 0.5 0.0 -0.5 -0.75 -1.0
    w y = -1.0 x = 0.0 0.1953125 0.390625 0.5859375
    s y = -1.0 x = 0.5859375 0.78125 0.9765625 1.171875 1.3671875 1.5625 1.7578125 1.953125 2.34375 2.734375 3.125
    e y = -1.0 x = 3.125 3.515625 3.90625 4.6875 6.25 9.375 12.5 18.75 25.0 37.5 50.0 62.5 75.0 100.0
    
    set x [scplxi xy_re $z]
    set y [scplxi xy_im $z]
    set x1 [di inf $x]
    set x2 1.75
    set y1 [di inf $y]
    set y2 [di sup $y]
    set z [scplxi xy_new [di interval_d_d $x1 $x2] [di interval_d_d $y1 $y2]]
    
    set max 100
    while {[set nz [newton $z]] != {} && $max > 0} {
        set z $nz
        incr max -1
        puts $z
    }
    xy {1.2054587512569979 1.2054587512570434} {0.021797085249007371 0.02179708524905179}
    foreach l [concat [ce $z] [cn $z] [cw $z] [cs $z]] {
        puts $l
    }
    set x [scplxi xy_re $z]
    set y [scplxi xy_im $z]
    
                xy {1.2054587512569979 1.2054587512570434} {0.021797085249007371 0.02179708524905179}
precision limit in  1.2054587512570434 1.2054587512570434   0.021797085249007371 0.021797085249007371
    
    # Certitude 
 
    se: 1.2054587512570456 0.021797085249007371
    sw: 1.2054587512569979 0.021797085249007371
     s: 1.2054587512570207 0.021797085249007371
prec.l:{1.2054587512569983
        1.2054587512569985} 0.021797085249007371 
prec.l:{1.2054587512569983
        1.2054587512569985} 0.0217970852490074   0 0110010100011111100110100001001010111010001000101010 01111111001
     s: {1.2054587512569983
        1.2054587512569985} 0.021797085249007464 0 0110010100011111100110100001001010111010001000100000 01111111001
prec.l.:{1.2054587512570016
         1.2054587512570019} 0.021797085249007364

# Au sud:
    sspx [binarToFloat 0 0110010100011111100110100001001010111010001000000000 01111111001] $x1 $x2 ;# precision limit
    sspx [binarToFloat 0 0110010100011111100110100001001010111010000110111111 01111111001] $x1 $x2 ;# s
    sspx [binarToFloat 0 0110010100011111100110100001001010111010000111000000 01111111001] $x1 $x2 ;# precision limit

    sspx [binarToFloat 0 0110010100011111100110100001001010111010000111000000 01111111001] $x1 $x2 ;# precision limit

# Au nord:
    sspx [binarToFloat 0 0110010100011111100110100001001010111101010110011010 01111111001] $x1 $x2 ;# nw n ne
    sspx [binarToFloat 0 0110010100011111100110100001001010111101010110011001 01111111001] $x1 $x2 ;# precision limit

# À l'ouest:
    sspy [binarToFloat 0 0011010010011000111100011101100101010011011001111100 01111111111] $y1 $y2 ;# w
    sspy [binarToFloat 0 0011010010011000111100011101100101010011011001111101 01111111111] $y1 $y2 ;# precision limit
    
# À l'est :
    sspy [binarToFloat 0 0011010010011000111100011101100101010011011101001100 01111111111] $y1 $y2 ;# precision limit
    sspy [binarToFloat 0 0011010010011000111100011101100101010011011101010001 01111111111] $y1 $y2 ;# precision limit
    sspy [binarToFloat 0 0011010010011000111100011101100101010011011101010010 01111111111] $y1 $y2 ;# e

set x1 [binarToFloat 0 0011010010011000111100011101100101010011011001111100 01111111111] ;# 1.2054587512569972
set x2 [binarToFloat 0 0011010010011000111100011101100101010011011101010010 01111111111] ;# 1.2054587512570447
set y1 [binarToFloat 0 0110010100011111100110100001001010111010000110111111 01111111001] ;# 0.021797085249007028
set y2 [binarToFloat 0 0110010100011111100110100001001010111101010110011010 01111111001] ;# 0.021797085249053084
    set z [scplxi xy_new [di interval_d_d $x1 $x2] [di interval_d_d $y1 $y2]]
    # L'encadrement parfait est trouvé

    foreach l [concat [ce $z] [cn $z] [cw $z] [cs $z]] {
        puts $l
    }
}


set FIL(2003.02.25.FP) {
    Suivi de contour 

    set x1 -10000
    set x2 100
    set y1 -2000
    set y2 2000


    set lle [sspyD0D1 $x2 $y1 $y2]
    set lls [sspxD0D1 $y1 $x1 $x2]
    set llw [sspyD0D1 $x2 $y2 $y1]
    set lln [sspxD0D1 $y2 $x2 $x1]
    foreach l $lle {
        puts [list [lindex $l 0] [lindex $l 3] [list [lindex $l 6] [lindex $l end]]]
    }
    foreach l $lln {
        puts [list [lindex $l 0] [list [lindex $l 6] [lindex $l end]] [lindex $l 3]]
    }
    foreach l $llw {
        puts [list [lindex $l 0] [lindex $l 3] [list [lindex $l 6] [lindex $l end]]]
    }
    foreach l $lls {
        puts [list [lindex $l 0] [list [lindex $l 6] [lindex $l end]] [lindex $l 3]]
    }

    # Je décide de suivre les vallées

    set ll [startvalleys -100000 -2000 100 2000]
    displayvalleys -100000 -2000 100 2000 $ll
    
    cd /home/fab/Z
    plot "ne.dat" with lines, "nw.dat" with lines, "sw.dat" with lines, "se.dat" with lines 

#####################################################

    Il y a des soucis pour partir du côté est.
    Je recompile pour utiliser kappaz et non  kappazC

    set ll [startvalleys -10 -100 10 100]
    displayvalleys -10 -100 10 100 $ll

    foreach {x1 y1 x2 y2} {-4 -10 4 100} break
    set ll [startvalleys $x1 $y1 $x2 $y2]
    displayvalleys $x1 $y1 $x2 $y2 $ll -step 0.01

    # Les courbes sw sont un peu stranges dans le domaine -4 86 4 97
    
    foreach {x1 y1 x2 y2} {-4 86 4 97} break
    set ll [startvalleys $x1 $y1 $x2 $y2]
    set fins [displayvalleys $x1 $y1 $x2 $y2 $ll -step 0.01]

    # La courbe sw suivante
    # est attirée un peu vers le nord : ene (il y a son frère en face)
    # La force de rappel vers f=sw strict ne peut pas ramener vers le sud.
    # Ce n'est que lorsque le minima se retrouve ese que le retour est brutal.

  -2.4000000000000341 92.875
-2.3900000000000343 92.875
-2.3800000000000345 92.875
-2.3800000000000345 92.864999999999995
-2.3800000000000345 92.85499999999999
-2.3800000000000345 92.844999999999985
-2.3800000000000345 92.83499999999998
 
    foreach {x1 y1 x2 y2} {-4 -10 4 100} break
    set ll [startvalleysN $x1 $y1 $x2 $y2]
    displayvalleysN $x1 $y1 $x2 $y2 $ll -step 0.01

    f/f' ne marche par parce qu'il y a des pôles.
}

set HELP(??) {

################################

Calcul des modes superplasmons :

A u = v (continuité du champ)
B u = v (continuité de la dérivée)
Donc det(A-B) = 0

Calcul des déterminants :

}

set FIL(2003.03.31.FP) {
    Évaluation de la technique suivante :

    - recherche de rectangles contenant un unique zéro de fD0
    - restriction de ces rectangles, pour éliminer les zéros de fD1
    - recherche du zéro de fD0/fD1 dans chacun de ces rectangles

    proc fz {zC} {return [fD0 $zC]}
    set ll [fulldo -100 -100 100 100]
    set ll [fulldo -5 -100 5 100]
    foreach l $ll {puts stderr $l}
    # 25 zéros

    # choix d'un rectangle
    set n 0
    set rac1 [lindex [lindex [lindex $ll $n] 1] 1] ;#  xy {1.07421875 1.171875} {-100.0 100.0}
    # recherche des zéros de la dérivée
    proc fz {zC} {return [lindex [fD0D1 $zC] 1]}
    set llr1 [fulldoz $rac1]

    set x [scplxi xy_re $rac1]
    set y [scplxi xy_im $rac1]
    set x1 [di inf $x]
    set x2 [di sup $x]
    set y1 [di inf $y]
    set y2 [di sup $y]

    ####

    set x1 -100
    set x2 100
    set y1 -100
    set y2 100
        
    set spe [sspysD0D1 $x2 $y1 $y2]
    set spn [sspxsD0D1 $y2 $x2 $x1]
    set spw [sspysD0D1 $x1 $y2 $y1]
    set sps [sspxsD0D1 $y1 $x1 $x2]

    set spe0 [lindex $spe 0]
    set spe1 [lindex $spe 1]
    set spn0 [lindex $spn 0]
    set spn1 [lindex $spn 1]
    set spw0 [lindex $spw 0]
    set spw1 [lindex $spw 1]
    set sps0 [lindex $sps 0]
    set sps1 [lindex $sps 1]

    set l0 [list]
    foreach l $spe0 {
	lappend l0 [lindex $l 0]
    }
    foreach l $spn0 {
	lappend l0 [lindex $l 0]
    }
    foreach l $spw0 {
	lappend l0 [lindex $l 0]
    }
    foreach l $sps0 {
	lappend l0 [lindex $l 0]
    }
    set nz0 0
    set prev [lindex $l0 end]
    foreach e $l0 {
	incr nz0 [icount $prev $e]
	set prev $e
    }

    set l1 [list]
    foreach l $spe1 {
	lappend l1 [lindex $l 0]
    }
    foreach l $spn1 {
	lappend l1 [lindex $l 0]
    }
    foreach l $spw1 {
	lappend l1 [lindex $l 0]
    }
    foreach l $sps1 {
	lappend l1 [lindex $l 0]
    }
    set nz1 0
    set prev [lindex $l1 end]
    foreach e $l1 {
	incr nz1 [icount $prev $e]
	set prev $e
    }


    

{ne 50.0 52.34375} {w 52.34375 53.90625}
{{ne n} 50.0 50.78125} {{n n} 50.78125 51.5625} {{nw n} 51.5625 52.34375} {{w w} 52.34375 53.125} {{w w} 53.125 53.90625} {{sw sw} 53.90625 54.6875}

}

proc rien {} {}
