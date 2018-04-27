#!/bin/sh
# The next line is executed by /bin/sh, but not tcl \
exec tclsh8.4 "$0" ${1+"$@"}

# $Id$

set INFO(bbLocalBlurredInodes.tcl) {
    2005-05-10 (FP)
}

package require Db_Tcl 4.3

set x [file tail [pwd]]
append x .inodes.db
puts stderr "opening [pwd]/$x"

set inodes [berkdb open -rdonly $x]

set c [$inodes cursor]

set clusters [list]

set nlu 0
set kv [$c get -first]
while {$kv != {}} {
    incr nlu
    set nkv [$c get -nextdup]
    if {$nkv ne {}} {
	incr nlu
	set cluster [list $kv $nkv]
	while {[set nkv [$c get -nextdup]] ne {}} {
	    lappend cluster $nkv
	    incr nlu
	}
	lappend clusters $cluster
    }
    set kv [$c get -next]
}
$c close
$inodes close

foreach cluster $clusters {
    puts {}
    foreach kv $cluster {
	puts 
    }
}
