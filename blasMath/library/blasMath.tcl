# RCS: @(#) $Id: blasMath.tcl,v 1.3 2002/06/25 08:42:50 fab Exp $

namespace eval blas {}

fidev_load ../src/libtclblasmath Blasmath

package provide blasmath 0.4
