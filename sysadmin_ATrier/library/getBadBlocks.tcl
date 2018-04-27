#!/usr/local/bin/tclsh

puts [exec date]

set WARNS [exec grep WARNING /var/adm/messages]

set WARNS [split $WARNS \n]

foreach l $WARNS {
    set message [string range $l 16 end]
    set MESSAGES($message) {}
}

puts [array names MESSAGES]

set BLOCLI [exec grep "Error Block" /var/adm/messages]

set BLOCLI [split $BLOCLI \n]
foreach l $BLOCLI {
    set l [split $l \t]
    if {[llength $l] != 3} {
        puts stderr "3 != length $l"
    } else {
        set requested [lindex $l 1]
        set badbloc [lindex $l 2]
        set requested [split $requested :]
        set badbloc [split $badbloc :]
        set requested [expr [lindex $requested 1]]
        set badbloc [expr [lindex $badbloc 1]]
        set BADBLOCS($badbloc) {}
        set REQUESTEDS($requested) {}
    }
}

puts "BADBLOCS   : [lsort -integer [array names BADBLOCS]]"
puts "REQUESTEDS : [lsort -integer [array names REQUESTEDS]]"
