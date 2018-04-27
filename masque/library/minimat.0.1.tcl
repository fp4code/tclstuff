package require masque 1.0

# La marque de position est en bas à droite

namespace eval minimat {
}

proc ::minimat::allSymDes {typDispo contourMasque} {
    set ret [list]
    foreach r {N W S E} {
	foreach i {1 2 3 4 5 6 7 8 9} {
	    lappend ret $r$i
	}
    }
    return $ret
}

proc ::minimat::allTypDispo {} {
    return [pixel]
}

proc ::minimat::symDesToPos {symDes} {
    error "TODO"
}

proc ::minimat::geomName {symDes} {
    return pixel
}

proc ::minimat::getSurface {symDes} {
    return 400.0
}

proc ::minimat::configPointes {} {
    GPIB::renameGPIB smuX {}
    GPIB::renameGPIB smuY {}
    GPIB::copyGPIB smu1 smuX
    GPIB::copyGPIB smu2 smuY
    GPIB::copyGPIB smu3 smu3
    global GPIBAPP
    set GPIBAPP(synchro) {1*2}
}

package provide minimat 0.1
