#!/prog/Tcl/bin/tclsh

set lignes [exec niscat auto_home.org_dir]

set lignes [split $lignes "\n"]

foreach l $lignes {
    set user [lindex $l 0]
    set err [catch {exec ls -ld /home/$user/desktop} ll]
    puts "$err : $ll"
}
