package provide email 0.1

namespace eval ::email {}

proc ::email::splitField {f} {
    set fs [split $f .]
    set lf [list]
    set i [llength $fs]
    for {incr i -1} {$i >= 0} {incr i -1} {
	set t [lindex $fs $i]
	set t [string trim $t { }]
	if {$t == {}} {
	    error ""
	}
	lappend lf $t
    }
    return $lf
}

proc ::email::sortEmails {lines} {
    set il 0
    foreach l $lines {
	incr il
	set ls [split $l @]
	if {[llength $ls] != 2} {
	    puts stderr "bad line $il (no x@y): \"$l\""
	    continue
	}
	set a [list]
	if {[catch {splitField [lindex $ls 1]} ret]} {
	    puts stderr "bad line $il (addr field): \"$l\""
	    continue
	} else {
	    lappend a $ret
	}
	if {[catch {splitField [lindex $ls 0]} ret]} {
	    puts stderr "bad line $il (user field): \"$l\""
	    continue
	    break
	} else {
	    lappend a $ret
	}
	lappend addr $a
    }
    return $addr
}

proc ::email::sortBilist {l1 l2} {
    set l11 [lindex $l1 0]
    set l12 [lindex $l1 1]
    set l21 [lindex $l2 0]
    set l22 [lindex $l2 1]
    foreach t1 $l11 t2 $l21 {
	set c [string compare [string tolower $t1] [string tolower $t2]]
	if {$c != 0} {
	    return $c
	}
    }
    foreach t1 $l12 t2 $l22 {
	set c [string compare [string tolower $t1] [string tolower $t2]]
	if {$c != 0} {
	    return $c
	}
    }
    return 0
}

proc ::email::printEmailList {addr} {

    set addr [sortEmails $addr]

    set addr [lsort -command sortBilist $addr]
    
    set addrList [list]
    
    set maxlen 0
    
    foreach a $addr {
	set qui [lindex $a 1]
	set ou  [lindex $a 0]
	set email {}
	set i [llength $qui]
	incr i -1
	append email [lindex $qui $i]
	for {incr i -1} {$i >= 0} {incr i -1} {
	    append email .[lindex $qui $i]
	}
	append email @
	set i [llength $ou]
	incr i -1
	append email [lindex $ou $i]
	for {incr i -1} {$i >= 0} {incr i -1} {
	    append email .[lindex $ou $i]
	}
	set len [string length $email]
	if {$len > $maxlen} {
	    set maxlen $len
	}
	lappend addrList $email
    }
    
    set addrListCleaned [list]
    set ap {}
    foreach a $addrList {
	if {$a != $ap} {
	    lappend addrListCleaned $a
	}
	set ap $a
    }
    
    foreach a $addrListCleaned {
	puts [format "%${maxlen}s" $a]
    }
    
}
