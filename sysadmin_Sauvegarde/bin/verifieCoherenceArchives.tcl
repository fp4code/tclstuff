#!/bin/sh
# The next line is executed by /bin/sh, but not tcl \
exec tclsh "$0" ${1+"$@"}

# $Id: verifieCoherenceArchives.tcl,v 1.1 2003/01/23 10:10:50 fab Exp $
set INFO{verifieCoherenceArchives.tcl} {
    Programme vérifiant la cohérence de l'archive BigBro
    22 janvier 2003 (FP) création
       - contrôle md5sum
       - contrôle des permissions
    tient 230 Mbit/s sur penguin avec md5sum
}


####################
# PARAMETRE MAISON #
####################
set GLOB(RDEST) /

package require Tcl 8.5
package require fidev
package require alladin_md5 1.0

cd $GLOB(RDEST)

set totsize [expr {wide(0)}]
set totvus  [expr {wide(0)}]

puts stderr "date         GB      nombre   GB      nombre --Mbits/s--"
#            2003.01.22   0.006       85   0.006       85 280.6 280.6

catch {unset md5sums}
catch {unset instant}

foreach d [lsort -decreasing [glob *]] {
    if {![regexp {^[12][09][0-9][0-9].[01][0-9].[0-3][0-9]$} $d]} {
        puts stderr "exclu $d"
        continue
    }
    cd $GLOB(RDEST)
    if {[file attributes $d -group] != "p10admin"} {
        puts stderr "ERREUR $d group=[file attributes $d -group]"
        file attributes $d -group p10admin
    }
    if {[file attributes $d -permissions] != "040775"} {
        puts stderr "ERREUR $d permissions=[file attributes $d -permissions]"
        file attributes $d -permissions 040775
    }
    cd $d

    if {![info exists depart]} {
        set depart [clock clicks -milliseconds]
        set oldinstant $depart
    } else {
        set oldinstant $instant
    }
    set dirsize [expr {wide(0)}]
    set dirvus  [expr {wide(0)}]
    foreach f [glob *] {
        set df [file join $d $f]
        if {[string length $f] != 32} {
            puts stderr "exclu $df"
            continue
        }
        if {![regexp {^[0-9a-f]+$} $f]} {
            puts stderr "exclu $df"
            continue
        }
        if {1} {
            set md5sum [alladin_md5::file $f]
            if {$md5sum != $f} {
                puts stderr "ERREUR sur $df"
            }
        } else {
            # bidouille provisoire
            set md5sum $f
            file attributes $f -group p10admin -permissions 00440
        }
        if {[info exists md5sums($md5sum)]} {
            puts stderr "ERREUR doublon $df"
        }
        set md5sums($md5sum) {}
        file stat $f attrib
        set dirsize [expr {$dirsize + $attrib(size)}]
        incr dirvus
    }
    set totsize [expr {$totsize + $dirsize}]
    set totvus [expr {$totvus + $dirvus}]
    set instant [clock clicks -milliseconds]
    set dirdelai [expr {($instant - $oldinstant) * 1e-3}]
    set totdelai [expr {($instant - $depart) * 1e-3}]
    if {$dirdelai == 0} {
        set dispeed Inf
    } else {
        set dirspeed [format %5.1f [expr {8*$dirsize*1e-6/$dirdelai}]]
    }
    set totspeed [format %5.1f [expr {8*$totsize*1e-6/$totdelai}]]
    puts -nonewline stderr "$d [format %7.3f [expr {$totsize*1e-9}]] [format %8d $totvus]"
    puts -nonewline stderr " [format %7.3f [expr {$dirsize*1e-9}]] [format %8d $dirvus]"
    puts -nonewline stderr " $totspeed"
    puts -nonewline stderr " $dirspeed"
    puts stderr ""
}
