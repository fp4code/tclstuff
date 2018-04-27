#!/bin/sh
# The next line is executed by /bin/sh, but not tcl \
exec tclsh "$0" ${1+"$@"}

##
## labo20.tcl
##
## succédané de "telnet imap imap"
##

set IMAP imap.lpn.prive

puts -nonewline stderr "login/mot de passe : "
set lopass [split [gets stdin] /]
set LOGIN [lindex $lopass 0]
set PASS [lindex $lopass 1]

proc readImap {imap} {
    global STATUS
    if [eof $imap] {
        close $imap
        set STATUS "Imap is dead"
    } else {
        set l [gets $imap]
        puts stdout "Imap: \"$l\""
    }
}

proc sendImap {imap} {
    global STATUS

    set l [gets stdin]
    if {[eof stdin]} {
        puts stderr "EOF stdin"
        close $imap
        set STATUS "done"
    } else {
        puts $imap $l
    }
}

proc doIt {} {
    global STATUS IMAP
    set imap [socket $IMAP imap]
    fileevent $imap readable [list readImap $imap]
    fconfigure $imap -buffering line -blocking 0
    puts stderr "Connecté à imap !"
    fileevent stdin readable [list sendImap $imap]
    vwait STATUS
}

doIt
puts stderr $STATUS
