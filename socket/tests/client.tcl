    proc count_to_eof {s} {
	global count done timer
	set l [gets $s]
	if {[eof $s]} {
	    incr count
	    if {$count > 9} {
		close $s
		set done true
		set count {eof is sticky}
		after cancel $timer
	    }
	}
    }
    proc timerproc {} {
	global done count c
	set done true
	set count {timer went off, eof is not sticky}
	close $c
    }	
    set count 0
    set done false
    proc write_then_close {s} {
	puts $s bye
	close $s
    }
    proc accept {s a p} {
	fconfigure $s -buffering line -translation lf
	fileevent $s writable "write_then_close $s"
    }
    set s [socket -server accept 2833]
    set c [socket [info hostname] 2833]
    fconfigure $c -blocking off -buffering line -translation lf
    fileevent $c readable "count_to_eof $c"
    set timer [after 1000 timerproc]
    vwait done
    close $s
    set count
