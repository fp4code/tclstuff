# RCS: @(#) $Id: zblas1.0.1.tcl,v 1.3 2002/06/25 08:43:08 fab Exp $

package require -exact blasObj 0.1

namespace eval blas {}

fidev_load ../src/libtcl_zblas1.0.1 Zblas1

set HELP(zblas1) {
}
package provide zblas1 0.1
