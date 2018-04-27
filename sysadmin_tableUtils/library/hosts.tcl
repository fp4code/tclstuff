# 2000/02/01 (FP)

set MASTER l2m

proc niscathosts {} {
    global MASTER
    set lignes [exec rsh -n $MASTER niscat hosts.org_dir]
    set lignes [split $lignes \n]
    foreach l $lignes {
        set data [split $l " "]
        set nom [lindex $data 0]
        set alias [lindex $data 1]
        set ip [lindex $data 2]
        set comment [join [lrange $data 3 end] " "]
        if {![info exists NOMS($ip)]} {
	    set NOM($ip) $nom
	} else {
	    if {$NOM($ip) != $nom} {
		return -code error "pour ip = $ip, deux noms : $NOM($ip) et $nom"
	    }
	}
        if {$alias != $nom} {
	    lappend ALIASES($ip) $alias
	}
	if {![info exists COMMENT($ip)]} {
	    set COMMENT($ip) $comment
	} else {
	    if {$COMMENT($ip) != {} && $comment != {} && $COMMENT($ip) != $comment} {
		return -code error "pour ip = $ip, deux comments : \"$COMMENT($ip)\" et \"$comment\""
	    }
	}
    }
    return [listhosts NOM ALIASES COMMENT]
}

proc listhosts {NOMarr ALIASESarr COMMENTarr} {
    upvar $NOMarr NOM
    upvar $ALIASESarr ALIASES
    upvar $COMMENTarr COMMENT
    
    set lignes [list]

    foreach ip [lsort -command compip [array names NOM]] {
	set ligne [list]
	lappend ligne $ip
	set nom [list $NOM($ip)]
	if {[info exists ALIASES($ip)]} {
	    lappend ligne [concat $nom $ALIASES($ip)]
	} else {
	    lappend ligne $nom
	}
	if {[info exists COMMENT($ip)]} {
	    lappend ligne $COMMENT($ip)
	} else {
	    lappend ligne {}
	}
	lappend lignes $ligne
    }
    return $lignes
}

proc printhosts {lignes} {
    set maxlen 0
    foreach ligne $lignes {
	set len [string length [lindex $ligne 1]]
	if {$len > $maxlen} {
	    set maxlen $len
	}
    }
    set fl [list]
    foreach ligne $lignes {
	if {[lindex $ligne 2] != ""} {
	    set comment " # [lindex $ligne 2]"
	} else {
	    set comment ""
	}
	lappend fl "[format %-15s [lindex $ligne 0]] [format %-${maxlen}s [lindex $ligne 1]]$comment"
    }
    return $fl
}

proc compip {sip1 sip2} {
    set ip1 [split $sip1 .]
    set ip2 [split $sip2 .]
    if {[llength $ip1] != 4} {
	return -code error "bad IP \"$sip1\""
    }
    if {[llength $ip2] != 4} {
	return -code error "bad IP \"$sip2\""
    }
    foreach v1 $ip1 v2 $ip2 {
	if {$v1 < 0 || $v1 > 255} {
	    return -code error "bad IP \"$sip1\""
	}
	if {$v2 < 0 || $v2 > 255} {
	    return -code error "bad IP \"$sip2\""
	}
	if {$v1 < $v2} {
	    return -1
	}
	if {$v1 > $v2} {
	    return 1
	}
    }
    return 0
}

proc etchosts {} {
    set f [open /etc/hosts RDONLY]
    set lignes [read -nonewline $f]
    close $f
    set lignes [split $lignes \n]

    foreach l $lignes {
	set i [string first # $l]
	if {$i < 0} {
	    set data $l
	    set comment ""
	} else {
	    set data [string range $l 0 [expr {$i - 1}]]
	    set comment [string trim [string range $l [expr {$i + 1}] end]]
	}
	if {[llength $data] == 0} {
	    continue
	}
	if {[llength $data] == 1} {
	    return -code error "ligne \"$l\" incorrecte"
	}
	set ip [lindex $data 0]
	set NOM($ip) [lindex $data 1]
	if {[llength $data] > 2} {
	    set ALIASES($ip) [lrange $data 2 end]
	}
	if {$comment != {}} {
	    set COMMENT($ip) $comment
	}
    }
    return [listhosts NOM ALIASES COMMENT]
}

proc diff {h1 h2} {
    set i1 0
    set i2 0
    set end1 [llength $h1]
    set end2 [llength $h2]
    set abs1 [list]
    set abs2 [list]
    set dnom [list]
    set dcomment [list]
    while 1 {
	if {$i1 >= $end1} {
	    if {$i2 >= $end2} {
		break
	    }
	    lappend abs2 [lindex $h2 $i2]
	    incr i2
	} elseif {$i2 >= $end2} {
	    lappend abs1 [lindex $h1 $i1]
	    incr i1
	}
	set l1 [lindex $h1 $i1]
	set l2 [lindex $h2 $i2]
	set ip1 [lindex $l1 0]
	set ip2 [lindex $l2 0]
	set nom1 [lindex $l1 1]
	set nom2 [lindex $l2 1]
	set comment1 [lindex $l1 2]
	set comment2 [lindex $l2 2]
	set comp [compip $ip1 $ip2]
	if {$comp < 0} {
	    lappend abs1 $l1
	    incr i1 
	} elseif {$comp > 0} {
	    lappend abs2 $l2
	    incr i2
	} else {
	    if {$nom1 != $nom2} {
		lappend dnom [list $l1 $l2]
	    } elseif {$comment1 != $comment2} {
		lappend dcomment [list $l1 $l2]
	    }
	    incr i1
	    incr i2
	}
    }
    if {$abs1 != {}} {
	puts "sur seul premier:"
	puts ""
	foreach l $abs1 {
	    puts $l
	}
	puts ""
    }
    if {$abs2 != {}} {
	puts "sur seul second:"
	puts ""
	foreach l $abs2 {
	    puts $l
	}
	puts ""
    }
    if {$dnom != {}} {
	puts "Différences de nom:"
	foreach ll $dnom {
	    puts ""
	    puts [lindex $ll 0]
	    puts [lindex $ll 1]
	}
	puts ""
    }
    if {$dcomment != {}} {
	puts "Différences de commentaires:"
	foreach ll $dcomment {
	    puts ""
	    puts [lindex $ll 0]
	    puts [lindex $ll 1]
	}
	puts ""
    }
}

set h1 [niscathosts]
set h2 [etchosts]
diff $h1 $h2