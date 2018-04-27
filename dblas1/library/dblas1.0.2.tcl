# RCS: @(#) $Id: dblas1.0.2.tcl,v 1.3 2002/06/25 08:42:51 fab Exp $

package require blasObj

namespace eval blas {}
fidev_load ../src/libtcldblas1.0.2 Dblas1

set HELP(dblas1) {
}

package provide dblas1 0.2
