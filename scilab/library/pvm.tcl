
set HELP(::scilab) {
    package require fidev; package require scilab




    set tid [::scilab::pvm_spawn [file join [file dirname [info script]] .. .. .. scilab essai_pvm esclave.sce]
    ::scilab::pvm_sendScalars $tid 3 3 DOUBLE {1 2 3 4 5 6 7 8 9}
    ::scilab::pvm_sendScalars $tid 2 2 COMPLEX {1 2 3 4 1 2 3 4}
    ::scilab::pvm_sendString $tid {a = %var}
    ::scilab::pvm_sendString $tid {v = spec(A)}
    ::scilab::pvm_sendString $tid "pvm_send([::pvm::mytid], v, 0)"
    ::scilab::pvm_recv $tid
    ::scilab::pvm_sendString $tid "pvm_send([::pvm::mytid], a, 0)"
    ::scilab::pvm_recv $tid

    set tid [::scilab::pvm_spawn /home/fab/A/fidev/scilab/essai_pvm/esclave.sce]
    ::scilab::put $tid a 3 3 DOUBLE {1 2 3 4 5 6 7 8 9}
    ::scilab::exec $tid v=spec(A)
    ::scilab::get $tid v

    ::scilab::exec $tid x=1+2
    ::scilab::get $tid x

    ::scilab::exec $tid {a = 'coucou'}
    ::scilab::get $tid a

}


set SCICHARSP [list\
	0 1 2 3 4 5 6 7 8 9\
	a b c d e f g h i j\
	k l m n o p q r s t\
	u v w x y z _ # ! \$\
      { } ( ) \; : + - * / \\\
	= . , ' \[ \] % | & <\
	> ~ ^]

set SCICHARSM [list\
	0 1 2 3 4 5 6 7 8 9\
	A B C D E F G H I J\
	K L M N O P Q R S T\
	U V W X Y Z {} {} ? {}\
        {} {} {} {} {} {} {} {} {} \$\
	{} {} {} \" \{ \} {} {} {} `\
	{} @ {}]

set i 0
foreach c $SCICHARSM {
    set SCICHARVAL($c) $i
    incr i -1
} 
set i 0
foreach c $SCICHARSP {
    set SCICHARVAL($c) $i
    incr i 1
} 

proc ::scilab::stringMatrix {l} {
    global SCICHARSM SCICHARSP
    set strings [list]
    set nli [lindex $l 1]
    set nco [lindex $l 2]
    set n [expr {$nli*$nco}]
    set pointers [lrange $l 4 [expr {$n + 4}]]
    set datas [lrange $l [expr {$n + 5}] end]
    for {
	set i 1
	set p1 [expr {[lindex $pointers 0] - 1}]
    } {
	$i <= $n
    } {
	incr i
	set p1 $p2
    } {
	set p2 [expr {[lindex $pointers $i] - 1}]
	set s ""
	for {set ii $p1} {$ii < $p2} {incr ii} {
	    set c [lindex $datas $ii]
	    if {$c >= 0} {
		set c [lindex $SCICHARSP $c]
	    } else {
		set c [lindex $SCICHARSM [expr {-$c}]]
	    }
	    append s $c
	}
	lappend strings $s
    }
    return [list STRING $nli $nco $strings]
}

proc ::scilab::interprete {paire} {
    set l1 [lindex $paire 0]
    set l2 [lindex $paire 1]
    set type [lindex $l1 0]
    if {$type == 10} {
	if {$l2 != {}} {
	    error "STRINGS: l2 != {}"
	}
        return [::scilab::stringMatrix $l1]
    } elseif {$type == 1} {
	set nli [lindex $l1 1]
	set nco [lindex $l1 2]
	set n [expr {$nli*$nco}]
	if {[lindex $l1 3] == 0} {
	    return [list $nli $nco DOUBLE [lrange $l2 0 [expr {$n-1}]]]
	} elseif {[lindex $l1 3] == 1} {
	    return [list $nli $nco COMPLEX\
		    [lrange $l2 0 [expr {2*$n-1}]]]
	} else {
	    error "SCALAR  unknown type: [lindex $l1 3]"
	}
    } elseif {$type == 4} {
	set nli [lindex $l1 1]
	set nco [lindex $l1 2]
	set n [expr {$nli*$nco}]
	return [list BOOLEAN $nli $nco [lrange $l1 3 [expr {$n+2}]]]
    } elseif {$type == 2} {
	set nli [lindex $l1 1]
	set nco [lindex $l1 2]
	set n [expr {$nli*$nco}]
	if {[lindex $l1 3] == 0} {
	    return [list DOUBLEPOLY $nli $nco]
	} elseif {[lindex $l1 3] == 1} {
	    return [list COMPLEXPOLY $nli $nco]
	} else {
	    error "POLY unknown type: [lindex $l1 3]"
	}
    }
}

proc ::scilab::put {tid scivar nli nco type datas} {
    ::scilab::pvm_sendScalars $tid $nli $nco $type $datas
    ::scilab::pvm_sendString $tid "$scivar = %var"
}

proc ::scilab::exec {tid cmd} {
    ::scilab::pvm_sendString $tid $cmd
}

proc ::scilab::get {tid scivar} {
    ::scilab::pvm_sendString $tid "pvm_send([::pvm::mytid], $scivar, 0)"
    return [::scilab::interprete [lrange [::scilab::pvm_recv $tid] 2 end]]
}

proc ::scilab::flush {tid} {
    while {[::pvm::probe $tid -1] > 0} {
	::scilab::pvm_recv $tid
    }
}
