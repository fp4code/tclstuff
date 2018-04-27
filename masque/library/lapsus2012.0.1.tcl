# masque pour lapsus_detect_V2 et lapsus_source_V2 (Simon Vassant 2011-2012)

package provide lapsus2012 0.1
package require masque 1.0

namespace eval lapsus2012 {
    
    variable blocs [list]
    foreach li {A B C D E F G H I J} {
	foreach co {01 02 03 04 05 06 07 08 09 10} {
	    lappend blocs $li$co
	}
    }
    
    variable ixBloc
    variable iyBloc

    array set iyBloc {A 0 B 1 C 2 D 3 E 4 F 5 G 6 H 7 I 8 J 9}
    array set ixBloc {01 0 02 1 03 2 04 3 05 4 06 5 07 6 08 7 09 8 10 9}
}

proc ::lapsus2012::allSymDes {typDispo contourMasque} {
    variable xyDispo
    variable blocs
    
    set ret [list]
    foreach bloc $blocs {
	set symDes ${bloc}
	foreach {x y} [symDesToPos $symDes] {}
	# puts -nonewline "$symDes $x $y "
	if {[geom2d::isInternal $contourMasque $x $y]} {
	    lappend ret $symDes
	    # puts YES
	} else {
	    # puts NO
	}
    }
    return $ret
}

proc ::lapsus2012::allTypDispo {} {
    global xyDispo
    return [array names xyDispo]
}

proc ::lapsus2012::symDesToPos {symDes} {
    variable ixBloc
    variable iyBloc
    
    set li [string range $symDes 0 0]
    set yibloc [expr {($iyBloc($li))*(425)}]
    set co [string range $symDes 1 2]
    set xibloc [expr {($ixBloc($co))*(403)}]

    return [list [expr {$xibloc}] [expr {$yibloc}]]
}

proc ::lapsus2012::geomName {symDes} {
    set dispo fet
    puts "$symDes -> $dispo"
    return $dispo
}

