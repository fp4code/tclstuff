package provide TLM_CNET  0.1
package require masque 1.0

namespace eval TLM_CNET {
    
    variable blocs [list]
    foreach co {A B C D E F G H I J K L M N O P} {
        foreach li {01 02 03 04 05 06 07 08 09 10 11 12 13 14 15} {
            lappend blocs $li$co
        }
    }
    
    variable xyDispo

    set xyDispo()        {   0    0}

    set xyDispo(tlmA20)  { 170     0}
    set xyDispo(tlmB20)  { 170  -220}
    set xyDispo(tlmA40)  { 240     0}
    set xyDispo(tlmB40)  { 240  -220}
    set xyDispo(tlmA60)  { 330     0}
    set xyDispo(tlmB60)  { 330  -220}
    set xyDispo(tlmA100)  { 440    0}
    set xyDispo(tlmB100)  { 440 -220}
    set xyDispo(tlmA150)  { 590    0}
    set xyDispo(tlmB150)  { 590 -220}
    set xyDispo(tlmA200)  { 790    0}
    set xyDispo(tlmB200)  { 790 -220}
}

proc ::TLM_CNET::allSymDes {typDispo contourMasque} {
    variable xyDispo
    variable blocs
    
    if {![regexp {^([a-zA-Z]+)([0-9]+)$} $typDispo tout nature taille]} {
        return -code error "::TLM_CNET::allSymDes : cannot regexp \"$typDispo\""
    }
    set ret [list]
    switch $nature {
        "tlm" {
            set dispo $typDispo
            foreach bloc $blocs {
                foreach couche {A B} {
                    set symDes ${bloc}tlm${couche}${taille}
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
        } default {
            return {}
        }
    }
}

proc ::TLM_CNET::allTypDispo {} {
    global xyDispo
    return [array names xyDispo]
}

proc ::TLM_CNET::symDesToPos {symDes} {
    variable xyDispo
    
    set li [string trimleft [string range $symDes 0 1] 0]
    set yibloc [expr {($li-1)*(-1000)}]

    scan [string range $symDes 2 2] %c co
    scan A %c A
    set xibloc [expr {($co-$A)*2000}]

    set dispo [string range $symDes 3 end]

    if {![info exists xyDispo($dispo)]} {
        error "symDes $symDes : $dispo doit être [array names xyDispo]"
    }
    foreach {xd yd} $xyDispo($dispo) {}
    return [list [expr {$xibloc + $xd}] [expr {$yibloc + $yd}]]

}

proc ::TLM_CNET::geomName {symDes} {
    set dispo [string range $symDes 3 end]
    puts "$symDes -> $dispo"
    return $dispo
}

proc ::TLM_CNET::getSurface {symDes} {
    variable surfaceDispo
    set dispo [::TLM_CNET::geomName $symDes]
    if {![info exists surfaceDispo($dispo)]} {
	error "symDes $symDes : $dispo doit être [array names surfaceDispo]"
    }
    return $surfaceDispo($dispo)
}

proc ::TLM_CNET::triGeom {g1 g2} {
    variable orderGeom
    return [expr {$orderGeom($g1) - $orderGeom($g2)}]
}

proc ::TLM_CNET::triGeomAsFirstElem {l1 l2} {
    return [::TLM_CNET::triGeom [lindex $l1 0] [lindex $l2 0]]
}


proc ::TLM_CNET::configPointes {} {
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
