# avant de créer des objets

proc getX {xy} {
    return [lindex $xy 0]
}

proc getY {xy} {
    return [lindex $xy 1]
}

proc newXY {x y} {
    return [list $x $y]
}

proc sumXY {xy1 xy2} {
    return [newXY [expr [getX $xy1]+[getX $xy2]] [expr [getY $xy1]+[getY $xy2]]]
}
