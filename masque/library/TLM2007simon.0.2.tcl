package provide TLM2007simon 0.2 ;# masque pour lapsus 2012-02
package require masque 1.0

namespace eval TLM2007simon {
    
    variable blocs [list]
    foreach li {A B C D E} {
	lappend blocs $li
    }
    
    variable yBloc

    array set yBloc {A 0 B 500 C 1000 D 1500 E 2000}

    variable xyDispo

    set xyDispo()        {   0    0}

    set xyDispo(2.5)  { 180   305}
    set xyDispo(5)  { 180   250}
    set xyDispo(10)  { 180   195}
    set xyDispo(15)  { 180   140}
    set xyDispo(20)  { 180    85}
}

proc ::TLM2007simon::allSymDes {typDispo contourMasque} {
    variable xyDispo
    variable blocs
    
    set ret [list]
    foreach bloc $blocs {
	foreach dispo {2.5 5 10 15 20} {
	    set symDes ${bloc}tlm${dispo}
	    foreach {x y} [symDesToPos $symDes] {}
	    # puts -nonewline "$symDes $x $y "
	    if {[geom2d::isInternal $contourMasque $x $y]} {
		lappend ret $symDes
		# puts YES
	    } else {
		# puts NO
	    }
	}
    }
    return $ret
}

proc ::TLM2007simon::allTypDispo {} {
    global xyDispo
    return [array names xyDispo]
}

proc ::TLM2007simon::symDesToPos {symDes} {
    variable xyDispo
    variable yBloc
    
    set li [string trimleft [string range $symDes 0 0] 0]
    if {$li == {}} {set li 0}
    set yibloc $yBloc($li)
    set xibloc [expr {0.0}]

    set dispo [string range $symDes 4 end]

    if {![info exists xyDispo($dispo)]} {
        error "symDes $symDes : $dispo doit être [array names xyDispo]"
    }
    foreach {xd yd} $xyDispo($dispo) {}
    return [list [expr {$xibloc + $xd}] [expr {$yibloc + $yd}]]
}

proc ::TLM2007simon::geomName {symDes} {
    set dispo tlm
    puts "$symDes -> $dispo"
    return $dispo
}


set rien {
proc ::TLM2007simon::getSurface {symDes} {
    variable surfaceDispo
    set dispo [::TLM_CNET::geomName $symDes]
    if {![info exists surfaceDispo($dispo)]} {
	error "symDes $symDes : $dispo doit être [array names surfaceDispo]"
    }
    return $surfaceDispo($dispo)
}

proc ::TLM2007simon::triGeom {g1 g2} {
    variable orderGeom
    return [expr {$orderGeom($g1) - $orderGeom($g2)}]
}

proc ::TLM_CNET::triGeomAsFirstElem {l1 l2} {
    return [::TLM_CNET::triGeom [lindex $l1 0] [lindex $l2 0]]
}


proc ::TLM2007simon::configPointes {} {
    gpibRename smuE {}
    gpibRename smuB {}
    gpibRename smuC {}
    gpibCopyName smu1 smuB
    gpibCopyName smu2 smuE
    gpibCopyName smu3 smuC
}

proc ::TLM_CNET::splitGeomTlm {symdes} {
    if {![regexp {^[0-9][0-9][A-Z](tlm[AB])[0-9]+$} $symdes tout couche]} {
        return -code error "::TLM_CNET::splitGeomTlm : cannot regexp \"$symdes\""
    }
    return $couche
}
} ;# rien
