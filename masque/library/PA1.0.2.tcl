package provide PA1 0.2 ;# 2021-10-26
package require masque 1.0

namespace eval PA1 {
    variable PA1_diodes_positions
    array set PA1_diodes_positions {
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
    variable PA1_TLM_positions
    array set PA1_TLM_positions {
	04a	{50	-170}
	12a	{160	-170}
	20a	{270	-170}
	28a	{380	-170}
	36a	{490	-170}
	04b	{50	-300}
	12b	{160	-300}
	20b	{270	-300}
	28b	{380	-300}
	36b	{490	-300}
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
    if {$typDispo == "TLM"} {
	foreach lico {
	        08-01 08-02 08-03 08-04 08-05 08-06 08-07
	        08-08
	        08-09 08-10 08-11 08-12 08-13 08-14 08-15
	        01-08 02-08 03-08 04-08 05-08 06-08 07-08
	        09-08 10-08 11-08 12-08 13-08 14-08 15-08} {
	    set dims [list 04a 12a 20a 28a 36a	04b 12b	20b 28b	36b]
	    foreach dim $dims {
		set symDes PA1_${dim}_${lico}
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

proc PA1::allTypDispo {} {
    return [list diode TLM]
}

proc PA1::symDesToPos {symDes} {
    set lsd [split $symDes _]
    if {[llength $lsd] != 3} {error "mauvais symDes \"$symDes\""}
    if {[lindex $lsd 0] == "PA1"} {
	set dispo [lindex $lsd 1]  
	set slico [lindex $lsd 2]
	set lico [split $slico -]
	if {[llength $lico] != 2} {error "mauvais lico \"$slico\" du symDes \"$symDes\""}
	set li [string trimleft [lindex $lico 0] 0]
	set co [string trimleft [lindex $lico 1] 0]
	# utile si démarre en 00
	# if {$li == ""} {set li 0}
	# if {$co == ""} {set co 0}
	foreach {x y} $::PA1::PA1_diodes_positions($dispo) {}
	return [list [expr {$x + ($co-1) * 580}] [expr {$y - ($li-1) * 450}]]
    } elseif {[lindex $lsd 0] == "PA1-TLM"} {
	set dispo [lindex $lsd 1]  
	set slico [lindex $lsd 2]
	set lico [split $slico -]
	if {[llength $lico] != 2} {error "mauvais lico \"$slico\" du symDes \"$symDes\""}
	set li [string trimleft [lindex $lico 0] 0]
	set co [string trimleft [lindex $lico 1] 0]
	# utile si démarre en 00
	# if {$li == ""} {set li 0}
	# if {$co == ""} {set co 0}
	foreach {x y} $::PA1::PA1_TLM_positions($dispo) {}
	return [list [expr {$x + ($co-1) * 580}] [expr {$y - ($li-1) * 450}]]
    } else {error "mauvais symDes \"$symDes\""}
}

proc PA1::geomName {symDes} {
    return [lindex [split $symDes _] 1]
}

proc PA1::getSurface {symDes} {
    set typDispo [lindex [split $symDes _] 0]
    if {$typDispo == "PA1"} {
	foreach {dx dy} [split [PA1::geomName $symDes] x] {}
	return [expr {$dx*$dy}]
    } elseif {$typDispo == "PA1-TLM"} {
	return [range [PA1::geomName $symDes] 0 1]
    } else {error "mauvais symDes \"$symDes\""}
}


#proc PA1::configPointes {} {
#    GPIB::renameGPIB smuA {}
#    GPIB::renameGPIB smuK {}
#    GPIB::copyGPIB smu1 smuA
#    GPIB::copyGPIB smu3 smuK
#}

