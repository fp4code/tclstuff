package provide tbs2 1.0
package require masque 1.0
package require mes 0.1

namespace eval tbs2 {
    
    variable blocTbs [list         \
	    00 01 02 03 04 05 06 07 08 \
	    10 11 12 13    15 16 17 18 \
	    20 21    23 24 25    27 28 \
	    30 31 32    34    36 37 38 \
	    40    42 43 44 45 46    48 \
	    50 51 52    54    56 57 58 \
	    60 61    63 64 65    67 68 \
	    70 71 72 73    75 76 77 78 \
	    80 81 82 83 84 85 86 87 88]
    variable xyBlocTbs
    foreach b $blocTbs {
        set li [string index $b 0]
        set co [string index $b 1]
        set xyBlocTbs($b) [list [expr $co*2000] [expr -$li*2000]]
    }
    
    variable xyDispo
    set ERREURavant_1999_01_21 {
	set xyDispo(8x27) [list    0    0]
	set xyDispo(5x10) [list  500    0]
	set xyDispo(5x54) [list 1000    0]
	set xyDispo(5x7)  [list 1500    0]
	set xyDispo(5x40) [list    0 -250]
	set xyDispo(6x20) [list  500 -250]
	set xyDispo(5x17) [list 1000 -250]
	set xyDispo(7x45) [list 1500 -250]
    }
    set xyDispo(5x40) [list    0    0]
    set xyDispo(6x20) [list  500    0]
    set xyDispo(5x17) [list 1000    0]
    set xyDispo(7x45) [list 1500    0]
    set xyDispo(8x27) [list    0 -250]
    set xyDispo(5x10) [list  500 -250]
    set xyDispo(5x54) [list 1000 -250]
    set xyDispo(5x7)  [list 1500 -250]
    
    variable blocTest [list        \
                                   \
                    14             \
              22          26       \
                 33    35          \
           41                47    \
                 53    55          \
              62          66       \
                    74             \
                                   ]
    variable xyBlocTest
    foreach b $blocTest {
        set li [string index $b 0]
        set co [string index $b 1]
        set xyBlocTest($b) [list $co*2000 -$li*2000]
    }
}

proc ::tbs2::allSymDes {typDispo contourMasque} {
    variable blocTbs
    if {$typDispo == "tbs"} {
	set ret [list]
	foreach bloc $blocTbs {
	    foreach ABC {A B C} {
		foreach dispo {8x27 5x10 5x54 5x7 5x40 6x20 5x17 7x45} {
		    set symDes $bloc$ABC$dispo
		    foreach {x y} [symDesToPos $symDes] {}
		    if {[geom2d::isInternal $contourMasque $x $y]} {
			lappend ret $symDes
		    }
		}
	    }
	}
	return $ret
    }
}

proc ::tbs2::allTypDispo {} {
    # rajouter les autres
    return [list tbs]
}

proc ::tbs2::symDesToPos {symDes} {
    #puts $symDes
    variable blocTbs
    variable xyBlocTbs
    variable xyDispo
    
    set lico [string range $symDes 0 1]
    
    if {[info exists xyBlocTbs($lico)]} {
	# bloc tbs
	foreach {xibloc yibloc} $xyBlocTbs($lico) {}
	
	set yABC(A) 0
	set yABC(B) -500 
	set yABC(C) -1000
	set ABCbloc [string range $symDes 2 2]
	if {![info exists yABC($ABCbloc)]} {
	    error "symDes $symDes : $ABCbloc doit être A, B ou C"
	}
	set xABCbloc 0
	set yABCbloc $yABC($ABCbloc)
	
	set dispo [string range $symDes 3 end]
	if {![info exists xyDispo($dispo)]} {
	    error "symDes $symDes : $dispo doit être [array names xyDispo]"
	}
	foreach {xd yd} $xyDispo($dispo) {}
	return [list [expr $xibloc + $xABCbloc + $xd] \
		[expr $yibloc + $yABCbloc + $yd]]
    } else {
	error "bloc $lico ([lindex $lico 1]/[lindex $lico 0]) non traitable"
    }
}

proc ::tbs2::geomName {symDes} {
    set dispo [string range $symDes 3 end]
    puts "$symDes -> $dispo"
    return $dispo
}

proc ::tbs2::getSurface {symDes} {
    variable xyDispo
    variable surfaceDispo
    global gloglo
    set dispo [::tbs2::geomName $symDes]
    if {![info exists xyDispo($dispo)]} {
	error "symDes $symDes : $dispo doit être [array names xyDispo]"
    }
    set dims [split $dispo "x"]
    set l [lindex $dims 0]
    set L [lindex $dims 1]
    if {$l == 5 && $L == 40} {
	set l 5.5
    }

    set em [mes::readUnit $gloglo(ecartLargeurAuMasque) um]
    set surface [expr {($l - $em) * ($L - $em) }] 
    puts stderr "dims = [expr {($l - $em)}]x[expr {($L - $em)}], surface = $surface um-2"
    return $surface
}

proc ::tbs2::triGeom {g1 g2} {
    foreach {l1 L1} [split $g1 x] {}
    foreach {l2 L2} [split $g2 x] {}
    if {$l1 < $l2} {return -1}
    if {$l1 > $l2} {return 1}
    if {$L1 < $L2} {return -1}
    if {$L1 > $L2} {return 1}
    return 0
}

proc ::tbs2::triGeomAsFirstElem {l1 l2} {
    return [::tbs2::triGeom [lindex $l1 0] [lindex $l2 0]]
}

proc ::tbs2::configPointes {} {
    GPIB::renameGPIB smuE {}
    GPIB::renameGPIB smuB {}
    GPIB::renameGPIB smuC {}
    GPIB::copyGPIB smu1 smuB
    GPIB::copyGPIB smu2 smuE
    GPIB::copyGPIB smu3 smuC
}
