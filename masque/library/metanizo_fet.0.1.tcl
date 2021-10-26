package provide metanizo 0.1
package require masque 1.0

namespace eval metanizo_fet {
    variable P4_positions
    array set P4_positions {
	P4W08 {-2000 400}
	P4W09 {-1600 400}
        P4W10 {-1200 400}
	P4W11 { -800 400}
	P4W12 { -400 400}
	FULL  {    0 400}
	P4W13 {-2000   0}
	P4W14 {-1600   0}
	P4W15 {-1200   0}
	P4W16 { -800   0}
	P4W17 { -400   0}
	BLANK {    0   0}
    }
}

proc ::metanizo_fet {


proc ::PA::allSymDes {typDispo contourMasque} {
    if {$typDispo == "P4"} {
        set ret [list]
	foreach co {01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19} {
	    foreach li {01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19} {
		set lico $li$co
		set dims [list 3x3 3.5x3.5 4.2x4.2 5.3x5.3 7.2x7.2 11x11 24x24 100x100 0x0 100x600 25x600]
		foreach dim $dims {
		    set symDes PA_${li}${co}_$dim
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
    return [list P4]
}

proc PA::symDesToPos {symDes} {
    scan [string index $symDes 0] %c _xi
    scan [string index $symDes 1] %c _yi
    set xi [expr {$_xi - 65}]
    set yi [expr {$_yi - 65}]



    set ili [string trimleft string range $symDes 3 4] 0]
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

