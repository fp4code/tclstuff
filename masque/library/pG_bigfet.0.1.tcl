namespace eval pG_bigfet {
    
    variable blocs [list]
    foreach li {01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20} {
        foreach co {A B C D E F G H I J K L M N O P Q R S T} {
            lappend blocs $li$co
        }
    }
    
    variable surfaceDispo

    foreach ico {1 2 4} {
	foreach ili {2A 2B 4A 4B 6A 6B} {
	    # bidon
            set surfaceDispo(fetG$ico$ili) 1
	}
    }

    variable xyDispo

    set xyDispo()        {   0    0}

    # TLM horizontal
    set xyDispo(tlmA5)   { -528  -2030}
    set xyDispo(tlmA10)  { -445  -2030}
    set xyDispo(tlmA20)  { -355  -2030}
    set xyDispo(tlmA30)  { -255  -2030}
    set xyDispo(tlmA40)  { -145  -2030}

    # TLM 30 degres
    set xyDispo(tlmB5)   {   67   -955}
    set xyDispo(tlmB10)  {  138   -996}
    set xyDispo(tlmB20)  {  216  -1041}
    set xyDispo(tlmB30)  {  303  -1091}
    set xyDispo(tlmB40)  {  398  -1146}

    # TLM 60 degres
    set xyDispo(tlmC5)   { -735   -945}
    set xyDispo(tlmC10)  { -694  -1016}
    set xyDispo(tlmC20)  { -649  -1094}
    set xyDispo(tlmC30)  { -599  -1181}
    set xyDispo(tlmC40)  { -544  -1276}

    # TLM verticaux
    set xyDispo(tlmD5)   {  440  -1567}
    set xyDispo(tlmD10)  {  440  -1650}
    set xyDispo(tlmD20)  {  440  -1740}
    set xyDispo(tlmD30)  {  440  -1840}
    set xyDispo(tlmD40)  {  440  -1950}
}

proc ::pG_bigfet::allSymDes {typDispo contourMasque} {
    variable blocs
    
    set ret [list]
    if {[string match tlm* $typDispo]} {
	set asd [list]
	foreach d {5 10 20 30 40} { 
	    lappend asd $typDispo$d
	}
    } elseif {[string match fetG* $typDispo]}  {
	set asd [list]
	foreach g {1 2 4} {
	    foreach e {6A 4A 2A 6B 4B 2B} {
                lappend asd $typDispo$g$e
	    }
	}
    } else {error "bad typDispo \"$typDispo\""}

    foreach bloc $blocs {
	foreach dispo $asd {
	    set symDes $bloc$dispo
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

proc ::pG_bigfet::allTypDispo {} {
    return {fetG tlmA tlmB tlmC tlmD}
}

proc ::pG_bigfet::symDesToPos {symDes} {
    variable blocs
    variable xyDispo
    
    set bloc0 [lindex $blocs 0]

    scan [string range $symDes 2 2] %c co
    scan [string range $bloc0  2 2] %c co0
    set xibloc [expr {($co-$co0)*(4100)}]

    set li  [string trimleft [string range $symDes 0 1] 0]
    set li0 [string trimleft [string range $bloc0  0 1] 0]
    set yibloc [expr {($li-$li0)*(-4000)}]

#puts stderr "[string range $symDes 0 2] -> $xibloc,$yibloc"

    set dispo [string range $symDes 3 end]
    if {[string match fetG* $dispo]} {
	set ix [string index $dispo 4]
	set siy [string range $dispo 5 6]
	switch $siy {
	    "6A" {set iy 0}
	    "4A" {set iy 1}
	    "2A" {set iy 2}
	    "6B" {set iy 3}
	    "4B" {set iy 4}
	    "2B" {set iy 5}
	    default {error "bad siy \"$siy\""}
	}
	switch $ix {
	    "1" {set xx 1220; set yy [expr {-355+($iy)*(-130)}]}
	    "2" {set xx 1590; set yy [expr {-355+($iy)*(-132)}]}
	    "4" {set xx 1960; set yy [expr {-355+($iy)*(-134)}]}
	    default {error "bad ix for \"$dispo\""}
	}
        return [list [expr {$xibloc + $xx}] [expr {$yibloc + $yy}]]
    } elseif {[string match tlm* $dispo]} {
        if {![info exists xyDispo($dispo)]} {
            error "symDes $symDes : $dispo doit être [array names xyDispo]"
        }
        foreach {xx yy} $xyDispo($dispo) {}
        return [list [expr {$xibloc + $xx}] [expr {$yibloc + $yy}]]
    } elseif {[string match origin $dispo]} {
        return [list $xibloc $yibloc]
    } else {
	error "Bad dispo \"$dispo\""
    }
}

proc ::pG_bigfet::geomName {symDes} {
    set dispo [string range $symDes 3 end]
    puts "$symDes -> $dispo"
    return $dispo
}

proc ::pG_bigfet::getSurface {symDes} {
    variable surfaceDispo
    set dispo [::pG_bigfet::geomName $symDes]
    if {![info exists surfaceDispo($dispo)]} {
	error "symDes $symDes : $dispo doit être [array names surfaceDispo]"
    }
    return $surfaceDispo($dispo)
}

proc ::pG_bigfet::triGeom {g1 g2} {
    variable orderGeom
    return [expr {$orderGeom($g1) - $orderGeom($g2)}]
}

proc ::pG_bigfet::triGeomAsFirstElem {l1 l2} {
    return [::pG_bigfet::triGeom [lindex $l1 0] [lindex $l2 0]]
}


proc ::pG_bigfet::configPointes {} {
    gpibRename smuE {}
    gpibRename smuB {}
    gpibRename smuC {}
    gpibCopyName smu1 smuB
    gpibCopyName smu2 smuE
    gpibCopyName smu3 smuC
}

proc ::pG_bigfet::splitGeomTlm {symdes} {
    if {![regexp {^[A-Z][0-9][0-9](tlm[ABCD])[0-9]+$} $symdes tout couche]} {
        return -code error "::pG_bigfet::splitGeomTlm : cannot regexp \"$symdes\""
    }
    return $couche
}

package provide pG_bigfet 0.1