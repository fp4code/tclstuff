package provide PA 0.2 # prend la nomenclature JLP générale
package require masque 1.0

namespace eval PA {
    variable PA_positions
    array set PA_positions {
	3x3     {100 510}
	3.5x3.5 {250 510}
	4.2x4.2 {400 510}
	5.3x5.3 {100 310}
	7.2x7.2 {250 310}
	11x11   {400 310}
	24x24   {100  50}
	100x100 {250  50}
	0x0     {400 110}
	100x600 {560  55}
	25x600  {690 650}
	45x600  {760  55}
    }
}

proc ::PA::allSymDes {typDispo contourMasque} {
    if {$typDispo == "PA"} {
        set ret [list]
	foreach co {01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19} {
	    foreach li {01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19} {
		set lico $li$co
		set dims [list 3x3 3.5x3.5 4.2x4.2 5.3x5.3 7.2x7.2 11x11 24x24 100x100 0x0 100x600 25x600]
		foreach dim $dims {
		    set symDes PA_$dim_${li}x${co}
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
    }   
    return $ret
}

proc PA::allTypDispo {} {
    return [list PA]
}

proc PA::symDesToPos {symDes} {
    set li [string trimleft [string range $symDes 3 4] 0]
    set co [string trimleft [string range $symDes 5 6] 0]
    # utile si démarre en 00
    # if {$li == ""} {set li 0}
    # if {$co == ""} {set co 0}
    set dispo [string range $symDes 8 end]
    foreach {x y} $::PA::PA_positions($dispo) {}
    return [list [expr {$x + ($co-1) * 860}] [expr {$y - ($li-1) * 800}]]
}

proc PA::geomName {symDes} {
    return [string range $symDes 8 end]
}

proc PA::getSurface {symDes} {
    foreach {dx dy} [split [string range $symDes 8 end] x]
    return [expr {$dx*$dy}]
}


#proc PA::configPointes {} {
#    GPIB::renameGPIB smuA {}
#    GPIB::renameGPIB smuK {}
#    GPIB::copyGPIB smu1 smuA
#    GPIB::copyGPIB smu3 smuK
#}

