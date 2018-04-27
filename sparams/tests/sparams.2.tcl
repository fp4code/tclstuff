package require fidev
package require superTable
package require blasObj
package require dblas1
package require zblas1
package require sparams2

set pass [blas::vector create doublecomplex {0 0 1 0 1 0 0 0}]
set pass1 $pass
set pass2 $pass
sparams::ScombR pass $pass2
sparams::ScombL $pass2 pass

set M_PI [expr {4.0*atan(1.0)}]
set 2M_PI [expr {2.0*$M_PI}]
set omega [blas::vector create double {1e9 10e9}]
blas::mathsvop omega *scal ${2M_PI}

set line1 [blas::vector create doublecomplex -length 8]
sparams::SofLine line1 1.0 [expr {100e-6/299792458.}] $omega
set line2 [blas::vector create doublecomplex -length 8]
sparams::SofLine line2 1.0 [expr {200e-6/299792458.}] $omega
set line3 [blas::vector create doublecomplex -length 8]
sparams::SofLine line3 1.0 [expr {300e-6/299792458.}] $omega
set lineA $line1
sparams::ScombR lineA $line2
set lineB $line2
sparams::ScombL $line1 lineB
