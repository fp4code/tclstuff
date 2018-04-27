

canvas .c
.c configure -width 219 -height 219
pack .c

set 1sr3 [expr 1.0 / sqrt(3.0)]

proc isoc {x} {
    return [expr int($x / sqrt(3.0))]
}


proc poly {u1 u2 tag} {
    
    set v1 [isoc $u1]
    set v2 [isoc $u2]
    
    incr u1 1
    incr u2 -1
    incr v1 0
    incr v2 -1
        
    .c create polygon $u1 $v1 $u2 $v2 $u2 -$v2 $u1 -$v1 -outline black -fill {} -tag x+$tag
    .c create polygon $v1 $u1 $v2 $u2 -$v2 $u2 -$v1 $u1 -outline black -fill {} -tag y-$tag
    .c create polygon -$u1 -$v1 -$u2 -$v2 -$u2 $v2 -$u1 $v1 -outline black -fill {} -tag x+$tag
    .c create polygon -$v1 -$u1 -$v2 -$u2 $v2 -$u2 $v1 -$u1 -outline black -fill {} -tag y+$tag
    .c create text 0 [expr $u2-10] -text $tag -justify right

    incr u1 -1
    incr v1 2
    incr u2 -2
    incr v2 2

    .c create polygon $u1 $v1 $u2 $v2 $v2 $u2 $v1 $u1 -outline black -fill {} -tag x+${tag}y-$tag
    .c create polygon -$u1 $v1 -$u2 $v2 -$v2 $u2 -$v1 $u1 -outline black -fill {} -tag x-${tag}y+$tag
    .c create polygon -$u1 -$v1 -$u2 -$v2 -$v2 -$u2 -$v1 -$u1 -outline black -fill {} -tag x-${tag}y+$tag
    .c create polygon $u1 -$v1 $u2 -$v2 $v2 -$u2 $v1 -$u1 -outline black -fill {} -tag x-${tag}y-$tag
}

.c delete all
poly 10 50 10
poly 50 70 100
poly 70 90 1000
poly 90 110 10000

# .c bind DEPL <Button> {puts "%x %y"; puts [.c gettags [.c find closest %x %y]]}
.c bind all <Button> {puts [lindex [.c gettags current] 0]}

.c move all 110 110
