package require fidev
package require blasObj

set f [blas::vector create double {0.0 0.1 0.2}]
blas::math dsvop f sin

set y [blas::vector create double {0.1 0.2 0.3}]
set x [blas::vector create double {1.0 10.0 100.0}]
set f [blas::vector create double -length 3]
blas::math dsvop f atan2 $y $x

set f [blas::vector create double {1.0 10.0 100.0}]
set g [blas::vector create double {2. 2. 2.}]
blas::math dsvop f pow $g

set f [blas::vector create double {1. 10. 100.}]
blas::math dsvop f log

set j0 [blas::vector create double {1. 10. 100.}]
set j1 $j0
set jn0 $j0
set jn1 $j0
set y0 $j0
set y1 $j0
set yn0 $j0
set yn1 $j0
set g0 [blas::vector create long {0 0 0}]
set g1 [blas::vector create long {1 1 1}]
blas::math dsvop j0 j0
blas::math dsvop j1 j1
blas::math dsvop jn0 jn $g0
blas::math dsvop jn1 jn $g1
blas::math dsvop y0 y0
blas::math dsvop y1 y1
blas::math dsvop yn0 yn $g0
blas::math dsvop yn1 yn $g1
set j0
set jn0
set j1
set jn1
set y0
set yn0
set y1
set yn1

set f [blas::vector create double {0.0 1.0 10.0}]
blas::math dsvop f log
set g [blas::vector create long -length 3]
blas::math dsvop g isnan $f
set g
blas::math dsvop f log
blas::math dsvop g isnan $f
set g

set f [blas::vector create long -length 4]
set g [blas::vector create double {0.0 1.0 10.0 100.0}]
blas::math dsvop f ilogb $g
set f

set f [blas::vector create double {1.0 1.0 1.0 1.0 1.0 1.0}]
blas::math dsvop f scalbn [blas::vector create long {-2 -1 0 1 2 3}]
set f

set f [blas::subvector 2 2 4 {double 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0}]
blas::math dsvop f scalbn [blas::vector create long {1 2 3 4}]
set f

set f [blas::subvector 4 -2 4 {double 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0}]
blas::math dsvop f scalbn [blas::vector create long {1 2 3 4}]
set f


set f [blas::subvector 1 2 4 {double 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0}]
blas::math dsvop f scalbn [blas::vector create long {1 2 3 4}]
set f


package require dblas1
set f [blas::subvector create 10 -2 4 {double 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0}]
set f [blas::vector create double {0 0 0 0}]
blas::daxpy 10 [blas::vector create double {2 3 4 5}] f

# f s11r s11i s12r s12i s21r s21i s22r s22i    

# memory validate on
package require fidev
package require blasObj
set f [blas::vector create double {1 0 0 1 2 2}]
blas::math dsvop f zinverse
set f

set f [blas::subvector create 1 2 2 {double 1 2 3 4}]
blas::math dsvop f *scal 10
set f


