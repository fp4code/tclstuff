# RCS: @(#) $Id: blasObj.0.2.tcl,v 1.3 2002/06/25 08:42:50 fab Exp $

namespace eval blas {}
fidev_load ../src/libtclblasobj.0.2 BlasObj

proc blas::getallsvdata {sv} {
    return -code error "Obsolète, utiliser \"blas::subvector getvector ...\""
    return [lindex $sv 3]
}

package provide blasObj 0.2
