package require masque 1.0

namespace eval pda_emilie {
    variable pda_emilie_positions
    array set pda_emilie_positions {
	05x005 {380 320}
	07x020 {270 320}
	10x005 {160 320}
	10x010 { 50 320}
	10x100 {490  60}
	20x020 {380  60}
	30x100 {270  60}
	40x040 {160  60}
	70x175 { 50  60}
	tlm05  {625 500}
	tlm10  {625 425}
	tlm20  {625 345}
	tlm30  {625 255}
	tlm40  {625 155}
    }
}


proc ::pda_emilie::allSymDes {typDispo contourMasque} {
    set ret [list]
    foreach co {01 02 03 04 05 06 07 08 09 10 11 12 13 14} {
	foreach li {A B C D E F G H I J K L M N} {
	    if {$typDispo == "pda_emilie"} {
		set dims [list 05x005 07x020 10x005 10x010 10x100 20x020 30x100 40x040 70x175]
	    } elseif {[string match tlm*  $typDispo]} {
		set dims [list $typDispo]
	    } else {
		error "should be one of [allTypDispo]"
	    }
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

proc ::pda_emilie::allTypDispo {} {
    return [list pda_emilie tlm05 tlm10 tlm20 tlm30 tlm40]
}

proc ::pda_emilie::symDesToPos {symDes} {
    set li [expr {[scan [string index $symDes 0] %c] - [scan A' %c]}]
    set co [string trimleft [string range $symDes 1 2] 0]
    if {$co == ""} {set co 0} 
    set dispo [string range $symDes 4 end]
    foreach {x y} $::pda_emilie::pda_emilie_positions($dispo) {}
    return [list [expr {$x + ($co - 1) * 750}] [expr {$y - $li * 750}]]
}

proc ::pda_emilie::geomName {symDes} {
    return [string range $symDes 4 end]
}

proc ::pda_emilie::getSurface {symDes} {
    if {[string range $symDes 4 6] == "tlm"} {
	return 9800
    } else {	
	set dx [string trimleft [string range $symDes 4 5] 0]
	set dy [string trimleft [string range $symDes 7 9] 0]
	return [expr {$dx*$dy}]
    }
}

proc ::pda_emilie::configPointes {} {
    GPIB::renameGPIB smu {}
    GPIB::copyGPIB smu1 smu
}

package provide pda_emilie 0.1
