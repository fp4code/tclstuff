namespace eval ::fidev::gnuplot {
    variable _gp
}

package require Tk ;# or use something like

proc ::fidev::gnuplot::vwait_with_timeout {} {
    variable _gp
    after 5000 {set _gp(DONE) Timeout}
    vwait _gp(DONE)
}

proc ::fidev::gnuplot::pg {s} {
    variable _gp
    puts $_gp(channel) $s
}

proc ::fidev::gnuplot::readable_then_read {} {
    variable _gp
    set status [catch {read $_gp(channel)} data]
    set n [string length $data]
    if {$n > 0} {
        append _gp(buffer) $data
	if {$_gp(DEBUG)} {
	    lappend _gp(pieces) $n
	}
    } elseif {[eof $_gp(channel)]} {
	if {$_gp(DEBUG)} {
	    puts stderr "end of file"
	}
        set $_gp(DONE) End
    } elseif {[fblocked $_gp(channel)]} {
	if {$_gp(DEBUG)} {
	    puts stderr "blocked"
	}
	return
    } elseif {$_gp(DEBUG)} {
	puts stderr "blocked"
	return
    } else {
	if {$_gp(DEBUG)} {
	    puts stderr "can't happen"
	}
        set $_gp(DONE) {Unexpected case}
    }
}

proc ::fidev::gnuplot::rg {} {
    variable _gp
    if {$_gp(DEBUG)} {
	puts stderr $_gp(pieces)
	set _gp(pieces) [list]
    }
    set ret $_gp(buffer)
    set _gp(buffer) ""
    return $ret
}


# Pour unix, permet de ne pas utiliser de pager
set env(PAGER) cat
# Normal gnuplot output is stderr "2>@ stdout" is necessary
set ::fidev::gnuplot::_gp(channel) [open "|gnuplot-3.8 2>@ stdout" w+]
fconfigure $::fidev::gnuplot::_gp(channel) -buffering none -blocking 0
set ::fidev::gnuplot::_gp(DEBUG) 1
set ::fidev::gnuplot::_gp(pieces) [list]
set ::fidev::gnuplot::_gp(buffer) ""
fileevent $::fidev::gnuplot::_gp(channel) readable ::fidev::gnuplot::readable_then_read

namespace eval ::fidev::gnuplot {namespace export pg rg}
namespace import fidev::gnuplot::pg ::fidev::gnuplot::rg
pg {plot sin(x)}
pg {show all}
rg

proc help_set {} {
    pg {help set}
    after 1000
    puts stderr lu
    set rg [rg]
    return $rg

}
