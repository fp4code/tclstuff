package require microCIS 0.1

proc ::masque::allTypDispo {} {
    return [::microCIS::allTypDispo]
}

proc ::masque::calculeTout {} {
    return [::microCIS::calculeTout]
}

proc ::masque::getSurface {symdes} {
    return [::microCIS::getSurface $symdes]
}

proc ::masque::getFamily {symdes} {
    return [::microCIS::geomName $symdes]
}

proc ::masque::allSymDes {typDispo} {
    global ::microCIS::contourMasque
    return [::microCIS::allSymDes $typDispo $::microCIS::contourMasque]
}

proc ::masque::symDesToPos {symDes} {
    return [::microCIS::symDesToPos $symDes]
}

set ::microCIS::contourMasque [list \
     -1       1\
     -1  -16001\
  20001  -16001\
  20001       1\
     -1       1
]

proc ::microCIS::calculeTout {} {
    global ::masque::contourMasque
    global AllSymDes
    set AllSymDes [allSymDes microCIS $::microCIS::contourMasque]
}



proc ::masque::verifContour {} {
    global ::masque::contourMasque
    foreach {x y} $::masque::contourMasque {
        ::aligned::moveTo tc550 $x $y
#        after 1000
    }
}

proc ::masque::configPointes {} {
    return [::microCIS::configPointes]
}
