package require pG-Lpn

proc ::masque::allTypDispo {} {
    return [::pG-Lpn::allTypDispo]
}

proc ::masque::calculeTout {} {
    return [::pG-Lpn::calculeTout]
}

proc ::masque::getSurface {symdes} {
    return [::pG-Lpn::getSurface $symdes]
}

proc ::masque::getFamily {symdes} {
    return [::pG-Lpn::geomName $symdes]
}

proc ::masque::allSymDes {typDispo} {
    global ::pG-Lpn::contourMasque
    return [::pG-Lpn::allSymDes $typDispo $::pG-Lpn::contourMasque]
}

proc ::masque::symDesToPos {symDes} {
    return [::pG-Lpn::symDesToPos $symDes]
}

set ::pG-Lpn::contourMasque [list \
    -10920     18390\
    -14820     14490\
    -14820      8790\
     -8520      2490\
      -720     10290\
     -7020     16590\
    -10920     18390\
]


# set ::pG-Lpn::type psg
set ::pG-Lpn::type jumbo

proc ::pG-Lpn::calculeTout {} {
    global ::masque::contourMasque
    global AllSymDes
    variable type

    # commenter éventuellement
    set AllSymDes [allSymDes $type ${::pG-Lpn::contourMasque}]
    
    # set AllSymDes [list\
	C3psg10x40\
	D4psg5x10\
	C4psg5x20\
	D5psg5x20\
	C4psg5x40\
	C4psg5x5\
	C4psg5x80]
}

proc ::masque::verifContour {} {
    global ::pG-Lpn::contourMasque
    global TC
    foreach {x y} ${::pG-Lpn::contourMasque} {
        ::aligned::moveTo $TC(machine) $x $y
        after 1000
    }
}

proc masque::configPointes {} {
    ::pG-Lpn::configPointes
}
