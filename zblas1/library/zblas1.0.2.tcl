# RCS: @(#) $Id: zblas1.0.2.tcl,v 1.3 2002/06/25 08:43:09 fab Exp $

package require -exact blasObj 0.2

namespace eval blas {}

fidev_load ../src/libtclzblas1.0.2 Zblas1

set HELP(zblas1) {
}

package provide zblas1 0.2
