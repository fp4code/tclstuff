#!/usr/local/bin/tclsh

package require http

::http::config -proxyhost freeway -proxyport 8080


proc ::http::copy { url file {chunk 4096} } {
    set out [open $file w]
    set token [geturl $url -channel $out -progress ::http::Progress \
        -blocksize $chunk]
    close $out
    # This ends the line started by http::Progress
    puts stderr ""
    upvar #0 $token state
    set max 0
    foreach {name value} $state(meta) {
        if {[string length $name] > $max} {
            set max [string length $name]
        }
        if {[regexp -nocase ^location$ $name]} {
        # Handle URL redirects
            puts stderr "Location:$value"
            return [copy [string trim $value] $file $chunk]
        }
    }
    incr max
    foreach {name value} $state(meta) {
        puts [format "%-*s %s" $max $name: $value]
    }

    return $token
}

proc ::http::Progress {args} {
    puts -nonewline stderr . ; flush stderr
}

set adresse http://moa.cit.cornell.edu/Server/TR
#set book MATH:MATH3-00000405
#set nom peano
#set book MATH:MATH1-00000072
#set nom burali-forti
set book MATH:MATH1-00000151
set nom floquet
set firstPage 137
set pages 200

#for {set i $firstPage} {$i<$pages} {incr i} {
#puts $i
#::http::copy $adresse/$book/Page/$i?format=TIFFG4_300 $nom[format %03d $i].tiff
#}

set adresse http://gide.uchicago.edu
set book enc1
set volume 15
set firstPage 463
set lastPage 474

for {set i $firstPage} {$i<=$lastPage} {incr i} {
puts $i
set page [format %02d $i]
set file ENC_${volume}-${page}.jpeg
::http::copy $adresse/$book/V${volume}/$file $file
}

