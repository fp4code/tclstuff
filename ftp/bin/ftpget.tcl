#!/bin/sh
# la ligne suivante lance tclsh mais elle est ignorée par lui \
exec tclsh "$0" "$@"

# Interface avec "wget -desArguments ftp://..." au travers de freeway
# (FP) 2000-05-31 création

set argumes [lrange $argv 0 end-1]
set quoi [lindex $argv end]
if {[string range $quoi 0 5] != "ftp://"} {
    puts stderr "le dernier argument doit commencer par \"ftp://\""
    exit 1
}
set quoi [string range $quoi 6 end]
set slashpos [string first "/" $quoi]
if {$slashpos < 0} {
    puts stderr "e dernier argument doit commencer par \"ftp://machine/\""
    exit 1
}
set machine [string range $quoi 0 [expr {$slashpos-1}]]
set quoi [string range $quoi $slashpos end]

catch {file mkdir $machine}
cd $machine

puts "eval exec wget $argumes [list ftp://anonymous%40${machine}@freeway${quoi}] 2>@ stderr"

eval exec wget $argumes [list ftp://anonymous%40${machine}@freeway${quoi}] 2>@ stderr
