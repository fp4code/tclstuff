# 2007-01-11 (FP) ajout de tlm
# 2007-08-29 (FP) ajout de pea -> 1.1
# 2007-09-24 (JLP+FP) bug dans les coordonnees de pea -> 1.1

package provide pG-Lpn 1.2
package require masque 1.0

namespace eval pG-Lpn {
        
    variable xyDispo
    variable type inconnu ;# psg ou jumbo

    set xyDispo(O) [list 0 0] ;# O de PICOGIGA

    set xyDispo(psg5x5)   [list  -120 -1610]
    set xyDispo(psg5x10)  [list   130 -1610]
    set xyDispo(psg5x20)  [list   380 -1610]
    set xyDispo(psg5x40)  [list   630 -1610]
    set xyDispo(psg5x80)  [list   880 -1610]
    set xyDispo(psg10x10) [list  -120 -2050]
    set xyDispo(psg10x20) [list   130 -2050]
    set xyDispo(psg10x40) [list   380 -2050]
    set xyDispo(psg10x60) [list   630 -2050]
    set xyDispo(psg75x75) [list   880 -2050]

    set xyDispo(pea5x5)    [list   575  -645]
    set xyDispo(pea5x10)   [list   575  -945]
    set xyDispo(pea5x20)   [list   575 -1245]
    set xyDispo(pea5x40)   [list   875  -645]
    set xyDispo(pea10x10a) [list   -25  -645]
    set xyDispo(pea10x10b) [list   275  -645]
    set xyDispo(pea10x20a) [list   -25  -945]
    set xyDispo(pea10x20b) [list   875  -945]
    set xyDispo(pea10x40)  [list   -25 -1245]
    set xyDispo(pea20x20)  [list   275  -945]
    set xyDispo(pea20x60)  [list   875 -1245]
    set xyDispo(pea50x50)  [list   275 -1245]

    set xyDispo(jumbo50)  [list   1950 -2080]
    set xyDispo(jumbo75)  [list   1460 -2080]
    set xyDispo(jumbo100) [list   1460 -1590]

    set xyDispo(tlmE120)  [list   2600  -200]
    set xyDispo(tlmE80)   [list   2600  -330]
    set xyDispo(tlmE60)   [list   2600  -440]
    set xyDispo(tlmE40)   [list   2600  -530]
    set xyDispo(tlmE30)   [list   2600  -610]
    set xyDispo(tlmE20)   [list   2600  -680]
    set xyDispo(tlmE10)   [list   2600  -740]

    set xyDispo(tlmB120)  [list   2600  -1050]
    set xyDispo(tlmB80)   [list   2600  -1180]
    set xyDispo(tlmB60)   [list   2600  -1290]
    set xyDispo(tlmB40)   [list   2600  -1380]
    set xyDispo(tlmB30)   [list   2600  -1460]
    set xyDispo(tlmB20)   [list   2600  -1530]
    set xyDispo(tlmB10)   [list   2600  -1590]
}

proc ::pG-Lpn::allSymDes {typDispo contourMasque} {
    variable xyDispo
    if {$typDispo == "psg"} {
	set ret [list]
	puts stderr ::pG-Lpn::allSymDes
	foreach li {A B C D E F} {
	    foreach co {1 2 3 4 5} {
                if {"$li$co" == "F5"} continue
		foreach dispo {psg5x5 psg5x10 psg5x20 psg5x40 psg5x80 psg10x10 psg10x20 psg10x40 psg10x60 psg75x75} {
		    set symDes $li$co$dispo
		    foreach {x y} [symDesToPos $symDes] {}
		    puts stderr "$x $y"
		    if {[geom2d::isInternal $contourMasque $x $y]} {
			lappend ret $symDes
		    }
		}
	    }
	}
	return $ret
    } elseif {$typDispo == "pea"} {
	set ret [list]
	puts stderr ::pG-Lpn::allSymDes
	foreach li {A B C D E F} {
	    foreach co {1 2 3 4 5} {
                if {"$li$co" == "F5"} continue
		foreach dispo {pea5x5 pea5x10 pea5x20 pea5x40 pea10x10a pea10x10b pea10x20a pea10x20b pea10x40 pea20x20 pea20x60 pea50x50} {
		    set symDes $li$co$dispo
		    foreach {x y} [symDesToPos $symDes] {}
		    puts stderr "$x $y"
		    if {[geom2d::isInternal $contourMasque $x $y]} {
			lappend ret $symDes
		    }
		}
	    }
	}
	return $ret
    } elseif {$typDispo == "jumbo"} {
	set ret [list]
	puts stderr ::pG-Lpn::allSymDes
	foreach li {A B C D E F} {
	    foreach co {1 2 3 4 5} {
                if {"$li$co" == "F5"} continue
		foreach dispo {jumbo50 jumbo75 jumbo100} {
		    set symDes $li$co$dispo
		    foreach {x y} [symDesToPos $symDes] {}
		    # puts stderr "$symDes  $x $y -> [geom2d::isInternal $contourMasque $x $y]"
		    if {[geom2d::isInternal $contourMasque $x $y]} {
			lappend ret $symDes
		    }
		}
	    }
	}
	return $ret
    } elseif {[string match tlm* $typDispo]} {
	set size [string range $typDispo 3 end]
	if {$size == ""} {
	    return -code error "il faut tlm10..tlm120"
	}
	puts stderr "typDispo = \"$typDispo\", size = \"$size\""
	set ret [list]
	puts stderr ::pG-Lpn::allSymDes
	foreach li {A B C D E F} {
	    foreach co {1 2 3 4 5} {
                if {"$li$co" == "F5"} continue
		foreach dispo [list tlmE$size tlmB$size] {
		    set symDes $li$co$dispo
		    foreach {x y} [symDesToPos $symDes] {}
		    puts stderr "$symDes  $x $y -> [geom2d::isInternal $contourMasque $x $y]"
		    if {[geom2d::isInternal $contourMasque $x $y]} {
			lappend ret $symDes
		    }
		}
	    }
	}
	return $ret
    } else {
	return -code error "bad typeDispo \"typeDispo\""
    }
    return {}
}

proc ::pG-Lpn::allTypDispo {} {
    # rajouter les autres
    return [list psg pea jumbo tlm10 tlm20 tlm30 tlm40 tlm60 tlm80 tlm120] ;# pont sous-gravé
}

proc recodeIt_toASCII { char } {
    scan $char %c value
    return $value
}

proc ::pG-Lpn::symDesToPos {symDes} {
    variable xyDispo
    
    set li [string index $symDes 0]
    set co [string index $symDes 1]
    set dispo [string range $symDes 2 end] 

    set xbloc [expr {($co - 1) * (-3500)}]

    set ybloc [expr {([recodeIt_toASCII $li]-[recodeIt_toASCII A]) * (3500)}]

    if {![info exists xyDispo($dispo)]} {
	error "symDes $symDes : $dispo doit être [array names xyDispo]"
    }
    return [list \
		[expr {$xbloc + [lindex $xyDispo($dispo) 0]}]\
		[expr {$ybloc + [lindex $xyDispo($dispo) 1]}]]
}

proc ::pG-Lpn::geomName {symDes} {
    set dispo [string range $symDes 2 end]
    puts "$symDes -> $dispo"
    return $dispo
}

proc ::pG-Lpn::getSurface {symDes} {
    variable xyDispo
    variable surfaceDispo
    global gloglo
    set dispo [::pG-Lpn::geomName $symDes]
    if {![info exists xyDispo($dispo)]} {
	error "symDes $symDes : $dispo doit être [array names xyDispo]"
    }
    if {[string match psg* $dispo]} {
	set dims [split [string range $dispo 3 end] "x"]
	set l [lindex $dims 0]
	set L [lindex $dims 1]

	set em 0.0
	set surface [expr {($l - $em) * ($L - $em) }] 
	puts stderr "dims = [expr {($l - $em)}]x[expr {($L - $em)}], surface = $surface um-2"
	return $surface
    } elseif {[string match pea* $dispo]} {
	if {![regexp {^([0-9]+)x([0-9]+)[ab]*$} [string range $dispo 3 end] tout l L]} {
	    return -code error "cannot regexp $dispo"
	}

	set em 0.0
	set surface [expr {($l - $em) * ($L - $em) }] 
	puts stderr "dims = [expr {($l - $em)}]x[expr {($L - $em)}], surface = $surface um-2"
	return $surface
    } elseif {[string match jumbo* $dispo]} {
	set l [string range $dispo 5 end]
	set L $l

	set em 0.0
	set surface [expr {($l - $em) * ($L - $em) }] 
	puts stderr "dims = [expr {($l - $em)}]x[expr {($L - $em)}], surface = $surface um-2"
	return $surface
    }
    return -code error "dispo non codé dans pG-Lpn.tcl : $dispo"
}


proc ::pG-Lpn::triGeom {g1 g2} {
    foreach {l1 L1} [split $g1 x] {}
    foreach {l2 L2} [split $g2 x] {}
    if {$l1 < $l2} {return -1}
    if {$l1 > $l2} {return 1}
    if {$L1 < $L2} {return -1}
    if {$L1 > $L2} {return 1}
    return 0
}

proc ::pG-Lpn::triGeomAsFirstElem {l1 l2} {
    return [::pG-Lpn::triGeom [lindex $l1 0] [lindex $l2 0]]
}

proc ::pG-Lpn::configPointes {} {
    variable type

    
    switch $type {
	psg {
	    GPIB::renameGPIB smuE {}
	    GPIB::renameGPIB smuB {}
	    GPIB::renameGPIB smuC {}
	    GPIB::copyGPIB smu1 smuE
	    GPIB::copyGPIB smu2 smuB
	    GPIB::copyGPIB smu3 smuC
	}
	jumbo {
	    GPIB::renameGPIB smuE {}
	    GPIB::renameGPIB smuB {}
	    GPIB::renameGPIB smuC {}
	    GPIB::copyGPIB smu1 smuC
	    GPIB::copyGPIB smu2 smuB
	    GPIB::copyGPIB smu3 smuE
	}
	default {
	    return -code error "La variable \"::pG-Lpn::type\" contient \"$type\" au lieu d'une des valeurs \"[allTypDispo]\""
	}
    }
}
