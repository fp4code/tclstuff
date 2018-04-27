#!/usr/local/bin/tclsh

package require fidev
package require fctlm_geom 0.1
package require fichUtils 1.0

set dir [pwd]
set out [fctlm_geom::readGeomAndQuality $dir]

set f [open geomEtalon.spt w]
foreach l $out {
    puts $f $l
}
close $f
puts "\nOK geomEtalon.spt est créé ou modifié"


