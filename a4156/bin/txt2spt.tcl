#!/bin/sh
# the next line restarts using tclsh \
exec tclsh "$0" "$@"


set DESCRIPTION "2008-12-23 (FP) conversion .TXT -> .spt"

proc txt2spt {table in out} {
    if {[file exists $out]} {
	error "file \"$out\" exists !"
    }
    set f [open $in r]
    set lines [split [read -nonewline $f] \n]
    close $f
    
    set f [open $out w]
    set tata "@@$out $table [lindex $lines 1]"
    puts $f $tata
    puts stdout $tata
    puts $f "#[lindex $lines 0]"
    puts $f "#[lindex $lines 1]"
    puts $f "@[lindex $lines 2]"
    puts $f "#[lindex $lines 3]"
    foreach l [lrange $lines 4 end] {
	puts $f $l
    }
    close $f
}

if {[llength $argv] == 0} {
    puts stderr "$::DESCRIPTION"
    puts stderr "Crée dans le répertoire courant les fichiers .spt"
    puts stderr "syntaxe: $argv0 repertoire/fichiers*.TXT"

}

foreach f $argv {
    set tail [file tail $f]
    set extension [file extension $tail]
    set i [file rootname $tail]
    if {$extension != ".TXT"} {
	error "bad extension \"$extension\", should be \".TXT\""
    }

    txt2spt "" $f "$i.spt"
}