#!/home/Tcl/bin/tclsh

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

set lm 0

foreach f $Machines {
    set l [string length $f]
    if {$l > $lm} {
        set lm $l
    }
}

set l1 [string length {# machine}]

if {$lm < $l1} {
    set lm $l1
}

set dada [exec /usr/bin/date +%y%m%d]
set log [open /usr/local/etc/logs/df.$dada w]

foreach machine $Machines {
    puts $machine
    set retour [exec rsh -n $machine /usr/bin/df -k -F ufs]
    set retour [split $retour "\n"]
    foreach l $retour {
        if {[string match Filesystem* $l]} {
            puts $log "[format %-${lm}s {# machine}] $l"
        } elseif {[string match /dev/dsk/* $l]} {
            puts $log "[format %-${lm}s $machine] $l"
        } else {
            puts stderr "ERREUR : $l"
        }
    }
    flush $log
}

close $log
