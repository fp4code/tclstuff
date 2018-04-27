package require TLM2007 0.2


proc ::masque::allTypDispo {} {
    return [::TLM2007::allTypDispo]
}

proc ::masque::getSurface {symdes} {
    return -code error "Pas de notion de surface !!!"
}

proc ::masque::getFamily {symdes} {
    return tlm
}

proc ::masque::allSymDes {typDispo} {
    global ::masque::contourMasque
    return [::TLM2007::allSymDes $typDispo $::masque::contourMasque]
}

proc ::masque::symDesToPos {symDes} {
    return [::TLM2007::symDesToPos $symDes]
}

set ::masque::contourMasque [list\
   8530   -9815\
   9630   -9815\
   9630     185\
   8530     185\
   8530   -9815\
]

proc ::masque::calculeTout {} {
    global ::masque::contourMasque
    global AllSymDes
# Mesure de tous les dispo inscrits dans le contour définit par contourMasque
    set AllSymDes [allSymDes tlm]
# Mesure des dispos d'une liste
#    set AllSymDes {}
}




proc ::masque::verifContour {} {
    global ::masque::contourMasque
    foreach {x y} $::masque::contourMasque {
        ::aligned::moveTo tc550 $x $y
#        after 1000
    }
}

proc ::masque::configPointes {} {
    return [::TLM2007::configPointes]
}
