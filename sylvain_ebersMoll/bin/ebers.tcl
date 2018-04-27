#!/usr/local/bin/wish

set q 1.6e-19
set k 1.38e-23
set T 300
set alphaF 0.95
set Ies1 1e-15
set Ics1 1e-12
set alphaR 0.01

set VbeMin 0.0
set VbeMax 1.5
set dVbe 0.01

set Vbc 0.0

set ploplo [open "|gnuplot 2>@ stderr" w]
fconfigure $ploplo -buffering line

puts $ploplo {set log y}
puts $ploplo {set yrange [1e-10:0.1]}

puts $ploplo {plot "-" using ($1):($2) with lines, "-" using ($1):($3) with lines} 

set data ""

for {set Vbe $VbeMin} {$Vbe <= $VbeMax} {set Vbe [expr {$Vbe + $dVbe}]} {
    set Ic [expr {$alphaF * $Ies1 * (exp($q * $Vbe/($k * $T)) - 1) -
                            $Ics1 * (exp($q * $Vbc/($k * $T)) - 1)}]
    set Ib [expr {(1 - $alphaF)*          $Ies1 * (exp($q * $Vbe/($k * $T)) - 1) -
                  $alphaR * $Ics1 * (exp($q * $Vbc/($k * $T)) - 1)}]
    append data "$Vbe\t$Ib\t$Ic\n"
}
append data "e\n"

puts -nonewline $ploplo $data
puts -nonewline $ploplo $data

