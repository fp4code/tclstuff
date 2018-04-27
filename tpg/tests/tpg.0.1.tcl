load /home/fab/C/fidev-SparcSolarisForte7-optim/Tcl/tpg/src/libtpg.0.1.so Tpg

set p [tpg::new_Point]
tpg::Point_x_set $p 2
tpg::Point_y_set $p 1

proc displayPoint {p} {
    return [list [::tpg::Point_x_get $p] [::tpg::Point_y_get $p]]
}

proc setPoint {pName x y} {
    ::tpg::Point_x_set $pName $x
    ::tpg::Point_y_set $pName $y
    return
}
