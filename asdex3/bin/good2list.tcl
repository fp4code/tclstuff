#!/bin/sh
#\
exec tclsh "$0" ${1+"$@"}

package require fidev
package require superTable
set OUT stdout

if {$argc < 1} {
    puts stderr "syntaxe: $argv0 fichier_good1.spt fichier_good2.spt ..."
    exit 1
}


proc goodlist {filename} {

    set nameOfTableName *
    
    if [catch {set indexes [superTable::fileToTable case $filename nameOfTableName {}]} message] {
        puts stderr "$filename: $message"
        return {}
    }
    
    set ils [lindex $indexes 0]
    set ics [lindex $indexes 1]
    if {[lindex $indexes 2] != {}} {
        return -code error "\[lindex $indexes 2\] != {} : [lindex $indexes 2]"
    }
    
    


    catch {unset BONS}
    set bons [list]
    
    foreach il $ils {
        set tn [superTable::getCell case $il table]
        set dispo [lindex $tn end]
        if {![info exists BONS($dispo)]} {
            set BONS($dispo) {}
            lappend bons $dispo
        }
    }
    return $bons
}

proc intersectCleanLists {l1 l2} {
    set ret [list]
    foreach l $l2 {
        set L($l) $l
    }
    foreach l $l1 {
        if {[info exists L($l)]} {
            lappend ret $l
        }
    }
    return $ret
}

set bons [goodlist [lindex $argv 0]]

foreach filename [lrange $argv 1 end] {
    set bons [intersectCleanLists $bons [goodlist $filename]]
}

puts $OUT {}
set filename [lindex $argv 0]
if {[file pathtype $filename] == "relative"} {
    set filename "[pwd]/$filename"
}
puts $OUT "    # extrait de $filename"
foreach filename [lrange $argv 1 end] {
    if {[file pathtype $filename] == "relative"} {
        set filename "[pwd]/$filename"
    }
    puts $OUT "    #      et de $filename"
}

puts $OUT "    set AllSymDes \[list \\"
foreach b $bons {
    puts $OUT "        $b \\"
}
puts $OUT "    \]"
puts $OUT {}
