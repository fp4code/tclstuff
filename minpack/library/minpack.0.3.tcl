# RCS: @(#) $Id: minpack.0.3.tcl,v 1.3 2002/06/25 08:42:55 fab Exp $

set dir [file dirname [info script]]
fidev_load ../src/libtclminpack.0.3 minpack

namespace eval minpack {
    variable lmder1_info
    set lmder1_info(0) "improper input parameters"
    set lmder1_info(1) "relative error in the sum of squares is at most tol"
    set lmder1_info(2) "relative error between x and the solution is at most tol"
    set lmder1_info(3) "relative error in the sum of squares and between x and the solution are at most tol"
    set lmder1_info(4) "fvec is orthogonal to the columns of the jacobian to machine precision"
    set lmder1_info(5) "number of calls to fcn with iflag = 1 has reached 100*(n+1)"
    set lmder1_info(6) "tol is too small. no further reduction in the sum of squares is possible"
    set lmder1_info(7) "tol is too small. no further improvement in the approximate solution x is possible"
}

proc ::minpack::lmder1_info {info} {
    variable lmder1_info
    return $lmder1_info($info)
}

package provide minpack 0.3
