namespace eval geom2D {
#    variable Pi
#    set Pi [expr atan2(0.0, -1.0)]
#  degres ( i -- ) ( F: -- 1/2tours )     \ calcul d'angle en deg.
}

proc ::geom2D::degToDemiTour {a} {
    return [expr $a/180.0]
}

set HELP(::geom2D::axe) {
		\ une ligne orientée
		\ distance algébrique à l'origine
		\ angle de la normale en demi-tour

    Le point P a pour coordonnees (d*cospi(a), d*sinpi(a))
    Le vecteur directeur de l'axe a pour coordonnées
        (cospi(a+0.5), sinpi(a+0.5)) = (-sinpi(a), cospi(a))
    Les points M vérifient PM = (-t*sinpi(a), t*cospi(a))
        x = d*cospi(a) - t*sinpi(a), y = d*sinpi(a) + t*cospi(a))
        l'orientation va de t=-infini à t=+infini
    Les points de l'axe vérifient
        x*cos(a) + y*sin(a) = d
}

proc ::geom2D::axe {distance angle} {
    return [list "axe" $distance $angle] ;# angle en 1/2 tours
} 

proc ::geom2D::axeGet {distanceName angleName axe} {
    upvar $distanceName distance
    upvar $angleName angle
    if {[lindex $axe 0] != "axe" || [llength $axe] != 3} {
        error "pas un axe : $axe"
    }
    set distance [lindex $axe 1]
    set angle [lindex $axe 2]
} 

set HELP(::geom2D::pt) {
		\ un point cartésien
		pt.x
		pt.y
}

proc ::geom2D::pt {x y} {
    return [list "pt" $x $y]
} 

proc ::geom2D::ptGet {xName yName pt} {
    upvar $xName x
    upvar $angleName angle
    if {[lindex $axe 0] != "pt" || || [llength $pt] != 3} {
        error "pas un pt : $pt"
    }
    set distance [lindex $axe 1]
    set angle [lindex $axe 2]
} 

set HELP(::geom2D::cercle) {
		\ un cercle
		pt:	cercle.o	\ origine (centre)
		float:	cercle.r	\ rayon
}

proc ::geom2D::cercle {centre rayon} {
    return [list "cercle" $centre $rayon]
} 

proc ::geom2D::cercleGet {centreName rayonName cercle} {
    upvar $centreName centre
    upvar $rayonName rayon
    if {[lindex $axe 0] != "cercle" || || [llength $cercle] != 3} {
        error "pas un cercle : $cercle"
    }
    set centre [lindex $axe 1]
    set rayon [lindex $axe 2]
} 



set rien {
: p DUP . DUP axe.a . axe.d . ;

}

namespace eval geom2D {
    variable Ox
    variable Oy
    variable aa
    variable bb

    set Ox [axe 0.0 -0.5]
    set Oy [axe 0.0  0.0]
    set aa [axe 1.0 -0.25]
    set bb [axe -1.0 0.75]
}

proc ::geom2D::axes.intersection {axe1 axe2} {
    axeGet d1 a1 $axe1
    axeGet d2 a2 $axe2

    set saa [expr {sinpi($a2 - $a1)}]
    if {$saa == 0.0} {
        error "droites non sécantes"
    }
    set x [expr {($d1*sinpi($a2) - $d2*sinpi($a1))/$saa}]
    set y [expr {($d2*cospi($a1) - $d1*cospi($a2))/$saa}]
    return [pt $x $y]
}

proc ::geom2D::distanceAlgebrique.pt.axe {pt axe} {
# > 0 si pt à droite de l'axe
    ptGet x y $pt
    axeGet d a $axe

    # IQ = (x - d*cospi(a) + t*sinpi(a), y - d*sinpi(a) + t*cospi(a))
    # V  = (-sinpi(a), cospi(a))
    # distance = IQ x V
    return [expr {$d - $x*cospi($a) - $y*sinpi($a)}]
}

# non vérifié
proc ::geom2D::axeTangentFromCercle+Angle {cercle a} {
    cercleGet centre rayon $cercle
    ptGet xc yc $centre
    return [axe [expr {$rc + $xc*cospi($a) + $yc*sinpi($a)}] $a]
}

# non vérifié
proc ::geom2D::axeFromPoint+Angle {point a} {
    ptGet x y $centre
    return [axe [expr {$x*cospi($a) + $y*sinpi($a)}] $a]
}

proc ::geom2D::intersectionSimpleDeSegments {ax0 ay0 ax1 ay1 bx0 by0 bx1 by1} {

}

