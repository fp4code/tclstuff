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

set adresse gide.uchicago.edu
set book enc1

file mkdir $adresse
::http::copy http://${adresse}/$book $adresse/$book

proc getall {file newFileNamesVar} {
    upvar $newFileNamesVar newFileNames
    set newDirNames [list]
    set f [open $file r]
    set lignes [read -nonewline $f]
    close $f
    set lignes [split $lignes \n]
    set nlignes [llength $lignes]
    set ok [regexp {^<HEAD><TITLE>Index of (.+)</TITLE></HEAD><BODY>$} [lindex $lignes 0] tout dir1]
    if {$ok == 0} {
        error "ligne 0"
    }
    set ok [regexp {^<H1>Index of (.+)</H1>$} [lindex $lignes 1] tout dir2]
    if {$ok == 0} {
        error "ligne 1"
    }
    if {$dir1 != $dir2} {
        error "HEAD != H1 : $dir1 != $dir2"
    }
    set DIR $dir1
    set ok [regexp {^<PRE><IMG SRC="/icons/blank.gif" ALT="     "> Name                   Last modified     Size  Description$} [lindex $lignes 2]]
    if {$ok == 0} {
        error "ligne 2"
    }
    set ok [regexp {^<HR>$} [lindex $lignes 3]]
    if {$ok == 0} {
        error "ligne 3"
    }
    set ok [regexp {^</PRE></BODY>$} [lindex $lignes [expr {$nlignes - 1}]]]
    if {$ok == 0} {
        error "ligne finale"
    }
    foreach l [lrange $lignes 4 [expr {$nlignes - 2}]] {
        set ok [regexp {^<IMG SRC="/icons/(.+).gif" ALT="\[(.+)\]"> <A HREF="(.+)">(.+)</A> +([^ ]+) ([^ ]+) +([^ ]+) *$} \
            $l tout icon alt href nom date heure taille]
        if {$ok == 0} {
            error "ligne $l"
        }
        puts [list $ok $icon $alt $href $nom $date $heure $taille]
        if {$icon == "folder"} {
            set lappend newDirNames $DIR/$href
        } elseif {$icon != "back"} {
            set newFileNames($DIR/$href) $icon
        }
    }
    return $newDirNames
}

set newDirNames [getall gide.uchicago.edu/enc1 newFileNames]


foreach f $newDirNames {
    if {![info exists exploredDirNames($f)]} {
        
    }

}
