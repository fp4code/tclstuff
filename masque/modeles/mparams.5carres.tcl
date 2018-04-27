package require 5carres 0.1

proc ::masque::allTypDispo {} {
    return [::5carres::allTypDispo]
}

proc ::masque::calculeTout {} {
    return [::5carres::calculeTout]
}

proc ::masque::getSurface {symdes} {
    return [::5carres::getSurface $symdes]
}

proc ::masque::getFamily {symdes} {
    return [::5carres::geomName $symdes]
}

proc ::masque::allSymDes {typDispo} {
    global ::5carres::contourMasque
    return [::5carres::allSymDes $typDispo $::5carres::contourMasque]
}

proc ::masque::symDesToPos {symDes} {
    return [::5carres::symDesToPos $symDes]
}

set ::5carres::contourMasque [list \
   -251     251\
   -251  -19201\
  19251  -19201\
  19251     251\
   -251     251
]

proc ::5carres::calculeTout {} {
    global ::masque::contourMasque
    global AllSymDes
    set AllSymDes [allSymDes 5carres $::5carres::contourMasque]
}

proc ::masque::verifContour {} {
    global ::masque::contourMasque
    foreach {x y} $::masque::contourMasque {
        ::aligned::moveTo tc550 $x $y
#        after 1000
    }
}

proc ::masque::configPointes {} {
    return [::5carres::configPointes]
}
