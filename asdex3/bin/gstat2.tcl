#!/bin/sh
#\
exec tclsh "$0" ${1+"$@"}

package require fidev
package require superTable

proc s {} {source /home/fab/A/fidev/Tcl/asdex3/bin/gstat.tcl}

set a(5x10) 5.0
set b(5x10) 10.0
set a(5x17) 5.0
set b(5x17) 17.0
set a(5x40) 5.5 ;# oui, 5.5
set b(5x40) 40.0
set a(5x54) 5.0
set b(5x54) 54.0
set a(5x7) 5.0
set b(5x7) 7.0
set a(6x20) 6.0
set b(6x20) 20.0
set a(7x45) 7.0
set b(7x45) 45.0
set a(8x27) 8.0
set b(8x27) 27.0

proc readIc {&Ic &f_Ic filename Vbe Vcb} {

    upvar ${&Ic} Ic
    upvar ${&f_Ic} f_Ic

    set nameOfTableName "*(Vbe = $Vbe)*"
    if [catch {set indexes [superTable::fileToTable case $filename nameOfTableName {Vcb geom}]} message] {
        puts stderr "$filename: $message"
        return {}
    }
    
    set ils [lindex $indexes 0]
    set ics [lindex $indexes 1]
    if {[lindex $indexes 2] != {}} {
        return -code error "\[lindex $indexes 2\] != {} : [lindex $indexes 2]"
    }

    puts $ils
    puts $ics

    set nils [list]
    foreach il $ils {
        if {[superTable::getCell case $il Vcb] == $Vcb} {
            set geom [superTable::getCell case $il geom]
            set IcVal [superTable::getCell case $il Ic_M] ;# Ic_M
            set f_IcVal [superTable::getCell case $il f_Ic_M] ;# Ic_M
            if {$IcVal != {}} {
                lappend nils $il 
                set Ic($geom) $IcVal
                set f_Ic($geom) $f_IcVal
            }
        }
    }
  
}

proc g {geom Jc f} {
    global a b Ic

    set rac [expr {sqrt(pow($a($geom) - $b($geom), 2) + 4.0*$f*$Ic($geom)/$Jc)}]
    set g [expr {0.5 * ($a($geom) + $b($geom) - $rac)}]
    return $g
}

proc zero {Jc} {
    global a b Ic
    
    set sg 0.0
    set sdg 0.0
    set sgdg 0.0
    set N 0
    foreach geom [array names Ic] {
        set rac [expr {sqrt(pow($a($geom) - $b($geom), 2) + 4.0*$Ic($geom)/$Jc)}]
        set g [expr {0.5 * ($a($geom) + $b($geom) - $rac)}]
        set dg [expr {$Ic($geom)/($rac*$Jc*$Jc)}]
        set sg [expr {$sg + $g}]
        set sdg [expr {$sdg + $dg}]
        set sgdg [expr {$sgdg + $g*$dg}]
        incr N
    }
    set stot [expr {$sgdg - $sg*$sdg/$N}]
    set verif {
        set stotBis 0.0
        foreach geom [array names Ic] {
            set rac [expr {sqrt(pow($a($geom) - $b($geom), 2) + 4.0*$Ic($geom)/$Jc)}]
            set g [expr {0.5 * ($a($geom) + $b($geom) - $rac)}]
            set dg [expr {$Ic($geom)/($rac*$Jc*$Jc)}]
            set stotBis [expr {$stotBis + ($g-$sg/$N)*($dg-$sdg/$N)}]
        }
        puts "-> $stot $stotBis"
    }
    return $stot
}

proc ploplo {JcMin JcMax} {
    upvar gp gp

    puts $gp {set ter x11 0}
    puts $gp {plot "-" with lines}

    set npts 101
    
    for {set i 0} {$i < $npts} {incr i} {
        set Jc [expr {$JcMin + double($JcMax - $JcMin)*$i/double($npts-1)}]
        puts $gp "$Jc [zero $Jc]"
        # puts stdout "$Jc [zero $Jc]"
    }
    puts $gp e
}

proc ploplog2 {JcMin JcMax} {
    upvar gp gp
    puts stderr [info globals]
    global Ic
    global f_Ic
    parray Ic
    parray f_Ic
}

proc ploplog {JcMin JcMax} {
    upvar gp gp
    global Ic
    global f_Ic

    set geoms [lsort [array names Ic]]
    set N [llength $geoms]

    puts $gp {set ter x11 1}
    puts $gp {set key bottom}

    set commande {}
    for {set i 0} {$i < $N} {incr i} {
        foreach type {"lines linewidth 5" lines "lines linewidth 5"}\
                title [list notitle "title \"[lindex $geoms $i]\"" notitle] {
            if {$commande == {}} {
                append commande "plot"
            } else {
                append commande ","
            }
            append commande " \"-\" $title with $type [expr {$i+1}]"
        }
    }
    puts $gp $commande
    puts $commande

    set npts 101

    foreach geom $geoms {
        if {$f_Ic($geom) == {}} {
            set fMin 1.0
            set fMax 1.0
        } else {
            set fMin [expr {1.0/$f_Ic($geom)}]
            set fMax [expr {$f_Ic($geom)}]
        }
        foreach f [list $fMin 1.0 $fMax] {
            set data {}
            for {set i 0} {$i < $npts} {incr i} {
                set Jc [expr {$JcMin + double($JcMax - $JcMin)*$i/double($npts-1)}]
                append data $Jc
                append data " [g $geom $Jc $f]"
                append data \n
                # puts stdout "$Jc [zero $Jc]"
            }
            append data e
            puts $gp $data
        }
    }
}

proc oeil {JcMin JcMax} {
    upvar gp gp
    global Ic
    global f_Ic

    set geoms [lsort [array names Ic]]
    set N [llength $geoms]

    puts $gp {set ter x11 2}
    puts $gp {set key bottom}

    puts $gp "plot \"-\", \"-\""

    set npts 1001

    set data [list]
    for {set i 0} {$i < $npts} {incr i} {
        if {[info exists gMin]} {unset gMin}
        if {[info exists gMax]} {unset gMax}
        foreach geom $geoms {
            if {$f_Ic($geom) != {}} {
                set Jc [expr {$JcMin + double($JcMax - $JcMin)*$i/double($npts-1)}]
                set ngMin [g $geom $Jc [expr {$f_Ic($geom)}]]
                set ngMax [g $geom $Jc [expr {1.0/$f_Ic($geom)}]]
                if {![info exists gMin] || $ngMin > $gMin} {
                    set gMin $ngMin
                }
                if {![info exists gMax] || $ngMax < $gMax} {
                    set gMax $ngMax
                }
            }
        }
        if {$gMin <= $gMax} {
            lappend data $Jc $gMin $gMax
        }
    }
    if {$data == {}} {
        puts stderr "rien ne se recouvre !!!"
        return
    }
    
    foreach {Jc gMin gMax} $data {
        puts $gp "$Jc $gMin"
    }
    puts $gp "e"

    foreach {Jc gMin gMax} $data {
        puts $gp "$Jc $gMax"
    }
    puts $gp "e"
}


proc gis {Jc} {
    global Ic

    set gis [list]
    foreach geom [array names Ic] {
        lappend gis [g $geom $Jc 1.0]
    }
    return $gis
}

set f ibicStat.spt

set dir [file dirname $f]
set tables [superTable::tablesOfFile $f]

puts $tables

set gp [open "|gnuplot" w]
fconfigure $gp -buffering line
puts $gp {set grid}

catch {unset Ic f_Ic}

# ./gstat2.tcl Vbe Vcb [ploplog | oeil] JcMin JcMax

#set Vbe 0.75
#set Vcb 0.0
#readIc Ic f_Ic $f $Vbe $Vcb
#ploplog 1e-5 1e-4
#oeil 1.5e-6 2.5e-5

if {$argc != 5} {
    puts stderr "syntaxe: $argv0 Vbe Vcb \[ploplog | oeil\] JcMin JcMax"
    exit 1
}

foreach {Vbe Vcb quoi JcMin JcMax} $argv {}
readIc Ic f_Ic $f $Vbe $Vcb

$quoi $JcMin $JcMax

set ATTEND 0
after 200000 {set ATTEND 0}
vwait ATTEND

