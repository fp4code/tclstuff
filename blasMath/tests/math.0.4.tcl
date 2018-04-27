package require fidev
package require blasObj
package require blasmath

set f [blas::vector create double {0.0 0.1 0.2}]
blas::mathsvop f sin

set y [blas::vector create double {0.1 0.2 0.3}]
set x [blas::vector create double {1.0 10.0 100.0}]
set f [blas::vector create double -length 3]
blas::mathsvop f atan2 $y $x

set f [blas::vector create double {1.0 10.0 100.0}]
set g [blas::vector create double {2. 2. 2.}]
blas::mathsvop f pow $g

set f [blas::vector create double {1. 10. 100.}]
blas::mathsvop f log

set j0 [blas::vector create double {1. 10. 100.}]
set j1 $j0
set jn0 $j0
set jn1 $j0
set y0 $j0
set y1 $j0
set yn0 $j0
set yn1 $j0
set g0 [blas::vector create short {0 0 0}]
set g1 [blas::vector create short {1 1 1}]
blas::mathsvop j0 j0
blas::mathsvop j1 j1
blas::mathsvop jn0 jn $g0
blas::mathsvop jn1 jn $g1
blas::mathsvop y0 y0
blas::mathsvop y1 y1
blas::mathsvop yn0 yn $g0
blas::mathsvop yn1 yn $g1
set j0
set jn0
set j1
set jn1
set y0
set yn0
set y1
set yn1

set f [blas::vector create double {0.0 1.0 10.0}]
blas::mathsvop f log
set g [blas::vector create short -length 3]
blas::mathsvop g isnan $f
set g
blas::mathsvop f log
blas::mathsvop g isnan $f
set g

set f [blas::vector create short -length 4]
set g [blas::vector create double {0.0 1.0 10.0 100.0}]
blas::mathsvop f ilogb $g
set f

set f [blas::vector create double {1.0 1.0 1.0 1.0 1.0 1.0}]
blas::mathsvop f scalbn [blas::vector create long {-2 -1 0 1 2 3}]
set f

set f [blas::subvector create 2 2 4 {double 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0}]
blas::mathsvop f scalbn [blas::vector create long {1 2 3 4}]
set f

set f [blas::subvector create 4 -2 4 {double 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0}]
blas::mathsvop f scalbn [blas::vector create long {1 2 3 4}]
set f


set f [blas::subvector create 1 2 4 {double 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0}]
blas::mathsvop f scalbn [blas::vector create long {1 2 3 4}]
set f


package require dblas1
set f [blas::subvector create 10 -2 4 {double 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0}]
set f [blas::vector create double {0 0 0 0}]
blas::daxpy 10 [blas::vector create double {2 3 4 5}] f

# f s11r s11i s12r s12i s21r s21i s22r s22i    

# memory validate on
package require fidev
package require blasObj
set f [blas::vector create doublecomplex {1 0 0 1 2 2}]
blas::mathsvop f inverse
set f

set f [blas::subvector create 1 2 2 {double 1 2 3 4}]
blas::mathsvop f *rscal 10
set f



blas::mathop connexBounds {double 1 4 5 6 7 8 9 10 11 23} 5.5 11.1
4 9
blas::mathop connexBounds {double 1 4 5 6 7 8 9 10 11 23} 6 11
4 9
blas::mathop connexBounds {double 1 4 5 6 7 8 9 10 11 23} 11 6
out of limits
blas::mathop connexBounds {double 1 4 5 6 7 8 9 10 11 23} -1 11
1 9
blas::mathop connexBounds {double 1 4 5 6 7 8 9 10 11 23} -1 25
1 10
blas::mathop connexBounds {double 1 4 5 6 7 8 9 10 11 23} -1 0
out of limits
blas::mathop connexBounds {double 1 4 5 6 7 8 9 10 11 23} -1 1
1 1
blas::mathop connexBounds {double 1 4 5 6 7 8 9 10 11 23} 23 23
10 10
blas::mathop connexBounds {double 1 4 5 6 7 8 9 10 11 23} 22 25
10 10
blas::mathop connexBounds {double 1 4 5 6 7 6 9 10 11 23} 22 25
10 10
blas::mathop connexBounds {double 1 4 5 6 7 6 9 10 11 23} 6.5 11
non connex


