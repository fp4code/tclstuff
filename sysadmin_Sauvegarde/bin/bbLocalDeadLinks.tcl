#!/bin/sh
# The next line is executed by /bin/sh, but not tcl \
exec tclsh8.4 "$0" ${1+"$@"}

# $Id$

set INFO(bbLocalDeadLinks.tcl) {
    7 février 2003 (FP)
    liste les répertoires morts dans /BB/2003.02.04.c0t2d0s7/2003.02.06.yoko.lpn.prive.c0t2d0s7.links.db 

    2004-07-15 (FP)
    /space/bb/
}

# package require Tcl 8.4 ;# Pour les entiers "wide"
load $env(P10PROG)/db/$env(P10ARCH)/lib/libdb_tcl.so

set x [file tail [pwd]]
set x [split $x .]
set x [concat [lindex $x 0] [info hostname] [lindex $x 1] links.db]
set x [join $x .]
puts stderr "opening [pwd]/$x"

set links [berkdb open -rdonly $x]

set c [$links cursor]

set bads [list]

set nlu 0
set x [$c get -first]
while {$x != {}} {
    incr nlu
    set x [lindex $x 0]
    set k [lindex $x 0]
    set v [lindex $x 1]
    set mtime [lindex $v 0]
    set inode [lindex $v 1]
    set type [lindex $v 2]
    set dest [lindex $v 3]
    switch $type {
        file {}
        directory {}
	link {}
        default {
	    set message "$k [clock format $mtime -format "%Y.%m.%d %H:%M:%S"] $type $dest"
            lappend bads $message
	    if {![string match "could not read*" $type]} {
		lappend badbads $message
	    }
        }
    }
    set x [$c get -next]
}
$links close

puts stderr "Vu $nlu liens, dont [llength $bads] morts"

if {[info exists badbads]} {
    puts stderr "Il y a des anormaux :"
    foreach x [lsort $badbads] {
	puts $x
    }
} else {
    puts stderr "Il n'y a pas de lien mort anormal"
}

foreach x [lsort $bads] {
    puts $x
}
