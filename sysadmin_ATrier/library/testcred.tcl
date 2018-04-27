#!/prog/Tcl/bin/tclsh

set passwords [exec /usr/bin/niscat passwd.org_dir]
set passwords [split $passwords '\n']

foreach f $passwords {
    set pass [split $f ":"]
    set code [lindex $pass 1]
    if {[string length $code] == 13} {
        set login [lindex $pass 0]
        puts $login
        set uid [lindex $pass 2]
        puts [exec /bin/su $login -c "/usr/bin/niscat passwd.org_dir | grep root"]
        /usr/bin/nisaddcred -p unix.${uid}@l2m.fr -P ${login}.l2m.fr. des
    }
}

nisplus

