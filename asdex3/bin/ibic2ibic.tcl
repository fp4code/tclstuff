#!/bin/sh
#\
exec tclsh "$0" ${1+"$@"}

package require fidev
package require superTable


proc ibic {&table filename nameOfTableName Vcb VbeList} {

    if [catch {set indexes [superTable::fileToTable case $filename nameOfTableName {}]} message] {
        puts stderr "$filename: $message"
        return {}
    }
    
    set ils [lindex $indexes 0]
    set ics [lindex $indexes 1]
    if {[lindex $indexes 2] != {}} {
        return -code error "\[lindex $indexes 2\] != {} : [lindex $indexes 2]"
    }
    
    # nettoyage des mesures avec Compliance
    # recherche du min de Ie
    
    set nils [list]
    set max 1e99
    catch {unset ilmax}
    set ii 0
    foreach il $ils {
        if {[superTable::getCell case $il Se] != {} ||
        [superTable::getCell case $il Sb] != {} ||
        [superTable::getCell case $il Sc] != {}} {
            foreach ic $ics {
                unset case([list $il $ic])
            }
        } else {
            if {[superTable::getCell case $il Ie] < $max} {
                set max [superTable::getCell case $il Ie]
                set ilmax $ii
            } elseif {[superTable::getCell case $il Ie] == $max} {
                lappend ilmax $ii
            }
            lappend nils $il
            incr ii
        }
    }
    if {![info exists ilmax]} {
        puts stderr "Warning: pas d'ilmax"
        return
    }
    if {[llength $ilmax] != 2} {
        puts stderr "Warning: extrema n'est pas en 2 points : $ilmax"
    } 
    
    # montée et descente
    set ilsM [lrange $nils 0 [lindex $ilmax 0]]
    set ilsD [lrange $nils [lindex $ilmax end] end]
    
    # Nettoyage des mesures paranos
    
    set nilsM [list]
    set lastIe 1e99
    foreach il $ilsM {
        if {[superTable::getCell case $il Ie] < $lastIe} {
            lappend nilsM $il
            set lastIe [superTable::getCell case $il Ie]
        }
    }
    set ilsM $nilsM
    
    set nilsD [list]
    set lastIe -1e99
    foreach il $ilsD {
        if {[superTable::getCell case $il Ie] > $lastIe} {
            lappend nilsD $il
            set lastIe [superTable::getCell case $il Ie]
        }
    }
    set ilsD $nilsD
    
    foreach Vbe $VbeList {
        upvar ${&table}$Vbe table

        set ibicM [ibicVals case $Vbe $ilsM log]
        set ibicD [ibicVals case $Vbe $ilsD log]
    
        set ibM [lindex $ibicM 0]
        set ibD [lindex $ibicD 0]
        set icM [lindex $ibicM 1]
        set icD [lindex $ibicD 1]
    
        set index [list $filename $Vcb]
        superTable::setCell table $index dispo $filename
        superTable::setCell table $index Vcb $Vcb
        superTable::setCell table $index Ic_M $icM
        superTable::setCell table $index Ic_D $icD
        superTable::setCell table $index Ib_M $ibM
        superTable::setCell table $index Ib_D $ibD
    }
}

# découpage en sous-listes monotones
# ex: a 1  b 2  c 2  d 2  e -1  f -3  g 10  -> {a b} {1 2} c 2 {d e f} {2 -1 -3} {f g} {-3 10}

namespace eval numlist::decoupeMonotone {}

proc numlist::decoupeMonotone {l2} {

    set lils [list]
    set nilsi [lindex $l2 0]
    set nilsv [lindex $l2 1]
    set lv [lindex $l2 1]

    set ii 2
    foreach {i v} [lrange $l2 $ii end] {
        if {$v == $lv} {
            lappend lils $nilsi $nilsv 
            set nilsi $i
            set nilsv $v
            incr ii 2
            set li $i
            set lv $v
        } else {
            if {$v > $lv} {
                set sens 1
            } else {
                set sens -1
            }
            lappend nilsi $i
            lappend nilsv $v
            incr ii 2
            set li $i
            set lv $v
            break
        }
    }

    foreach {i v} [lrange $l2 $ii end] {
        # puts "$sens * ($v - $lv)"
        set prod [expr {$sens * ($v - $lv)}]
        if {$prod > 0} {
            lappend nilsi $i
            lappend nilsv $v
        } else {
            set sens [expr {-$sens}]
            if {$prod == 0} {
                lappend lils $nilsi $nilsv
                set nilsi [list $i]
                set nilsv [list $v]
            } elseif {[llength $nilsi] > 1} {
                lappend lils $nilsi $nilsv 
                set nilsi [list $li $i]
                set nilsv [list $lv $v]
            } else {
                lappend nilsi $i
                lappend nilsv $v
            }
        }
        set li $i
        set lv $v
    }

    lappend lils $nilsi $nilsv
    return $lils
}

# La liste $lv doit être monotone strict

proc numlist::interpole {vt lv} {
    # recherche linéaire à optimiser
    if {[lindex $lv 0] < [lindex $lv end]} {
        if {$vt < [lindex $lv 0] || $vt > [lindex $lv end]} {
            return {}
        }
        set ii 0
        foreach v $lv {
            if {$v < $vt} {
                incr ii
                set vPrec $v
                continue
            } elseif {$v == $vt} {
                return [list $ii 1.0]
            } else {
                return [list [expr {$ii - 1}] [expr {($vt - $v)/($vPrec - $v)}]]
            }
        }
    } else {
        if {$vt > [lindex $lv 0] || $vt < [lindex $lv end]} {
            return {}
        }

        set ii 0
        foreach v $lv {
            if {$v > $vt} {
                incr ii
                set vPrec $v
                continue
            } elseif {$v == $vt} {
                return [list $ii 1.0]
            } else {
                return [list [expr {$ii - 1}] [expr {($vt - $v)/($vPrec - $v)}]]
            }
        }
    }
}

# renvoit normalement Ib Ic, mais peut renvoyer {} ou Ib1 Ic1 Ib2 Ic2 ... dans le cas d'états multistables.

proc ibicVals {&case Vbe ils mode} {
    upvar ${&case} case
    set l2 [list]
    foreach il $ils {
        lappend l2 $il [superTable::getCell case $il Ve]
    }
    set l2 [numlist::decoupeMonotone $l2]
    set ibic [list]
    foreach {li lv} $l2 {
        set ip [numlist::interpole [expr {-$Vbe}] $lv]
        # puts stderr "numlist::interpole [expr {-$Vbe}] -> $ip"
        if {$ip != {}} {
            foreach {i t} $ip {break}
            set il1 [lindex $li $i]
            set il2 [lindex $li [expr {$i+1}]]
            set Ib1 [superTable::getCell case $il1 Ib]
            set Ib2 [superTable::getCell case $il2 Ib]
            set Ic1 [superTable::getCell case $il1 Ic]
            set Ic2 [superTable::getCell case $il2 Ic]
            if {[catch {
                switch $mode {
                    lin {
                        set Ib [expr {$t*$Ib1 + (1.0 - $t)*$Ib2}]
                        set Ic [expr {$t*$Ic1 + (1.0 - $t)*$Ic2}]
                    }
                    log {
                        set Ib [expr {exp($t*log($Ib1) + (1.0 - $t)*log($Ib2))}]
                        set Ic [expr {exp($t*log($Ic1) + (1.0 - $t)*log($Ic2))}]
                    }
                    default {
                        return -code error "mode should be \"lin\" or \"log\""
                    }
                }
            } message]} {
                puts stderr $message
            } else {
                # puts stderr "Ic : $Ic1 $Ic2 -> $Ic"
                # puts stderr "Ib : $Ib1 $Ib2 -> $Ib"
                lappend ibic [format %.3e $Ib] [format %.3e $Ic]
            }
        }
    }
    return $ibic
}

set rien {
    foreach il $ilsM {
        puts "[superTable::getCell case $il Ve] [superTable::getCell case $il Ib] [superTable::getCell case $il Ic]"
    }
    puts {}
    foreach il $ilsD {
        puts "[superTable::getCell case $il Ve] [superTable::getCell case $il Ib] [superTable::getCell case $il Ic]"
    }
}

set rien {
# recherche de l'encadrement de Ve

set ii 0
set lastVe -1e99
foreach il $ilsM {
    if {[superTable::getCell case $il Ve] < $last}
    incr ii
}
}

set rien {
    proc compareVbe {&case li1 li2} {
        upvar ${&case} case
        set diff [expr {([superTable::getCell case $li1 Vb] - [superTable::getCell case $li1 Ve]) - ([superTable::getCell case $li2 Vb] - [superTable::getCell case $li2 Ve])}]
        if {$diff > 0} {
            return 1
        } elseif {$diff < 0} {
            return -1
        } else {
            return 0
        }
    }
    
    set nils [lsort -command {compareVbe case} $ils]
    
    foreach il $nils {
        puts "[expr {[superTable::getCell case $il Vb] - [superTable::getCell case $il Ve]}] [superTable::getCell case $il Ib] [superTable::getCell case $il Ic] [superTable::getCell case $il Itot]"
    }
}

# cd /home/asdex/A/data/G000420/G000420.2/bipolaire/

proc compIndex {&array l1 l2} {
    upvar ${&array} array
#    set Vbe1 [superTable::getCell array $l1 Vbe]
#    set Vbe2 [superTable::getCell array $l2 Vbe]
#    if {$Vbe1 > $Vbe2} {return 1}
#    if {$Vbe1 < $Vbe2} {return -1}
    set f1 [superTable::getCell array $l1 dispo]
    set f2 [superTable::getCell array $l2 dispo]
    set c [string compare $f1 $f2]
    if {$c != 0} {return $c}
    set Vcb1 [superTable::getCell array $l1 Vcb]
    set Vcb2 [superTable::getCell array $l2 Vcb]
    if {$Vcb1 > $Vcb2} {return 1}
    if {$Vcb1 < $Vcb2} {return -1}
    return 0
}

for {set i 55} {$i <= 90} {incr i} {
    lappend VbeList 0.$i
}

# set VbeList 0.80

foreach f [glob -nocomplain */*.spt] {
    puts $f
    set dir [file dirname $f]
    set tables [superTable::tablesOfFile $f]
    foreach t $tables {
        if {[regexp {^IbIc \(Vc = ([^\)]+)\)[ ]+([^ ]*).*$} $t tout Vcb nom]} {
            if {![info exists Nom]} {
                set Nom $nom
            } elseif {$nom != $Nom} {
                return -code error "Changement de nom: \"$Nom\" devient \"$nom\""
            }
            puts stderr $Vcb
            ibic table $f $tout $Vcb $VbeList
        } else {
            puts stderr "skipped \"$t\""
        }
    }
}

set lignes [list]

foreach Vbe $VbeList {
    set lignes [concat $lignes [superTable::createLinesFromArray table$Vbe "IbIc (Vbe = $Vbe) $Nom"\
            -orderOfCols {dispo Vcb Ic_M Ic_D Ib_M Ib_D} -sortLines compIndex]]
}

superTable::writeToFile ibic.spt $lignes

