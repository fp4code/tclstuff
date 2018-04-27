#!/bin/sh
# \
exec tclsh "$0" ${1+"$@"}

# 12 avril 2001 (FP)
puts "\nFit lin�aire par la m�thode des moindres carr�s,"
puts "    exemple de fit de polyn�mes du second degr�."

package require fidev
package require blasObj
package require port3_lin_np

# nombre d'�chantillons par probl�me
set m 100

# nombre de variables
set n 3 ;# a b c

# nombre de probl�mes
set irhs 2 ;# 1 2

# variables du probl�me 1
set a1 -1
set b1 2
set c1 3

# variables du probl�me 2
set a2 10
set b2 0
set c2 5

# gamme de variables x
set fx 10

# bruit
set fy 0.1
puts "    bruit = $fy"

# variable libre
set xi [list]

# variable mesur�e, probl�me 1
set y1i [list]

# variable mesur�e, probl�me 2
set y2i [list]

# futures matrices
set a [list]
set b [list]

for {set i $m} {$i > 0} {incr i -1} {
    set x [expr {$fx*rand()}]
    lappend xi $x
    lappend y1i [expr {($c1*$x + $b1)*$x + $a1 + $fy*rand()}]
    lappend y2i [expr {($c2*$x + $b2)*$x + $a2 + $fy*rand()}]
}

# construction de a
foreach x $xi {
    lappend a 1
}
foreach x $xi {
    lappend a $x
}
foreach x $xi {
    lappend a [expr {$x*$x}]
}
set a [blas::vector create double $a]

# construction de b
foreach y $y1i {
    lappend b $y
}
foreach y $y2i {
    lappend b $y
}
set b [blas::vector create double $b]

set w [blas::vector create double -length $n]
 
# appel de la proc�dure de moindres carr�s lin�aire
port3::dltsqRaw $m $n a $m b $irhs w

# r�cup�ration dans b des valeurs fitt�es

puts "\nFit 1:"
set idx 1
puts "$a1 -> [lindex $b $idx]"
incr idx
puts "$b1 -> [lindex $b $idx]"
incr idx
puts "$c1 -> [lindex $b $idx]"

puts "\nFit 2:"
set idx $m
incr idx
puts "$a2 -> [lindex $b $idx]"
incr idx
puts "$b2 -> [lindex $b $idx]"
incr idx
puts "$c2 -> [lindex $b $idx]"
