package provide fidevFloating 0.2

#####################################################################
# procedures to show internal IEEE standard "double" representation #
#####################################################################

# big endian code

proc floatToBinarBigEndian {d} {
    binary scan [binary format d $d] B* v
    set sign [string index $v 0]
    set exponent [string range $v 1 11]
    set mantissa [string range $v 12 end]
    return [list $sign $mantissa $exponent]
}

proc binarToFloatBigEndian {sign mantissa exponent} {
    if {$sign != "0" && $sign != "1"} {
	error "bad sign \"$sign\""
    }
    if {[string length $mantissa] != 52} {
	error "bad mantissa \"$mantissa\""
    }
    if {[string length $exponent] != 11} {
	error "bad exponent \"$exponent\""
    }
    set v [binary format B64 $sign$exponent$mantissa]
    binary scan $v d v
    return $v
}

# little endian code

proc __reverse__ {s} {
    for {set i [string length $s]} {$i>=0} {incr i -1} {
        append sr [string index $s $i]
    }
    return $sr
}

proc floatToBinarLittleEndian {d} {
    binary scan [binary format d $d] b* v
    set v [__reverse__ $v]
    set sign [string index $v 0]
    set exponent [string range $v 1 11]
    set mantissa [string range $v 12 end]
    return [list $sign $mantissa $exponent]
}

proc binarToFloatLittleEndian {sign mantissa exponent} {
    if {$sign != "0" && $sign != "1"} {
	error "bad sign \"$sign\""
    }
    if {[string length $mantissa] != 52} {
	error "bad mantissa \"$mantissa\""
    }
    if {[string length $exponent] != 11} {
	error "bad exponent \"$exponent\""
    }
    set v [binary format b64 [__reverse__ $sign$exponent$mantissa]]
    binary scan $v d v
    return $v
}

###################################
# platform independent procedures #
###################################

proc floatToBinar {d} {
    global tcl_platform
    switch $tcl_platform(byteOrder) {
        "bigEndian" {return [floatToBinarBigEndian $d]}
        "littleEndian" {return [floatToBinarLittleEndian $d]}
        default {return -code error "unknown byteOrder \"$tcl_platform(byteOrder)\""}
    }
}

proc binarToFloat {sign mantissa exponent} {
    global tcl_platform
    switch $tcl_platform(byteOrder) {
        "bigEndian" {return [binarToFloatBigEndian $sign $mantissa $exponent]}
        "littleEndian" {return [binarToFloatLittleEndian $sign $mantissa $exponent]}
        default {return -code error "unknown byteOrder \"$tcl_platform(byteOrder)\""}
    }
}

proc floatToBinarTest {value sign mantissa exponent} {
    set r [floatToBinar $value]
    if {
        [lindex $r 0] != $sign ||
        [lindex $r 1] != $mantissa ||
        [lindex $r 2] != $exponent
    } {
        return -code error "this machine is not IEEE floating point compliant"
    }
}

set test {

floatToBinarTest  1.0      0 0000000000000000000000000000000000000000000000000000 01111111111
floatToBinarTest -1.0      1 0000000000000000000000000000000000000000000000000000 01111111111

# An example why you should put braces around "expr" argument

set tcl_precision 12
set pi [expr {acos(-1.0)}]
floatToBinarTest $pi           0 1001001000011111101101010100010001000010110100011000 10000000000
floatToBinarTest [expr {$pi}]  0 1001001000011111101101010100010001000010110100011000 10000000000
floatToBinarTest [expr $pi]    0 1001001000011111101101010100010001000010111011101010 10000000000

# the 17 digits string representation is exact

set tcl_precision 17
set pi [expr {acos(-1.0)}]
floatToBinarTest $pi           0 1001001000011111101101010100010001000010110100011000 10000000000
floatToBinarTest [expr {$pi}]  0 1001001000011111101101010100010001000010110100011000 10000000000
floatToBinarTest [expr $pi]    0 1001001000011111101101010100010001000010110100011000 10000000000

puts [binarToFloat 0 1001001000011111101101010100010001000010110100010111 10000000000] ;# 3.1415926535897927
puts [binarToFloat 0 1001001000011111101101010100010001000010110100011000 10000000000] ;# 3.1415926535897931
                                                                        #parameter (dpi = 3.14159265358979311600D+00)
                                                                             #define M_PI 3.14159265358979323846
                                                                                          3.1415926535897932384626433
0  100 1001 0000 1111 1101 1010 1010 0010 0010 0001 0110 1000 1100 0  100 0000 0000
puts [binarToFloat 0 1001001000011111101101010100010001000010110100011001 10000000000] ;# 3.1415926535897936 

puts [binarToFloat 0 1001001000011111101101010100010001000010110100010111 10000000000] ;# 3.1415926535897927
puts [binarToFloat 0 1001001000011111101101010100010001000010110100011000 10000000000] ;# 3.1415926535897931
puts [binarToFloat 0 1001001000011111101101010100010001000010110100011001 10000000000] ;# 3.1415926535897936 

binarToFloat 0 0000000000000000000000000000000000000000000000000000 00000000000        ;# 0.0
binarToFloat 0 0000000000000000000000000000000000000000000000000001 00000000000        ;# 4.9406564584124654e-324
binarToFloat 0 1111111111111111111111111111111111111111111111111111 00000000000        ;# 2.2250738585072009e-308
binarToFloat 0 0000000000000000000000000000000000000000000000000000 00000000001        ;# 2.2250738585072014e-308
binarToFloat 0 0000000000000000000000000000000000000000000000000000 11111111110        ;# 8.9884656743115795e+307
binarToFloat 0 1111111111111111111111111111111111111111111111111111 11111111110        ;# 1.7976931348623157e+308
binarToFloat 0 0000000000000000000000000000000000000000000000000000 11111111111        ;# inf
binarToFloat 1 0000000000000000000000000000000000000000000000000000 11111111111        ;# -inf
binarToFloat 0 1111111111111111111111111111111111111111111111111111 11111111111        ;# nan
binarToFloat 1 1111111111111111111111111111111111111111111111111111 11111111111        ;# nan

}