#!/usr/local/bin/tclsh

set fichier [open posmar8.rtf r]
set f [read -nonewline $fichier] ; close $fichier

proc ge {f index ic} {
    if {[lindex $ic 0] == -1} {
	return {}
    }
    return [string range $f [expr {[lindex $ic 0] + $index}] [expr {[lindex $ic 1] + $index}]]
}

set index 0
set stack 0
set BS ""
while {[set head [string index $f $index]] != {}} {
    if {$head == "\{"} {
	incr index
	puts "$BS\{"
	incr stack
	set BS "$BS    "
    } elseif {$head == "\}"} {
	incr stack -1
	set BS [string range $BS 0 [expr {[string length $BS] - 5}]]
	incr index
	puts "$BS\}"
    } elseif {$head == "\\"} {
	incr index
#	regexp -indices -- {^([^\\\{\}]+)} [string range $f $index end] tout a
#	regexp -indices -- {^([a-z]+)|(.)} [string range $f $index end] tout a
#	regexp -indices -- {^([a-z]+)|(.)} $t tout a

	set r [regexp  -indices -- {^(?:(?:([a-z]+)(-?)([0-9]+)?(\ ?))|(.))} \
		[string range $f $index end] itout ic1 ic2 ic3 ic4 isingle]
	#    
# puts [list [ge $f $index $itout] [ge $f $index $ic1] [ge $f $index $ic2] [ge $f $index $ic3] [ge $f $index $ic4] [ge $f $index $isingle]]
        set s0 [lindex $isingle 0]
	if {$s0 >= 0} {
	    incr s0 $index
            set char [string index $f $s0]
	    puts "$BS\"$char\""
	} else {
	    set c1_0 [expr {[lindex $ic1 0] + $index}]
	    set c1_1 [expr {[lindex $ic1 1] + $index}]
	    set c2_0 [expr {[lindex $ic2 0] + $index}]
	    set c2_1 [expr {[lindex $ic2 1] + $index}]
	    set c3_0 [expr {[lindex $ic3 0] + $index}]
	    set c3_1 [expr {[lindex $ic3 1] + $index}]
	    set c4_0 [expr {[lindex $ic4 0] + $index}]
	    set c4_1 [expr {[lindex $ic4 1] + $index}]
	    set commande [list [ge  $f $index $ic1] [ge $f $index $ic2] [ge $f $index $ic3] [ge $f $index $ic4]]
	    puts "$BS\"\\$commande\""
	}
	set index [expr {[lindex $itout 1] + $index + 1}]
    } else {
	set r [regexp -indices -- {^[^\\\{\}]*} [string range $f $index end] itout]
	if {$r != 0} {
	    set it0 [expr {[lindex $itout 0] + $index}]
	    set it1 [expr {[lindex $itout 1] + $index}]
	    puts "$BS\"[string range $f $it0 $it1]\""
	    set index [expr {$it1 + 1}]
	}
    }
}
