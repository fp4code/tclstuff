# RCS: @(#) $Id: blasObj.tcl,v 1.3 2002/06/25 08:42:50 fab Exp $

namespace eval blas {}
fidev_load ../src/libtclblasObj BlasObj

proc blas::getallsvdata {sv} {
    return -code error "Obsolète, utiliser \"blas::subvector getvector ...\""
    return [lindex $sv 3]
}

package provide blasObj 0.1
