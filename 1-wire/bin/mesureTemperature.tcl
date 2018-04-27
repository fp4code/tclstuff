#!/bin/sh
# \
exec tclsh "$0" ${1+"$@"}

# 2002/10/16 (FP)

proc lit_dg {} {
    global THE_END DG FILES
    if {[eof $DG]} {
        close $DG
        set THE_END 1
        foreach f [array names FILES] {
            close $FILES($f)
        }
    } else {
        set ligne [gets $DG]
        if {[regexp {^([0-9]+/[01][0-9]/[0-3][0-9]_[012][0-9]:[0-5][0-9]:[0-5][0-9]) ([0-9A-F]+) (-*[0-9]+.[0-9]+)$} $ligne tout date dispo temp]} {
            if {![info exists FILES($dispo)]} {
                set FILES($dispo) [open "/home/fab/Y/Temperatures/$dispo.temperature" a]
                puts $FILES($dispo) #
            }
            puts $FILES($dispo) "$date $temp"
            flush $FILES($dispo)
        } else {
            puts stderr "[clock format [clock seconds] -format "%Y/%m/%d_%H:%M:%S"] $ligne" 
        }
    }
}
set DG [open "|/home/fab/A/fidev/c/digitemp-2.6.1/digitemp -s/dev/ttyS1 -a -o \"%Y/%m/%d_%H:%M:%S %R %.3C\" -d 10 -n -1 2>@ stdout" r]
fileevent $DG readable lit_dg
fconfigure $DG -buffering line -blocking 1 ;# et j'ai patché digitemp pour fflush(stdout)
set THE_END 0
vwait THE_END
