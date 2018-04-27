package provide mes 0.1

# 2004-02-03 (FP) construction par déplacement à partir de mes_bipolaire 1.8

proc mes::copyParams {&from &to} {
    upvar \#0 ${&from} from
    upvar \#0 ${&to} to
    foreach key [array names from] {\
	set to($key) $from($key)
    }
}

proc mes::destroyParams {&from} {
    upvar \#0 ${&from} from
    foreach key [array names from] {
	unset from($key)
    }
}

proc mes::controlLimit {&loglo thingName unit symDes thingPerUnitOfSurface} {
    upvar ${&loglo} loglo
    upvar $thingName thing

    set family [masque::getFamily $symDes]
    set surface [::masque::getSurface $symDes]
    
    if {[info exists loglo($thingName,$family)]} {
        set thing [readUnit $loglo($thingName,$family) $unit]
        puts -nonewline stderr "******* $thingName from family"
    } else {
        set thing [expr {$surface*$thingPerUnitOfSurface}]
        puts -nonewline stderr "******* no gloglo($thingName,$family), $thingName from surface"
    }
    puts stderr " -> $thing"
}

proc mes::readUnit {data unit} {
    if {[llength $data] != 2} {
	error "$data : should be \"value unit\""
    }
    # contrôle si data est bien exprimé dans la bonne unité
    if {[lindex $data 1] != $unit} {
        error "$data : manque $unit"
    }
    return [lindex $data 0]
}

proc mes::negVal {s} {
    if {[string index $s 0] == "-"} {
	return [string range $s 1 end]
    } else {
	return "-$s"
    }
}
