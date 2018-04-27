# $Id

package require suninterval
namespace eval scplxi {}
fidev_load ../src/libtclscplxi.0.1 Scplxi
package provide scplxi 0.1

proc scplxi::wid {z} {
    return [list [lindex $z 0] [di wid [lindex $z 1]] [di wid [lindex $z 2]]]
}