package require Tk
package require fidev
package require blasObj
package require hsplot
set xy [blas::vector create short {10 10 10 0 20 10 30 0}]
canvas .c
pack .c
.c create hsplot 20 20 120 120 -xyblas xy -fill red
