#!/usr/local/bin/tclsh

package require fidev
package require fctlm_geom 0.2
package require fichUtils 1.0

set dir [pwd]
if {$argc != 1} {
    puts stderr "syntaxe $argv0 geom"
    exit 1
}
set geom $argv
set out [fctlm_geom::readGeomAndQuality $dir ${geom}.spt]

set f [open ${geom}Etalon.spt w]
foreach l $out {
    puts $f $l
}
close $f
puts "\nOK ${geom}Etalon.spt est créé ou modifié"


