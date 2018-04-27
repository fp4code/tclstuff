# 25 octobre 2000 (FP) correction de bugs sur les bords

namespace eval geom2d {
    variable pi
    set pi [expr {2.0*atan2(1.0, 0.0)}]
}

  # contour est une liste x0 y0 x1 y1 ... x0 y0
proc geom2d::isInternal {contour x y} {
    variable pi
    # retourne 1 si interne ou sur le bord
    if {$contour == {}} {
        return 1
    }
    set len [llength $contour]
    if {$len % 2 != 0} {
        error "contour $contour incorrect : len = $len"
    }
    if {[lindex $contour 0] != [lindex $contour [expr {$len - 2}]] || \
            [lindex $contour 1] != [lindex $contour [expr {$len - 1}]]} {
        error "contour $contour non fermé"
    }
    set tours 0.0
    foreach {x0 y0} [lrange $contour 0 1] {}
    if {$y0 == $y && $x0 == $x} {
        return 1
    }
    set a0 [expr {atan2($y0 - $y, $x0 - $x)}]
    foreach {x1 y1} [lrange $contour 2 end] {
        if {$y1 == $y && $x1 == $x} {
            return 1
        }
        set a1 [expr {atan2($y1 - $y, $x1 - $x)}]
        # les angles vont de -pi non inclus a pi inclus
        # les differences vont de -2pi non inclus a 2pi non inclus
        set da [expr {$a1 - $a0}]
        if {$da > $pi} {
            # la difference va de pi-2pi=-pi non inclus a 2pi-2pi=0 non inclus
            set da [expr {$da - 2*$pi}]
        } elseif {$da < -$pi} {
            # la difference va de -2pi+2pi=0 non inclus a -pi+2pi=pi non inclus
            set da [expr {$da + 2*$pi}]
        } elseif {$da == -$pi || $da == $pi} {
            # sur le bord
            return 1
        }
        set tours [expr {$tours + $da}]
        set a0 $a1
    }
    set tours [expr {0.5 * $tours / $pi}]
    if {abs($tours) < 1e-3} {
        return 0
    } elseif {abs(abs($tours) - 1.0) < 1e-3} {
        return 1
    } else {
        error "tours = $tours"
    }
}


