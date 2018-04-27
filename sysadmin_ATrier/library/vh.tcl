#!/home/Tcl/bin/tclsh

# crée les tableaux 

set Externe {}
set Machine {}
set Actif {}
set Clos {}
set Prog {}
set NonCommente {}
set Autre {}
set S1 {}
set Obsolete {}
set Tempo {}

set auto_home [exec /usr/bin/niscat auto_home.org_dir]
set auto_home [split $auto_home "\n"]

foreach ligne $auto_home {
    set i [string first "#" $ligne]
    if {$i < 0} {
        lappend NonCommente $ligne
    } else {
        set comment [string range $ligne [expr $i+1] end]
        set comment [string trim $comment]
        set body [string range $ligne 0 [expr $i-1]]
        set body [string trim $body]
        switch $comment {
            ACTIF {lappend Actif $body}
            CLOS {lappend Clos $body}
            PROG {lappend Prog $body}
            EXTERNE {lappend Externe $body}
            OBSOLETE {lappend Obsolete $body}
            MACHINE {lappend Machine $body}
            TEMPO {lappend Tempo $body}
            S1 {lappend S1 $body}
            default {lappend Autre $ligne}
        }
    }
}



# on part d'une liste {n1 machine1:/path1} {n2 machine2:/path2}
# on initialise le tableau n1 -> machine1 path1
#                          n2 -> machine2} path2
proc splitAutoHomeInTable {Tableau Liste} {
    upvar $Tableau tableau 
    foreach a [array names tableau] {
        unset tableau($a)
    } 
    foreach ligne $Liste {
        set elems [split $ligne]
        if {[llength $elems] != 2} {
            puts stderr "DANGER : [llength $elems] éléments (au lieu de 2) pour $ligne"
        }
        set qui [lindex $elems 0]
        set ou [lindex $elems 1]
        set ou [split $ou ":"]
        if {[llength $ou] != 2} {
          puts stderr "DANGER : path incorrect : $ligne"
        }
        set tableau($qui) $ou 
    }
}





close $log
