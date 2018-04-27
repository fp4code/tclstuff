package require masque_diodes_Benjamin_8x13 0.1

proc ::masque::allTypDispo {} {
    return [::diodes_Benjamin_8x13::allTypDispo]
}

proc ::masque::calculeTout {} {
    return [::diodes_Benjamin_8x13::calculeTout]
}

proc ::masque::getSurface {symdes} {
    return [::diodes_Benjamin_8x13::getSurface $symdes]
}

proc ::masque::getFamily {symdes} {
    return [::diodes_Benjamin_8x13::geomName $symdes]
}

proc ::masque::allSymDes {typDispo} {
    global ::diodes_Benjamin_8x13::contourMasque
    return [::diodes_Benjamin_8x13::allSymDes $typDispo $::diodes_Benjamin_8x13::contourMasque]
}

proc ::masque::symDesToPos {symDes} {
    return [::diodes_Benjamin_8x13::symDesToPos $symDes]
}

set ::diodes_Benjamin_8x13::contourMasque [list \
   -100     -100\
   2500     -100\
   2500     2200\
   -100     2200\
   -100     -100
]

proc ::diodes_Benjamin_8x13::calculeTout {} {
    global ::masque::contourMasque
    global AllSymDes
    set AllSymDes [allSymDes diodes $::diodes_Benjamin_8x13::contourMasque]
}

proc ::masque::verifContour {} {
    global ::masque::contourMasque
    foreach {x y} $::masque::contourMasque {
        ::aligned::moveTo tc550 $x $y
#        after 1000
    }
}

proc ::masque::configPointes {} {
    return [::diodes_Benjamin_8x13::configPointes]
}
