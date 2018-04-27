#!/bin/sh
#\
exec tclsh "$0" ${1+"$@"}

package require fidev
package require superTable

proc ibicstat {&stable filename nameOfTableName} {
    upvar ${&stable} stable

    if [catch {set indexes [superTable::fileToTable table $filename nameOfTableName {dispo Vcb}]} message] {
        puts stderr "$filename: $message"
        return {}
    }
    
    set ils [lindex $indexes 0]
    set ics [lindex $indexes 1]
    if {[lindex $indexes 2] != {}} {
        return -code error "\[lindex $indexes 2\] != {} : [lindex $indexes 2]"
    }

    foreach il $ils {
        set dispo [lindex $il 0]
        set Vcb [lindex $il 1]
        set geom [file dirname $dispo]
        lappend tils([list $geom $Vcb]) $il
    }

    foreach mesure [array names tils] {
        puts $mesure
        foreach {Ic_M f_Ic_M Ic_D f_Ic_D Ib_M f_Ib_M Ib_D f_Ib_D} [messtat table $tils($mesure)] break
        foreach {logIc} {Ic_M Ic_D Ib_M Ib_D} {
            set v [set $logIc]
            if {$v == {}} {
                set stable([list $mesure $logIc]) {}
            } else {
                set stable([list $mesure $logIc]) [format %.3e [expr {exp($v)}]]
            }
        }
        foreach {f_logIc} {f_Ic_M f_Ic_D f_Ib_M f_Ib_D} {
            set v [set $f_logIc]
            if {$v == {}} {
                set stable([list $mesure $f_logIc]) {}
            } else {
                set stable([list $mesure $f_logIc]) [format %.4f [expr {exp($v)}]]
            }
        }
        set stable([list $mesure geom]) [lindex $mesure 0]
        set stable([list $mesure Vcb]) [lindex $mesure 1]
    }
}

set HELP(stat) {
    retourne moyenne et écart-type de la liste
}

set ERLN(2) 1.128
set ERLN(3) 1.693
set ERLN(4) 2.059
set ERLN(5) 2.326

proc stat {vlist} {
    set tot 0.0
    set n [llength $vlist]
    if {$n == 0} {
        return {{} {}}
    }
    foreach v $vlist {
        set tot [expr {$tot + $v}]
    }
    set moy [expr {$tot/$n}]

    if {$n > 5} {
        set s2 0.0
        foreach v $vlist {
            set s2 [expr {$s2 + ($v - $moy)*($v - $moy)}]
        }
        set ecart [expr {sqrt($s2/($n - 1))}]
    } elseif {$n > 1} {
        global ERLN
        set vmin [lindex $vlist 0]
        set vmax $vmin
        foreach v [lrange $vlist 1 end] {
            if {$v < $vmin} {
                set vmin $v
            } elseif {$v > $vmax} {
                set vmax $v
            }
        }
        set ecart [expr {($vmax - $vmin)/$ERLN($n)}]
    } else {
        set ecart {}
    }
    return [list $moy $ecart]
}

proc messtat {&table ils} {
    upvar ${&table} table

    set lIcM [list]
    set lIcD [list]
    set lIbM [list]
    set lIbD [list]
    foreach il $ils {
        set Ic_M [superTable::getCell table $il Ic_M]
        set Ic_D [superTable::getCell table $il Ic_D]
        set Ib_M [superTable::getCell table $il Ib_M]
        set Ib_D [superTable::getCell table $il Ib_D]

        foreach i $Ic_M {lappend lIcM [expr {log($i)}]}
        foreach i $Ic_D {lappend lIcD [expr {log($i)}]}
        foreach i $Ib_M {lappend lIbM [expr {log($i)}]}
        foreach i $Ib_D {lappend lIbD [expr {log($i)}]}

    }
    return [concat [stat $lIcM] [stat $lIcD] [stat $lIbM] [stat $lIbD]]
}

proc compIndex {&array l1 l2} {
    upvar ${&array} array
    set f1 [superTable::getCell array $l1 geom]
    set f2 [superTable::getCell array $l2 geom]
    set c [string compare $f1 $f2]
    if {$c != 0} {return $c}
    set Vcb1 [superTable::getCell array $l1 Vcb]
    set Vcb2 [superTable::getCell array $l2 Vcb]
    if {$Vcb1 > $Vcb2} {return 1}
    if {$Vcb1 < $Vcb2} {return -1}
    return 0
}

set lignes [list]

set f ibic.spt
puts $f
set tables [superTable::tablesOfFile $f]
foreach t $tables {
    if {[regexp {^IbIc \(Vbe = ([^\)]+)\)[ ]+([^ ]*).*$} $t tout Vbe nom]} {
        if {![info exists Nom]} {
            set Nom $nom
        } elseif {$nom != $Nom} {
            return -code error "Changement de nom: \"$Nom\" devient \"$nom\""
        }
        puts stderr $Vbe
        catch {unset stable}
        ibicstat stable $f $tout
        # parray stable
        set lignes [concat $lignes [superTable::createLinesFromArray stable "IbIcStat.0.1 (Vbe = $Vbe) $Nom"\
                -orderOfCols {geom Vcb Ic_M f_Ic_M Ic_D f_Ic_D Ib_M f_Ib_M Ib_D f_Ib_D} -sortLines compIndex]]
        
    } else {
        puts stderr "skipped \"$t\""
    }
}

# foreach l $lignes {puts $l}
superTable::writeToFile ibicStat.spt $lignes
