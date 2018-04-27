#!/bin/sh
# The next line is executed by /bin/sh, but not tcl \
exec tclsh "$0" ${1+"$@"}

package require fichUtils 0.2

proc explore {dir dev errors&} {
    puts stderr "explore $dir"
    cd $dir
    upvar ${errors&} errors
    set fichiers [glob -nocomplain .* *]
    foreach f $fichiers {
        if {$f == "." || $f == ".."} {
            continue
        }
        set next [file join $dir $f]
        set err [catch {file stat $f attrib} message]
        if {$err} {
            lappend errors "file stat \"$next\" : $message"
            continue
        }
        switch $attrib(type) {
            "directory" {
                if {$attrib(dev) == $dev} {
                    explore $next $dev errors
                    cd $dir
                } else {
                    lappend errors "other dev : \"$next\""
                }
            }
            "file" {
                set md5sum [::fidev::fichUtils::md5sum $f]
                binary scan $md5sum H32 md5sum
                puts stderr "$md5sum $next"
            }
            "link" {
                A FAIRE
            }
            default {
                lappend errors "unknown type : $attrib(type) for \"$next\""
            }
        } 
    }
}

set ici [pwd]
file stat $ici attrib
explore $ici $attrib(dev) ERRORS
