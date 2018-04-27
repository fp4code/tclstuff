# 19 décembre 2002 (FP)
# 23 décembre 2002 (FP)

set BASE /home/p10admin/A/html
set DYNAMIC   Lpn/dynamic
set DATABASES Lpn/databases

package require fidev
package require fichUtils 0.2

proc readLines {file} {
    global BASE DATABASES FICHIERS
    set fifi [file join $BASE $DATABASES $file]
    lappend FICHIERS $file
    set f [open $fifi r]
    set lines [read -nonewline $f]
    close $f
#    set ret ""
#    foreach l [split $lines \n] {
#        if {![regexp "^\#" $l] && ![regexp {^[\t ]*$} $l]} {
#            append ret " $l"
#        }
#    }
#    return $ret
    return $lines
}

set SCRIPT [file join [pwd] [info script]]
while {[file type $SCRIPT] == "link"} {
    set SCRIPT [file readlink $SCRIPT]
}

set lines [readLines organisationSalleBlanche] 

proc traiteSalle l {
    set salle [lindex $l 0]
    set tel [lindex $l 1]
    set denom [lindex $l 2]
    puts "Tel. $tel"
    puts $denom
    foreach {k v} [lrange $l 3 end] {
        puts "$k: $v"
    }
}




foreach l $lines {   
    set e0 [lindex $l 0]
    puts $e0

    if {$e0 == "comment"} {
        continue
    }

    if {[regexp "^Salle" $e0]} {
        traiteSalle $l
        continue
    }

    if {[regexp "^organigramme" $e0]} {
        traiteOrganigramme $l
        continue
    }

    puts stderr "header inconnu \"$e0\""

}
