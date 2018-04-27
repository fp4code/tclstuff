#!/bin/sh
# The next line is a TK comment, but a shell command \
exec ./netlib "$0" "$@"

set pi [expr atan(1.0)*4]
puts "pi = $pi"
foreach v [netlib::frac $pi 1e-10] {
    foreach {n d e} $v {
        puts "pi = $n/$d +- $e"    
    }
}
