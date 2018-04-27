#!/bin/sh
# \
exec tclsh "$0" ${1+"$@"}

# 17 juillet 2003 (FP)

package require tdom 0.7.7
package require fidev
package require fidev_xh 0.1

set input [read stdin]

set script [info script]
while {[file type $script] == "link"} {set script [file readlink $script]}
set DTDDIR [file join [file dirname $script] .. dtd]

# set input {blabla<p>blibli&eacute;</p><a href="toto.html">toto</a>}

set fichier /tmp/[pid].html
set f [open $fichier w]
puts $f "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01//EN\" \"http://www.w3.org/TR/html4/strict.dtd\">\n<html><head><title>dummy</title></head><body>$input</body>"
close $f

xh::tidy $fichier
# file delete ${fichier}.original

set f [open $fichier r]
set newData [read $f]

# puts $newData

close $f
file delete $fichier

proc readLocalDTD {base_uri system public} {
    global DTDDIR
    set f [file join $DTDDIR [file tail $system]]
    if {![file exists $f]} {return -code error "Missing file $f in [pwd]]"}
    set ff [open $f r] ; set data [read $ff] ; close $ff
    return [list string $base_uri $data] ;# Pour $base_uri, c'est pas clair
}

# puts $newData
set document [dom parse -externalentitycommand readLocalDTD $newData]

set root [$document documentElement]
set bodyNode {}
foreach node [$root childNodes] {
    if {[$node nodeName] == "body"} {
	set bodyNode $node
	break
    }
}

if {$bodyNode == {}} {
    return -code error "Pas de node body"
}

set body [$bodyNode asHTML]

if {![regexp {^<body>(.*)</body>$} $body tout result]} {
    return -code error "cannot regexp"
}

puts $result
