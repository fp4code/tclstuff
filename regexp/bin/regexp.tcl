#!/bin/sh
# \
exec wish "$0" ${1+"$@"}

entry .r  -textvariable V(r)
entry .s  -textvariable V(s)
button .b -command rr
label .ret -textvariable V(ret)
label .l1 -textvariable V(l1)
label .l2 -textvariable V(l2)
label .l3 -textvariable V(l3)
label .l4 -textvariable V(l4)
label .l5 -textvariable V(l5)
label .l6 -textvariable V(l6)
label .l7 -textvariable V(l7)

proc rr {} {
    global V
    set V(ret) [regexp -- $V(r) $V(s) V(l1) V(l2) V(l3) V(l4) V(l5) V(l6) V(l7)]
}


pack .r .s .b .ret .l1 .l2 .l3 .l4 .l5 .l6 .l7
