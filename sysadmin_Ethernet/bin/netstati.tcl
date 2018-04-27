#!/usr/local/bin/tclsh

package require sysadmin
package require sysadmin_tableUtils

proc netstati {} {
    set t0(INSTANT) [clock seconds]
    set n [split [exec /usr/bin/netstat -i] \n]
    sysadmin::tableUtils::new t0 [lindex $n 0] [lrange $n 1 end]
    sysadmin::tableUtils::imprime t0
    after 5000
    set t1(INSTANT) [clock seconds]
    set n [split [exec /usr/bin/netstat -i] \n]
    sysadmin::tableUtils::new t1 [lindex $n 0] [lrange $n 1 end]
    set td(COLONNES) "Ipkts Ierrs Opkts Oerrs Collis"
    set td(LIGNES) $t1(LIGNES)
    set td(INSTANT) $t1(INSTANT)

    foreach n $td(LIGNES) {
        set td($n,Name) $t1($n,Name)
        set td($n,Address) $t1($n,Address)
        foreach c $td(COLONNES) {
            set td($n,$c) [expr $t1($n,$c) - $t0($n,$c)]
        }
    }
    set td(COLONNES) "Name Address $td(COLONNES)"
    
    sysadmin::tableUtils::imprime td
}

netstati


