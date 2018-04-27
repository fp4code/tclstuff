#package provide microCIS_plots 0.1 ; # (FP) 2013-05-16
package require masque 1.0

namespace eval microCIS_plots {
    variable surfaces
    array set surfaces {
	A 204282
	B 53093
	C 20106
	D 5675
	E 2827
	F 1590
	G 962
	H 707
	I 491
	J 314
	K 227
	L 177
	M 133
	N  79
	O 38
	Z 10065977
    }
}

proc ::microCIS_plots::allSymDes {typDispo contourMasque} {
    if {$typDispo == "microCIS_plots"} {
        set dispos [list]
	foreach co0 {0 1 2 3} {
	    foreach li0 {0 1 2 3} {
		set lico0 $li0$co0
		if {$lico0 == "30"} {
		    puts "Z30"
		    lappend dispos Z30
		} elseif {$co0 <= 2} {
		    foreach {type lico1} {D 00 C 01 B 02 A 03 H 10 G 11 F 12 E 13 L 20 K 21 J 22 I 23 O 31 N 32 M 33} {
			lappend dispos $type${lico0}$lico1
		    }
		} else {
		    foreach co1 {0 1 2} {
			lappend dispos A${lico0}3$co1
			lappend dispos B${lico0}2$co1
		    }
		    foreach co1 {5 6 7} {
			lappend dispos A${lico0}1$co1 ;# VERIFIER
			lappend dispos B${lico0}0$co1 ;# VERIFIER
		    }
		    foreach {type lico1 lico2} {
			C 33 10 D 33 11 E 34 10 F 34 11 G 35 10 H 35 11 I 36 10 J 36 11 K 37 10 L 37 11  
			C 33 00 D 33 01 E 34 00 F 34 01 G 35 00 H 35 01 I 36 00 J 36 01 K 37 00 L 37 01
			C 23 10 D 23 11 E 24 10 F 24 11 G 25 10 H 25 11 I 26 10 J 26 11 K 27 10 L 27 11
			M 23 00 M 23 01 M 24 00 N 24 01 N 25 00 N 25 01 O 26 00 O 26 01 O 27 00} {
			lappend dispos $type$lico0$lico1$lico2
		    }
		    foreach {type lico1 lico2} {
			L 10 10 K 10 11 J 11 10 I 11 11 H 12 10 G 12 11 F 13 10 E 13 11 D 14 10 C 14 11  
			L 10 00 K 10 01 J 11 00 I 11 01 H 12 00 G 12 01 F 13 00 E 13 01 D 14 00 C 14 01
			L 00 10 K 00 11 J 01 10 I 01 11 H 02 10 G 02 11 F 03 10 E 03 11 D 04 10 C 04 11
			        O 00 01 O 01 00 O 01 01 N 02 00 N 02 01 N 03 00 M 03 01 M 04 00 M 04 01} {
			lappend dispos $type$lico0$lico1$lico2
		    }
		}
	    }
	}
	set ret [list]
	foreach symDes $dispos {
	    foreach {x y} [symDesToPos $symDes] {}
	    if {[geom2d::isInternal $contourMasque $x $y]} {
		lappend ret $symDes
		# puts YES
	    } else {
		puts NO
	    }
	}
    }
    return $ret
}

proc ::microCIS_plots::allTypDispo {} {
    return [list microCIS_plots]
}

proc ::microCIS_plots::symDesToPos {symDes} {
    set li0 [string index $symDes 1]
    set co0 [string index $symDes 2]
    if {[string length $symDes] == 3} {
	return [list [expr {$co0*4000 + 500}] [expr {$li0*4000 + 150}]]
    }
    set li1 [string index $symDes 3]
    set co1 [string index $symDes 4]
    if {[string length $symDes] == 5} {
	return [list [expr {$co0*4000 + $co1*1000 + 500}] [expr {$li0*4000 + $li1*1000 + 150}]]	
    }
    set li2 [string index $symDes 5]
    set co2 [string index $symDes 6]
    return  [list [expr {$co0*4000 + $co1*1000 + $co2*500 + 300}] [expr {$li0*4000 + $li1*1000 + $li2*500 + 150}]]	
}

proc ::microCIS_plots::geomName {symDes} {
    return [string index $symDes 0]
}

proc ::microCIS_plots::getSurface {symDes} {
    return $::microCIS_plots::surfaces([::microCIS_plots::geomName $symDes])
}

proc ::microCIS_plots::configPointes {} {
    GPIB::renameGPIB smuA {}
    GPIB::renameGPIB smuK {}
    GPIB::copyGPIB smu1 smuA
    GPIB::copyGPIB smu3 smuK
}

package provide microCIS_plots 0.1 ; # (FP) 2013-05-16
