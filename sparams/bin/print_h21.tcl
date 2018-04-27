set F [::scilab::get $tid ${prefix}f]
set S11 [::scilab::get $tid ${prefix}s11]
set S12 [::scilab::get $tid ${prefix}s12]
set S21 [::scilab::get $tid ${prefix}s21]
set S22 [::scilab::get $tid ${prefix}s22]
set H21 [::scilab::get $tid ${prefix}h21]

set F [lindex $F 3]
set S11_r [lrange [lindex $S11 3] 0 [expr {[lindex $S11 1] - 1}]]
set S11_i [lrange [lindex $S11 3]          [lindex $S11 1] end]
set S12_r [lrange [lindex $S12 3] 0 [expr {[lindex $S12 1] - 1}]]
set S12_i [lrange [lindex $S12 3]          [lindex $S12 1] end]
set S21_r [lrange [lindex $S21 3] 0 [expr {[lindex $S21 1] - 1}]]
set S21_i [lrange [lindex $S21 3]          [lindex $S21 1] end]
set S22_r [lrange [lindex $S22 3] 0 [expr {[lindex $S22 1] - 1}]]
set S22_i [lrange [lindex $S22 3]          [lindex $S22 1] end]
set H21_r [lrange [lindex $H21 3] 0 [expr {[lindex $H21 1] - 1}]]
set H21_i [lrange [lindex $H21 3]          [lindex $H21 1] end]


puts "# [pwd] $prefix"
puts "# f s11_r s11_i s12_r s12_i s21_r s21_i s22_r s22_i h21_r h21_i"
foreach\
        i1 $F\
        i2 $S11_r i3 $S11_i\
        i4 $S12_r i5 $S12_i\
        i6 $S21_r i7 $S21_i\
        i8 $S22_r i9 $S22_i\
        i10 $H21_r i11 $H21_i\
        {
    puts [list [format %7.2e $i1] $i2 $i3 $i4 $i5 $i6 $i7 $i8 $i9 $i10 $i11]
}

set s11 [complexes::newXY 0.22484 -0.73416]
set s12 [complexes::newXY 0.080278 0.052092]
set s21 [complexes::newXY -1.3468 3.2067]
set s22 [complexes::newXY 0.5868 -0.56855]

lindex [sparams::HfromS $s11 $s12 $s21 $s22] 2
# -0.79203990483 -4.14746863056

