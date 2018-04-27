#!tclsh8.0

set fifi [open geom.txt r]

set i 1
while {![eof $fifi ]} {
    gets $fifi ligne
    puts "$i $ligne"
    incr i
}
