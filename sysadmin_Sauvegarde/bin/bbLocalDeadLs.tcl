#!/bin/sh
# The next line is executed by /bin/sh, but not tcl \
exec tclsh8.4 "$0" ${1+"$@"}

# $Id$

set INFO(bbLocalLs.tcl) {
    7 février 2003 (FP)
    liste les répertoires morts dans /BB/2003.02.04.c0t2d0s7/2003.02.06.yoko.lpn.prive.c0t2d0s7.dirContents.db 
}

# package require Tcl 8.4 ;# Pour les entiers "wide"
load $env(P10PROG)/db/$env(P10ARCH)/lib/libdb_tcl.so

set x [file tail [pwd]]
set x [split $x .]
set x [concat [lrange $x 0 2] [info hostname] [lrange $x 3 end] dirContents.db]
set x [join $x .]
puts stderr "opening [pwd]/$x"

set links [berkdb open $x]

set c [$links cursor]

set bads [list]
set x [$c get -first]
while {$x != {}} {
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
        default {
            lappend bads "$k [clock format $mtime -format "%Y.%m.%d %H:%M:%S"] $type $dest"
        }
    }
    set x [$c get -next]
}
$links close

foreach x [lsort $bads] {
    puts $x
}
