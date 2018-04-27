package require tbs2

proc ::masque::allTypDispo {} {
    return [::tbs2::allTypDispo]
}

proc ::masque::calculeTout {} {
    return [::tbs2::calculeTout]
}

proc ::masque::getSurface {symdes} {
    return [::tbs2::getSurface $symdes]
}

proc ::masque::getFamily {symdes} {
    return [::tbs2::geomName $symdes]
}

proc ::masque::allSymDes {typDispo} {
    global ::tbs2::contourMasque
    return [::tbs2::allSymDes $typDispo $::tbs2::contourMasque]
}

proc ::masque::symDesToPos {symDes} {
    return [::tbs2::symDesToPos $symDes]
}

set ::tbs2::contourMasque [list \
   0 0\
   0 -20000\
   20000 -20000\
   20000 0\
   0 0\
]


proc ::tbs2::calculeTout {} {
    global ::masque::contourMasque
    global AllSymDes

    # commenter éventuellement
    set AllSymDes [allSymDes tbs $::tbs2::contourMasque]

    # extrait de ...be_pretri/good.spt
    # set AllSymDes [list \
        12C5x10 \
        21A5x10 \
        ...
        82B8x27 \
    ]
}

proc ::masque::verifContour {} {
    global ::masque::contourMasque
    foreach {x y} $::masque::contourMasque {
        ::aligned::moveTo tc550 $x $y
#        after 1000
    }
}

proc ::masque::configPointes {} {
    return [::tbs2::configPointes]
}
