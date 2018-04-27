package require masque 1.0

# Les croix sont en haut à droite.

namespace eval diodes_gardees {
    variable positions
    variable  typdims
    array set positions {
	ds050 { -360 -135}
	ds065 { -360 -225}
	ds100 { -195  -15}
	ds150 { -220 -180}
	ds300 { -105 -470}
	dg050 {  -85 -263}
	dg065 { -398  -15}
	dg100 { -605  -25}
	dg150 { -555 -195}
	dg300 { -405 -465}
	tlm05  {-618 -720}
	tlm10  {-543 -720}
	tlm20  {-463 -720}
	tlm30  {-373 -720}
	tlm40  {-273 -720}
    }
    array set typdims {
	ds {ds050 ds065 ds100 ds150 ds300}
	dg {dg050 dg065 dg100 dg150 dg300}
	tlm {tlm05 tlm10 tlm20 tlm30 tlm40}
    }
}

proc ::diodes_gardees::allSymDes {typDispo contourMasque} {
    set ret [list]
    if {$typDispo == "dg" || $typDispo == "ds"} {
	set dims $::diodes_gardees::typdims($typDispo)
    } else {
	set dims $typDispo ;# tlm05 tlm10 tlm20 tlm30 tlm40
    }
    foreach co {00 01 02 03 04 05 06 07 08 09} {
	foreach li {00 01 02 03 04 05 06 07 08 09} {
	    set lico $li$co
	    foreach dim $dims {
		set symDes $li${co}_$dim
		foreach {x y} [symDesToPos $symDes] {}
		if {[geom2d::isInternal $contourMasque $x $y]} {
		    lappend ret $symDes
		    # puts YES
		} else {
		    # puts NO
		}
	    }
	}
    }
    return $ret
}

proc ::diodes_gardees::allTypDispo {} {
    return [list dg ds tlm05 tlm10 tlm20 tlm30 tlm40]
}

proc ::diodes_gardees::symDesToPos {symDes} {
    set li [string trimleft [string range $symDes 0 1] 0]
    set co [string trimleft [string range $symDes 2 3] 0]
    if {$li == ""} {set li 0}
    if {$co == ""} {set co 0}
    set dispo [string range $symDes 5 end]
    foreach {x y} $::diodes_gardees::positions($dispo) {}
    return [list [expr {$x + $co * 800}] [expr {$y - $li * 900}]]
}

proc ::diodes_gardees::geomName {symDes} {
    return [string range $symDes 5 end]
}

proc ::diodes_gardees::getSurface {symDes} {
    if {[string match *tlm* $symDes]} {
	error "pas de getSurface pour les tlm"
    }
    set cote [string trimleft [string range $symDes 7 end] 0]
    return [expr {$cote*$cote}]
}

proc ::diodes_gardees::configPointes {} {
    GPIB::renameGPIB smuA {}
    GPIB::renameGPIB smuK {}
    GPIB::copyGPIB smu1 smuG
    GPIB::copyGPIB smu3 smuA
}

package provide diodes_gardees 0.2
