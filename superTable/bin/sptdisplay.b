#!/prog/Tcl/bin/wish

package require fidev
package require tkSuperTable 1.3
package require tkstcb_Diodir 0.1
package require tkstcb_gnuplot 2.0
package require tkstcb_verifOptR 1.0

set font "-b&h-lucidatypewriter-medium-r-normal-sans-12-*-*-*-*-*-iso8859-1"
option add *Font $font

set win [::tkSuperTable::sptLoader .]

tkSuperTable::changeEntry $win.ecb callbacks::gnuplot

