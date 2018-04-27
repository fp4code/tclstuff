#!/usr/local/bin/tclsh

# 1999/06/03 (FP)

set table [exec rsh -n l2mk /usr/lib/nis/nisaddent -d netgroup]

set table [lsort [split $table \n]]

foreach l $table {
    puts $l
}
