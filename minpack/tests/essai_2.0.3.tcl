#!/usr/local/bin/tclsh

package require fidev
package require blasObj 0.2
package require minpack 0.3

# la fonction      {f = x^2+y^2}
# et son jacobien: {df/dx = 2*x} {df/dy = 2*y}

set fcn    "::minpack::essai2"

# estimation initiale x=10, y=50

set x      [::blas::vector create double {10 50}]
set n      [::blas::vector length $x]

# nombre de fonctions, allocation de la place

set m      2
set fvec   [::blas::vector create double -length $m]

# ldfjac est le pas du tableau jacobien. Doit être >= $m
# allocation de la place pour le jacobien 

set ldfjac 10
set fjac   [::blas::vector create double -length [expr $ldfjac*$n]]

# tolérance

set tol    1e-15

# tableau des permutations retournées

set ipvt   [::blas::vector create long -length $n]

# allocation d'un tableau de travail de dimension >= 5*n+m

set lwa    [expr 5*$n+$m]
set wa     [::blas::vector create double -length $lwa]

# appel de la procédure

::minpack::lmder1 $fcn $m $n $x $fvec $fjac $ldfjac $tol info $ipvt $wa $lwa

puts "$info -> [::minpack::lmder1_info $info]"

# impression de l'estimation finale

puts "minimum des carrés en \"$x\""

