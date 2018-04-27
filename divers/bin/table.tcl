#!/usr/local/bin/wish
 
 # a program displaying any expression table (FP)

 set first 0
 set last 9
 set expr {$a+$b}

 package require Tk
 set LP lp  ;# machine dependent print command
 
 proc showTable {first last oper} {
     set terms [list]
     for {set i $first} {$i <= $last} {incr i} {
         lappend terms $i
     }
     set n [llength $terms]
     
     set hdx 12
     set hdy 11
     set bx 20
     set by 20
     
     .c delete all
     .c configure -width [expr {2*($n+1)*$hdx + 2*$bx}] -height [expr {(2*$n+4)*$hdy + 2*$by}]
     set ia 0
     foreach a $terms {
         incr ia
         set ib 0
         foreach b $terms {
             incr ib
             set r [expr $oper]
             .c create text [expr {(2*$ib+1)*$hdx + $bx}] [expr {(2*$ia+1)*$hdy + $by}] -text $r
         }
     }
     .c create text [expr {($n+1)*$hdx + $bx}] [expr {(2*$n+4)*$hdy + $by}] -text $oper
     
     set ia 0
     foreach a $terms {
         incr ia
         .c create text [expr {(2*$ia+1)*$hdx + $bx}] [expr {$by + $hdy}] -text $a
         .c create text [expr {$bx + $hdx}] [expr {(2*$ia+1)*$hdy + $by}] -text $a
         .c create line\
                 [expr {$bx}] [expr {$by + (2*$ia+2)*$hdy}]\
                 [expr {$bx + (2*$n + 2)*$hdx}] [expr {$by + (2*$ia+2)*$hdy}]
         .c create line\
                 [expr {$bx + (2*$ia+2)*$hdx}] [expr {$by}]\
                 [expr {$bx + (2*$ia+2)*$hdx}] [expr {$bx + (2*$n+2)*$hdy}]
     }
     .c create line\
             [expr {$bx + 2*$hdx}] [expr {$by}]\
             [expr {$bx + (2*$n+2)*$hdx}] [expr {$by}] -width 2
     .c create line\
             [expr {$bx}] [expr {$by + 2*$hdy}]\
             [expr {$bx}] [expr {$bx + (2*$n+2)*$hdy}] -width 2
     .c create line\
             [expr {$bx}] [expr {$by + 2*$hdy}]\
             [expr {$bx + (2*$n+2)*$hdx}] [expr {$by + 2*$hdy}] -width 2
     .c create line\
             [expr {$bx + 2*$hdx}] [expr {$by}]\
             [expr {$bx + 2*$hdx}] [expr {$bx + (2*$n+2)*$hdy}] -width 2
 }
 
 canvas .c
 pack .c
 
 frame .f
 label .f.l1 -text from:
 label .f.l2 -text to:
 entry .f.e1 -textvariable first -width 2
 entry .f.e2 -textvariable last -width 2
 label .f.l3 -text {expr:}
 entry .f.e3 -textvariable expr
 pack .f.l1 .f.e1 .f.l2 .f.e2 -side left
 pack .f.e3 .f.l3 -side right
 pack .f -fill x
 
 button .bp -text print -command {exec $LP << [.c postscript]} 
 button .bq -text exit -command exit 
 pack .bq .bp -side left

 button .b -text show -command {showTable $first $last $expr}
 pack .b -side right -expand y -fill x
 .b invoke

 # end of program

