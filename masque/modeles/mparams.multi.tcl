package require MOHbt 0.2

proc ::masque::allTypDispo {} {
    return [::MOHbt::allTypDispo]
}

proc ::masque::allSymDes {typDispo} {
    return [::MOHbt::allSymDes $typDispo {}]
}

proc ::masque::symDesToPos {symDes} {
    return [::MOHbt::symDesToPos $symDes]
}

proc ::masque::calculeTout {} {
    global AllSymDes
    set AllSymDes [::masque::allSymDes {}]
}

proc ::masque::getSurface {symDes} {
    return [::MOHbt::getSurface $symDes]
}

proc ::masque::configPointes {} {
    return [::MOHbt::configPointes]
}

proc ::masque::getFamily {symdes} {
    return [::MOHbt::getFamily $symdes]
}
