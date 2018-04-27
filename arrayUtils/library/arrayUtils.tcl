package provide arrayUtils 1.0

namespace eval ::arrayUtils {}

proc ::arrayUtils::addReverseIndexes {toName fromName args} {
    upvar $toName to
    upvar $fromName from
    if {$args == {}} {
	foreach i [array names from] {
	    set v $from($i)
	    if {[info exists to($v)]} {
		if {$to($v) != $i} {
		    error "\"${toName}($v)\" exists, \"$to($v)\" cannot be replaced by \"$i\""
		}
	    } else {
		set to($v) $i
	    }
	}
    } elseif {$args == "-nowarn"} {
	foreach i [array names from] {
	    set to($from($i)) $i
	}
    } else {
	error "if not omitted, argument 3 of ::arrayUtils::addReverseIndexes should be \"-nowarn\""
    }
    return {}
}
