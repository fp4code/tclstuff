#!/prog/Tcl/bin/tclsh

set hosts [exec /usr/bin/niscat hosts.org_dir]
set hosts [split $hosts "\n"]

set Machines {}

foreach ligne $hosts {
    if {[string first "S2" $ligne] >=0 && [string first "ACTIF" $ligne]>=0} {
    set lili [split $ligne]
        if {[lindex $lili 0] == [lindex $lili 1]} {
          lappend Machines [lindex $lili 0]
        }
    }
}

set Machines [lsort $Machines]



foreach f $Machines {
    puts "**********************************************************************"
    puts $f
    set retour [exec rsh -n $f /usr/bin/df -k -F ufs]
    if {$retour != {}} {
    puts "**********"
        puts $retour
    }

}
    puts "**********************************************************************"
