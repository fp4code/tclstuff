package require 5carres_centres 0.1

proc ::masque::allTypDispo {} {
    return [::5carres_centres::allTypDispo]
}

proc ::masque::calculeTout {} {
    return [::5carres_centres::calculeTout]
}

proc ::masque::getSurface {symdes} {
    return [::5carres_centres::getSurface $symdes]
}

proc ::masque::getFamily {symdes} {
    return [::5carres_centres::geomName $symdes]
}

proc ::masque::allSymDes {typDispo} {
    global ::5carres_centres::contourMasque
    return [::5carres_centres::allSymDes $typDispo $::5carres_centres::contourMasque]
}

proc ::masque::symDesToPos {symDes} {
    return [::5carres_centres::symDesToPos $symDes]
}

set ::5carres_centres::contourMasque [list \
   -251     251\
   -251  -19201\
  19251  -19201\
  19251     251\
   -251     251
]

proc ::5carres_centres::calculeTout {} {
    global ::masque::contourMasque
    global AllSymDes
    set AllSymDes [allSymDes 5carres_centres $::5carres_centres::contourMasque]
}

proc ::masque::verifContour {} {
    global ::masque::contourMasque
    foreach {x y} $::masque::contourMasque {
        ::aligned::moveTo tc550 $x $y
#        after 1000
    }
}

proc ::masque::configPointes {} {
    return [::5carres_centres::configPointes]
}
