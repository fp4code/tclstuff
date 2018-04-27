package require fidev
package require blasObj 0.2
package require port3_root_np 0.2
package require blasmath 0.2

# recherche des zéros d'un polynôme complexe (2)z^3 + (-8+13i)z^2 + (3+74i)z + (135+105i)

set c [blas::vector create doublecomplex {2 0 -8 13 3 74 135 105}]
set cr [blas::math re $c]
set ci [blas::math im $c]
set ndeg [expr {[blas::vector length $cr] - 1}]
set zr [blas::vector create double -length $ndeg]
set zi [blas::vector create double -length $ndeg]

port3::dcpoly $cr $ci zr zi

puts $zr ;# double -2.79738689561e-16 -3.0 7.0
puts $zi ;# double 2.5 6.96660882194e-16 -9.0

