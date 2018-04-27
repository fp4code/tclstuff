# 26 janvier 2001 (FP) 1.2 modif. pour MM4005

package provide isometrie 1.2

namespace eval isometrie {
}

set ::HELP(::isometrie) {
    une isométrie est un tableau contenant les éléments
    angle, cos, sin (redondants) , xTr et yTr
    une isométrie approchée contient en outre une liste
    corr formée de couples de points mécanique-échantillon :
    {{{xm0 ym0} {xe0 ye0}} {{xm1 ym1} {xe1 ye1}} ...}
    Chaque couple de points devant être approché au mieux
    par l'isométrie, La synchronisation est faite par la
    procédure evalueTransform
} 

set ::HELP(::isometrie::setUncorrected) {
    initialise le tableau de nom $isometrie pour l'isométrie identité
}
proc isometrie::setUncorrected {name} {
    upvar #0 $name iso
    set iso(angle) 0.0
    set iso(cos) 1.0
    set iso(sin) 0.0
    set iso(xTr) 0
    set iso(yTr) 0
    
}

set ::HELP(::isometrie::setUncorrected90) {
    initialise le tableau de nom $name pour l'isométrie
    rotation de 90 degrés
}

proc isometrie::setUncorrected90 {name} {
    upvar #0 $name iso
    set iso(cos) 0.0
    set iso(sin) 1.0
    set iso(angle) [expr {atan2(1.0,0.0)}]
    set iso(xTr) 0
    set iso(yTr) 0
}

set ::HELP(::isometrie::new) {
    crée une isométrie de nom $name.
    Retourne une erreur si l'isométrie existe déjà
}

proc isometrie::new {name} {
    upvar #0 $name iso
    if {[info exists iso]} {
        error "$name already exists"
    }
    setUncorrected $name
    return $name
}

set ::HELP(::isometrie::echToMec) {
    retourne la liste des 2 coordonnées mécaniques à partir
    des coordonnées échantillon $px et $py pour une isométrie donnée
}

proc isometrie::echToMec {name px py} {
    upvar #0 $name iso
    set x [expr {int(round($px * $iso(cos) - $py * $iso(sin))) + $iso(xTr)}]
    set y [expr {int(round($px * $iso(sin) + $py * $iso(cos))) + $iso(yTr)}]
    return [list $x $y]
}

proc isometrie::mecToEch {name px py} {
    upvar #0 $name iso
    set px [expr {$px - $xTr}]
    set py [expr {$py - $yTr}]
    set x [expr {int(round($px * $iso(cos) + $py * $iso(sin)))}]
    set y [expr {int(round($px * $iso(sin) - $py * $iso(cos)))}]
    return [list $x $y]
}

set ::HELP(::isometrie::evalueTransform) {
    calcule les meileurs coefficients de l'isométrie
    pour mettre en correspondance les points 
    mécanique et échantillon
}

proc isometrie::evalueTransform {name} {
    upvar #0 $name iso
    if {![info exists iso(corr)] || $iso(corr) == {}} {
        setUncorrected $name
        return
    }
    set n [llength $iso(corr)]
    if {$n == 1} {
        set cdp [lindex $iso(corr) 0]
        setUncorrected $name
        set xymec [lindex $cdp 0]
        set xm [lindex $xymec 0]
        set ym [lindex $xymec 1]
        set xyech [lindex $cdp 1]
        set xe [lindex $xyech 0]
        set ye [lindex $xyech 1]
        set iso(xTr) [expr {$xm - $xe}]
        set iso(yTr) [expr {$ym - $ye}]
        return
    }
    set xmx 0.0
    set xmy 0.0
    set ymx 0.0
    set ymy 0.0
    set xm 0.0
    set ym 0.0
    set x 0.0
    set y 0.0
    foreach cdp $iso(corr) {
        set xymec [lindex $cdp 0]
        set xmi [expr {double([lindex $xymec 0])}]
        set ymi [expr {double([lindex $xymec 1])}]
        set xyech [lindex $cdp 1]
        set xi [expr {double([lindex $xyech 0])}]
        set yi [expr {double([lindex $xyech 1])}]
        set xmx [expr {$xmx + $xmi * $xi}]
        set xmy [expr {$xmy + $xmi * $yi}]
        set ymx [expr {$ymx + $ymi * $xi}]
        set ymy [expr {$ymy + $ymi * $yi}]
        set xm [expr {$xm + $xmi}]
        set ym [expr {$ym + $ymi}]
        set x [expr {$x + $xi}]
        set y [expr {$y + $yi}]
    }
    set xx [expr {($xmx - $xm * $x / $n) + ($ymy - $ym * $y / $n)}]
    set yy [expr {- ($xmy - $xm * $y / $n) + ($ymx - $ym * $x / $n)}]
    if {$xx == 0 && $yy == 0} {
        set iso(angle) 0.0
    } else {
        set iso(angle) [expr {atan2($yy, $xx)}]
    }
    set iso(cos) [expr {cos($iso(angle))}]
    set iso(sin) [expr {sin($iso(angle))}]
    set iso(xTr) [expr {int(round((- $x * $iso(cos) + $y * $iso(sin) + $xm)/$n))}]
    set iso(yTr) [expr {int(round((- $x * $iso(sin) - $y * $iso(cos) + $ym)/$n))}]
}

set ::HELP(::isometrie::insertLast) {
    ajoute un couple de points à la liste de corrections
    et recalcule l'isométrie $name
}

proc isometrie::insertLast {name xymec xyech} {
    upvar #0 $name iso
    lappend iso(corr) [list $xymec $xyech]
    evalueTransform $name
}

set ::HELP(::isometrie::removeFirst) {
    ôte le premier couple de points de la liste de corrections
    et recalcule l'isométrie $name
}

proc isometrie::removeFirst {name} {
    upvar #0 $name iso
    set iso(corr) [lreplace $iso(corr) 0 0]
    evalueTransform $name
}

set ::HELP(::isometrie::removeLast) {
    ôte le dernier couple de points de la liste de corrections
    et recalcule l'isométrie $name
}

proc isometrie::removeLast {name} {
    upvar #0 $name iso
    set iso(corr) [lreplace $iso(corr) end end]
    evalueTransform $name
}

set ::HELP(::isometrie::translateOnly) {
    décale de façon identique
    tous les couples de points de la liste de corrections
    pour que la correspondance entre les points $xymec et $xyech
    soit exacte
    et recalcule l'isométrie $name
}

proc isometrie::translateOnly {name xymec xyech} {
    upvar #0 $name iso
    if {![array exists iso] ||
    ![info exists iso(corr)] ||
    [llength $iso(corr)] == 0}  {
        set iso(corr) [list [list $xymec $xyech]]
    } else {
        set newcorr {}
        foreach {xm ym} $xymec {}
        foreach {xe ye} $xyech {}
        foreach {xmo ymo}  [echToMec $name $xe $ye] {}
        set dx [expr {$xm - $xmo}]
        set dy [expr {$ym - $ymo}]
        foreach c $iso(corr) {
            set xymec [lindex $c 0]
            set xm [lindex $xymec 0]
            set ym [lindex $xymec 1]
            set xymec [list [expr {$xm + $dx}] [expr {$ym + $dy}]]
            lappend newcorr [list $xymec [lindex $c 1]]
        }
        set iso(corr) $newcorr
    }
    evalueTransform $name
}

set ::HELP(::isometrie::ecarts) {
    retourne la liste des écarts entre les coordonnées mécaniques
    voulues et obtenues au moyen de l'isométrie
    et recalcule l'isométrie $name
}

proc isometrie::ecarts {name} {
    upvar #0 $name iso
    set ret {}
    foreach cdp $iso(corr) {
        set xymec [lindex $cdp 0]
        set xm [lindex $xymec 0]
        set ym [lindex $xymec 1]
        set xyech [lindex $cdp 1]
        set xe [lindex $xyech 0]
        set ye [lindex $xyech 1]
        set dx [expr {$xe * $iso(cos) - $ye * $iso(sin) - $xm + $iso(xTr)}]
        set dy [expr {$xe * $iso(sin) + $ye * $iso(cos) - $ym + $iso(yTr)}]
        lappend ret [expr {sqrt($dx*$dx+$dy*$dy)}]
    }
    return $ret
}

set ::HELP(::isometrie::removeWorst) {
    ôte le pire couple de points de la liste de corrections
    et recalcule l'isométrie $name
}

proc isometrie::removeWorst {name} {
    upvar #0 $name iso
    set worstec2 0.0
    set worsti 0
    set i 0
    foreach ec [ecarts $name] {
        if {$ec > $worstec2} {
            set worsti $i
            set worstec2 $ec
        }
        incr i
    }   
    set iso(corr) [lreplace $iso(corr) $worsti $worsti]
    evalueTransform $name
}
    
proc isometrie::printDist {name} {
    puts [ecarts $name]
}
