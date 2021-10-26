package provide PA1 0.1 ;# 2021-10-01
package require masque 1.0

namespace eval PA1 {
    variable PA1_positions
    array set PA1_positions {
	3x3     {260  -55}
	5.3x5.3 {370  -55}
	7.2x7.2 { 40 -110}
	11x11   {150 -110}
	15x15   {260 -195}
        24x24   {370 -195}
	100x100 {500 -160}
	3.5x35  {370 -380}
        5x50    {260 -380}
        7x70    {150 -380}
        15x150  { 40 -380}
	0x0     {500 -380}
    }
}

proc ::PA1::allSymDes {typDispo contourMasque} {
    set ret [list]
    if {$typDispo == "diode"} {
	foreach co {01 02 03 04 05 06 07 09 10 11 12 13 14 15} {
	    foreach li {01 02 03 04 05 06 07 09 10 11 12 13 14 15} {
		set lico $li$co
		set dims [list 3x3 5.3x5.3 7.2x7.2 11x11 15x15 24x24 100x100 3.5x35 5x50 7x70 15x150 0x0]
		foreach dim $dims {
		    set symDes PA1_${dim}_${li}-${co}
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

proc PA1::allTypDispo {} {
    return [list diode tlm]
}

proc PA1::symDesToPos {symDes} {
    set lsd [split $symDes _]
    if {[llength $lsd] != 3 || [lindex $lsd 0] != "PA1"} {error "mauvais symDes \"$symDes\""}
    set dispo [lindex $lsd 1]  
    set slico [lindex $lsd 2]
    set lico [split $slico -]
    if {[llength $lico] != 2} {error "mauvais lico \"$slico\" du symDes \"$symDes\""}
    set li [string trimleft [lindex $lico 0] 0]
    set co [string trimleft [lindex $lico 1] 0]
    # utile si démarre en 00
    # if {$li == ""} {set li 0}
    # if {$co == ""} {set co 0}
    foreach {x y} $::PA1::PA1_positions($dispo) {}
    return [list [expr {$x + ($co-1) * 580}] [expr {$y - ($li-1) * 450}]]
}

proc PA1::geomName {symDes} {
    return [lindex [split $symDes _] 1]
}

proc PA1::getSurface {symDes} {
    foreach {dx dy} [split [PA1::geomName $symDes] x] {}
    return [expr {$dx*$dy}]
}


#proc PA1::configPointes {} {
#    GPIB::renameGPIB smuA {}
#    GPIB::renameGPIB smuK {}
#    GPIB::copyGPIB smu1 smuA
#    GPIB::copyGPIB smu3 smuK
#}

