package provide zblas1 0.1

package require blasObj

namespace eval blas {}

load $fidev_libDir/libtcl_zblas1.so Zblas1

set HELP(zblas1) {
}
