#!/usr/local/bin/tclsh

package require fidev
package require trig_sun

puts "atan2pi(0.0, -1.0) = [expr atan2pi(0.0, -1.0)]"
puts "atan2pi(-1.0, 0.0) = [expr atan2pi(-1.0, 0.0)]"

proc tzer x {
    set sp [expr {sinpi($x)}]
    set cp [expr {cospi($x)}]
    set s [expr {sin($x)}]
    set c [expr {cos($x)}]
    return [list [expr {$sp*$sp + $cp*$cp - 1.0}] [expr {$s*$s + $c*$c - 1.0}]]
}


