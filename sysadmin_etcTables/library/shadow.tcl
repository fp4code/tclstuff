#!/usr/local/bin/tclsh

# 1999/06/03 (FP)

set shadow [exec rsh -n l2mk /usr/lib/nis/nisaddent -d shadow]

set shadow [lsort [split $shadow \n]]

foreach h $shadow {
    puts $h
}
