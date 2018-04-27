# RCS: @(#) $Id: dblas1.0.1.tcl,v 1.3 2002/06/25 08:42:51 fab Exp $

package require blasObj

namespace eval blas {}
fidev_load ../src/libtcl_dblas1 Dblas1

set HELP(dblas1) {
}

package provide dblas1 0.1

