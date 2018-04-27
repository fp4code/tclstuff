#!/prog/Tcl/bin/tclsh





foreach f $argv {
    set cols [split [exec /bin/su $f -c "/usr/bin/nismatch name=$f passwd.org_dir"] ':']
    set login [lindex $cols 0]
    set passwd [lindex $cols 1]
    set uid [lindex $cols 2]
    if {[string length $passwd] != 13} {
        puts "Bad cred -> changé to nisplus"
        exec /usr/bin/nisaddcred -p unix.${uid}@l2m.fr -P ${login}.l2m.fr. -l nisplus des
    } else {
        puts "Good cred"
    }
}
