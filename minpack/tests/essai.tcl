#!/usr/local/bin/tclsh

package require fidev
package require blas
package require minpack

# la fonction      {f = 10*(2*y-x^2)} {g = 1-x}
# et son jacobien: {df/dx = -20*x}  {dg/dx = -1} ... {df/dy = 20} {dg/dy = 0} ...

set fcn    "::minpack::essaiRosenbrock"

# estimation initiale x=10, y=50

set x      [::blas::newVector double {10 50}]
set n      [::blas::getDataLength $x]

# nombre de fonctions, allocation de la place

set m      2
set fvec   [::blas::newVector double -length $m]

# ldfjac est le pas du tableau jacobien. Doit ici être >= 2
# allocation de la place pour le jacobien 

set ldfjac 10
set fjac   [::blas::newVector double -length [expr $ldfjac*$n]]

# tolérance

set tol    1e-15

# tableau des permutations retournées

set ipvt   [::blas::newVector int -length $n]

# allocation d'un tableau de travail de dimension >= 5*n+m

set lwa    [expr 5*$n+$m]
set wa     [::blas::newVector double -length $lwa]

# appel de la procédure

::minpack::lmder1 $fcn $m $n $x $fvec $fjac $ldfjac $tol info $ipvt $wa $lwa


puts "$info -> [::minpack::lmder1_info $info]"

# impression de l'estimation finale

puts "minimum des carrés en [::blas::getVector $x]"
