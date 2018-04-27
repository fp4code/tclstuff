#!/bin/sh
# \
exec tclsh "$0" ${1+"$@"}

set sos $argv

proc f_in_so so {
    global GLOB

    set err [catch {exec nm $so} rep]
    if $err {
        puts stderr "ERREUR \"$rep\""
        return
    }
    set rep [split $rep \n]
    if {[lindex $rep 4] != {[Index]   Value      Size    Type  Bind  Other Shndx   Name} && [lindex $rep 5] != {}} {
        puts stderr "ERREUR fichier \"$so\" : ligne 4 = \"[lindex $rep 4]\", ligne 5 = \"[lindex $rep 5]\""
        return
    }

    set rep [lrange $rep 6 end]
    foreach l $rep {
        set cols [split $l "|"]
        if {[llength $cols] != 8} {
            puts stderr "ERREUR \"$l\""
        } else {
            if {[string trim [lindex $cols 4]] == "GLOB" && [string trim [lindex $cols 3]] == "FUNC" && [string trim [lindex $cols 6]] != "UNDEF"} {
                puts $cols
                lappend GLOB([lindex $cols 7]) $so
            }
        }
    }
}

catch {unset GLOB}
foreach so $sos {
    puts stderr $so
    f_in_so $so
}

if {![info exists GLOB]} {
    puts stderr NOTHING
    exit 0
}

parray GLOB

exit 0


