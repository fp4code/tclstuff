package provide tkstcb_Diodir 0.1

package require asdex

namespace eval tkSuperTable::callbacks {}

set tkSuperTable::callbacks::CALLBACKS(DioDir) {}

proc tkSuperTable::callbacks::DioDir {win} {
puts [list win= $win]
}

