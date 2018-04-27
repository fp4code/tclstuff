
canvas .gauche.c

pack .gauche.c -fill both -expand 1

canvas .gauche.cj

pack .gauche.cj -fill both -expand 1

namespace eval mparamsCanvas {}

proc scrollConfAll {win marge} {
    foreach {x y x1 y1} [$win bbox all] {
        $win configure -scrollregion [list [expr $x-$marge]\
                                           [expr $y-$marge]\
                                           [expr $x1+$marge]\
                                           [expr $y1+$marge]]
    }
}


proc ::mparamsCanvas::echelle {canvas scale tagOrId} {
#    set coords [$canvas cget -scrollregion]
#    set newCoords {}
#    foreach c $coords {
#        lappend newCoords [expr $c * $scale]
#    }
#    $canvas configure -scrollregion $newCoords
    $canvas configure -scrollregion [$canvas bbox all]
    if {[string match {[1-9*]} $tagOrId]} {
        set objs $tagOrId
    } else {
        set objs [$canvas find withtag $tagOrId]
    }
    foreach obj $objs {
        set coords [$canvas coords $obj]
        set newCoords {}
        foreach c $coords {
            lappend newCoords [expr $c * $scale]
        }
        eval $canvas coords $obj $newCoords
    }
    scrollConfAll $canvas 20
}

.gauche.c delete all
eval .gauche.c create line $::tbs2::contourMasque -width 0 -fill green 
::mparamsCanvas::echelle .gauche.c 0.01 all


foreach symdes [::masque::allSymDes tbs] {
    set xy [::masque::symDesToPos $symdes]
    set x [lindex $xy 0]
    set y [lindex $xy 1]
    set dx 400
    set dy 200
    set x0 [expr {0.01*($x - 0.5*$dx)}]
    set y0 [expr {0.01*($y - 0.5*$dy)}]
    set x1 [expr {0.01*($x + 0.5*$dx)}]
    set y1 [expr {0.01*($y + 0.5*$dy)}]
    .gauche.c create poly $x0 $y0 $x1 $y0 $x1 $y1 $x0 $y1 -fill {} -outline black -tags $symdes
}
::mparamsCanvas::echelle .gauche.c 2 all

foreach symdes [::masque::allSymDes tbs] {
    .gauche.c itemconfigure $symdes -fill red
    update
}

foreach symdes [::masque::allSymDes tbs] {
    if {[string match *C* $symdes]} {
        .gauche.c itemconfigure $symdes -fill blue
    update
    }
}

foreach symdes [::masque::allSymDes tbs] {
    if {[string match {*[A-Z]8x27} $symdes]} {
        .gauche.c itemconfigure $symdes -fill green
    update
    }
}
