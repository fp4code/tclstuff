package require microCIS_plots 0.1

proc ::masque::allTypDispo {} {
    return [::microCIS_plots::allTypDispo]
}

proc ::masque::calculeTout {} {
    return [::microCIS_plots::calculeTout]
}

proc ::masque::getSurface {symdes} {
    return [::microCIS_plots::getSurface $symdes]
}

proc ::masque::getFamily {symdes} {
    return [::microCIS_plots::geomName $symdes]
}

proc ::masque::allSymDes {typDispo} {
    global ::microCIS_plots::contourMasque
    return [::microCIS_plots::allSymDes $typDispo $::microCIS_plots::contourMasque]
}

proc ::masque::symDesToPos {symDes} {
    return [::microCIS_plots::symDesToPos $symDes]
}

set ::masque::contourMasque [list \
      0       0\
  20000       0\
  20000   16000\
      0   16000\
      0       0
]

proc ::microCIS_plots::calculeTout {} {
    global ::masque::contourMasque
    global AllSymDes
    set AllSymDes [allSymDes microCIS_plots $::masque::contourMasque]
}


proc ::masque::verifContour {} {
    global ::masque::contourMasque
    foreach {x y} $::masque::contourMasque {
        ::aligned::moveTo tc550 $x $y
#        after 1000
    }
}

proc ::masque::configPointes {} {
    return [::microCIS_plots::configPointes]
}
