package require jumbo_pG 0.1

set JUMBODIM 50

proc ::masque::allTypDispo {} {
    return [::jumbo_pG::allTypDispo]
}

proc ::masque::calculeTout {} {
    return [::jumbo_pG::calculeTout]
}

proc ::masque::getSurface {symdes} {
    return [::jumbo_pG::getSurface $symdes]
}

proc ::masque::getFamily {symdes} {
    return [::jumbo_pG::geomName $symdes]
}

proc ::masque::allSymDes {typDispo} {
    global ::jumbo_pG::contourMasque
    return [::jumbo_pG::allSymDes $typDispo $::jumbo_pG::contourMasque]
}

proc ::masque::symDesToPos {symDes} {
    return [::jumbo_pG::symDesToPos $symDes]
}

set ::jumbo_pG::contourMasque [list \
  42000  -16000\
  42000  -42000\
  21000  -42000\
  21000  -34000\
  25200  -24000\
  42000  -16000\
]


proc ::jumbo_pG::calculeTout {} {
    global JUMBODIM
    global ::masque::contourMasque
    global AllSymDes
    set AllSymDes [allSymDes jumbo$JUMBODIM $::jumbo_pG::contourMasque]
}



proc ::masque::verifContour {} {
    global ::masque::contourMasque
    foreach {x y} $::masque::contourMasque {
        ::aligned::moveTo tc550 $x $y
#        after 1000
    }
}

proc ::masque::configPointes {} {
    return [::jumbo_pG::configPointes]
}
