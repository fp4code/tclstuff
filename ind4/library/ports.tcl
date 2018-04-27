#!/usr/local/bin/tclsh

namespace eval ind4 {}

# offsets des cartes

set inBase(0) 0x120
set inBase(1) 0x130
set inBase(2) 0x140
set inBase(3) 0x150
set outBase(0) 0x160
set outBase(1) 0x170
set outBase(2) 0x180
set outBase(3) 0x190

# entrées +5V 1kOhm

set inOffset([list 0 fdc+]) 0 ; set bit([list 0 fdc+]) 0x02 ; set pin([list 0 fdc+]) [list J1 55]
set inOffset([list 0 fdc-]) 0 ; set bit([list 0 fdc-]) 0x01 ; set pin([list 0 fdc-]) [list J1 57]
set inOffset([list 1 fdc+]) 0 ; set bit([list 1 fdc+]) 0x08 ; set pin([list 1 fdc+]) [list J1 40]
set inOffset([list 1 fdc-]) 0 ; set bit([list 1 fdc-]) 0x04 ; set pin([list 1 fdc-]) [list J1 42]
set inOffset([list 2 fdc+]) 0 ; set bit([list 2 fdc+]) 0x20 ; set pin([list 2 fdc+]) [list J1 25]
set inOffset([list 2 fdc-]) 0 ; set bit([list 2 fdc-]) 0x10 ; set pin([list 2 fdc-]) [list J1 27]
set inOffset([list 3 fdc+]) 0 ; set bit([list 3 fdc+]) 0x80 ; set pin([list 3 fdc+]) [list J1 10]
set inOffset([list 3 fdc-]) 0 ; set bit([list 3 fdc-]) 0x40 ; set pin([list 3 fdc-]) [list J1 12]

set inOffset([list 0 0meca]) 1 ; set bit([list 0 0meca]) 0x02 ; set pin([list 0 0meca]) [list J1 60]
set inOffset([list 0 0elec]) 1 ; set bit([list 0 0elec]) 0x01 ; set pin([list 0 0elec]) [list J1 58]
set inOffset([list 1 0meca]) 1 ; set bit([list 1 0meca]) 0x08 ; set pin([list 1 0meca]) [list J1 45]
set inOffset([list 1 0elec]) 1 ; set bit([list 1 0elec]) 0x04 ; set pin([list 1 0elec]) [list J1 43]
set inOffset([list 2 0meca]) 1 ; set bit([list 2 0meca]) 0x20 ; set pin([list 2 0meca]) [list J1 30]
set inOffset([list 2 0elec]) 1 ; set bit([list 2 0elec]) 0x10 ; set pin([list 2 0elec]) [list J1 28]
set inOffset([list 3 0meca]) 1 ; set bit([list 3 0meca]) 0x80 ; set pin([list 3 0meca]) [list J1 15]
set inOffset([list 3 0elec]) 1 ; set bit([list 3 0elec]) 0x40 ; set pin([list 3 0elec]) [list J1 13]

# inversion inOffset 2 et 3 par rapport à la doc.

set inOffset(E1) 3 ; set bit(E1) 0x01 ; set pin(E1) [list J2  4]
set inOffset(E2) 3 ; set bit(E2) 0x02 ; set pin(E2) [list J2  5]
set inOffset(E3) 3 ; set bit(E3) 0x04 ; set pin(E3) [list J2  6]
set inOffset(E4) 3 ; set bit(E4) 0x08 ; set pin(E4) [list J2  7]
set inOffset(E5) 3 ; set bit(E5) 0x10 ; set pin(E5) [list J2  1]
set inOffset(E6) 3 ; set bit(E6) 0x20 ; set pin(E6) [list J2  2]
set inOffset(E7) 3 ; set bit(E7) 0x40 ; set pin(E7) [list J2  3]
set inOffset(E8) 3 ; set bit(E8) 0x02 ; set pin(E8) [list J2 17]

set inOffset(E9)  2 ; set bit(E9)  0x01 ; set pin(E9)  [list J2 26] ;# NC
set inOffset(E10) 2 ; set bit(E10) 0x02 ; set pin(E10) [list J2 18]
set inOffset(E11) 2 ; set bit(E11) 0x04 ; set pin(E11) [list J2 21]
set inOffset(E12) 2 ; set bit(E12) 0x08 ; set pin(E12) [list J2 16]
set inOffset(E13) 2 ; set bit(E13) 0x10 ; set pin(E13) [list J2 12]
set inOffset(E14) 2 ; set bit(E14) 0x20 ; set pin(E14) [list J2 11]
set inOffset(E15) 2 ; set bit(E15) 0x40 ; set pin(E15) [list J2 14]
set inOffset(URG) 2 ; set bit(URG) 0x80 ; set pin(URG) [list J2  8]

# Sorties capables de tirer 50 mA sous 30V

# note : xm : mode minipas/pas entier
# note : xe : ecart? pour moteur cc

set outOffset([list 0 imp+]) 0 ; set bit([list 0 imp+]) 0x02 ; set pin([list 0 imp+]) [list J1 54]
set outOffset([list 0 imp-]) 0 ; set bit([list 0 imp-]) 0x01 ; set pin([list 0 imp-]) [list J1 56]
set outOffset([list 1 imp+]) 0 ; set bit([list 1 imp-]) 0x08 ; set pin([list 1 imp-]) [list J1 39]
set outOffset([list 1 imp-]) 0 ; set bit([list 1 imp+]) 0x04 ; set pin([list 1 imp+]) [list J1 41]
set outOffset([list 2 imp+]) 0 ; set bit([list 2 imp+]) 0x20 ; set pin([list 2 imp+]) [list J1 24]
set outOffset([list 2 imp-]) 0 ; set bit([list 2 imp-]) 0x10 ; set pin([list 2 imp-]) [list J1 26]
set outOffset([list 3 imp+]) 0 ; set bit([list 3 imp+]) 0x80 ; set pin([list 3 imp+]) [list J1  9]
set outOffset([list 3 imp-]) 0 ; set bit([list 3 imp-]) 0x40 ; set pin([list 3 imp-]) [list J1 11]

set outOffset([list 0 mode]) 1 ; set bit([list 0 mode]) 0x02 ; set pin([list 0 mode]) [list J1 49]
set outOffset([list 0 iecc]) 1 ; set bit([list 0 iecc]) 0x01 ; set pin([list 0 iecc]) [list J1 51]
set outOffset([list 1 mode]) 1 ; set bit([list 1 mode]) 0x08 ; set pin([list 1 mode]) [list J1 34]
set outOffset([list 1 iecc]) 1 ; set bit([list 1 iecc]) 0x04 ; set pin([list 1 iecc]) [list J1 36]
set outOffset([list 2 mode]) 1 ; set bit([list 2 mode]) 0x20 ; set pin([list 2 mode]) [list J1 19]
set outOffset([list 2 iecc]) 1 ; set bit([list 2 iecc]) 0x10 ; set pin([list 2 iecc]) [list J1 21]
set outOffset([list 3 mode]) 1 ; set bit([list 3 mode]) 0x80 ; set pin([list 3 mode]) [list J1  4]
set outOffset([list 3 iecc]) 1 ; set bit([list 3 iecc]) 0x40 ; set pin([list 3 iecc]) [list J1  6]

set outOffset(S9)  2 ; set bit(S9)  0x01 ; set pin(S9)  [list J2 10]
set outOffset(S10) 2 ; set bit(S10) 0x02 ; set pin(S10) [list J2 22]
set outOffset(S11) 2 ; set bit(S11) 0x04 ; set pin(S11) [list J2 24]
set outOffset(S12) 2 ; set bit(S12) 0x08 ; set pin(S12) [list J2 25]
set outOffset(S13) 2 ; set bit(S13) 0x10 ; set pin(S13) [list J2 20]
set outOffset(S14) 2 ; set bit(S14) 0x20 ; set pin(S14) [list J2 19]
set outOffset(S15) 2 ; set bit(S15) 0x40 ; set pin(S15) [list J2 13]
set outOffset(S16) 2 ; set bit(S16) 0x80 ; set pin(S16) [list J2  9]

# nappe J1 -- 4 SubD15

set J1SD15(1)  [list 3  1] ; set pin([list 3 memo])    [list J1  1]
set J1SD15(2)  [list 3  9] ; set pin([list 3 codeurA]) [list J1  2]
set J1SD15(3)  [list 3  2] ; set pin([list 3 raz])     [list J1  3]
set J1SD15(4)  [list 3 10]
set J1SD15(5)  [list 3  3] ; set pin([list 3 codeurB]) [list J1  5]
set J1SD15(6)  [list 3 11]
set J1SD15(7)  [list 3  4] ; set pin([list 3 NC])      [list J1  7]
set J1SD15(8)  [list 3 12] ; set pin([list 3 0V_Puissance])     [list J1  8]
set J1SD15(9)  [list 3  5]
set J1SD15(10) [list 3 13]
set J1SD15(11) [list 3  6]
set J1SD15(12) [list 3 14]
set J1SD15(13) [list 3  7]
set J1SD15(14) [list 3 15] ; set pin([list 3 0V_Logique])     [list J1 14]
set J1SD15(15) [list 3  8]

set J1SD15(16) [list 2  1] ; set pin([list 2 memo])    [list J1 16]
set J1SD15(17) [list 2  9] ; set pin([list 2 codeurA]) [list J1 17]
set J1SD15(18) [list 2  2] ; set pin([list 2 raz])     [list J1 18]
set J1SD15(19) [list 2 10]
set J1SD15(20) [list 2  3] ; set pin([list 2 codeurB]) [list J1 20] 
set J1SD15(21) [list 2 11] 
set J1SD15(22) [list 2  4] ; set pin([list 2 NC])      [list J1 22]
set J1SD15(23) [list 2 12] ; set pin([list 2 0V_Puissance])     [list J1 23]
set J1SD15(24) [list 2  5]
set J1SD15(25) [list 2 13]
set J1SD15(26) [list 2  6]
set J1SD15(27) [list 2 14]
set J1SD15(28) [list 2  7]
set J1SD15(29) [list 2 15] ; set pin([list 2 0V_Logique])     [list J1 29] 
set J1SD15(30) [list 2  8]
 
set J1SD15(31) [list 1  1] ; set pin([list 1 memo])    [list J1 31]
set J1SD15(32) [list 1  9] ; set pin([list 1 codeurA]) [list J1 32]
set J1SD15(33) [list 1  2] ; set pin([list 1 raz])     [list J1 33]
set J1SD15(34) [list 1 10]
set J1SD15(35) [list 1  3] ; set pin([list 1 codeurB]) [list J1 35] 
set J1SD15(36) [list 1 11]
set J1SD15(37) [list 1  4] ; set pin([list 1 NC])      [list J1 37]
set J1SD15(38) [list 1 12] ; set pin([list 1 0V_Puissance])     [list J1 38]
set J1SD15(39) [list 1  5]
set J1SD15(40) [list 1 13]
set J1SD15(41) [list 1  6]
set J1SD15(42) [list 1 14]
set J1SD15(43) [list 1  7]
set J1SD15(44) [list 1 15] ; set pin([list 1 0V_Logique])     [list J1 44]
set J1SD15(45) [list 1  8]

set J1SD15(46) [list 0  1] ; set pin([list 0 memo])    [list J1 46] 
set J1SD15(47) [list 0  9] ; set pin([list 0 codeurA]) [list J1 47]
set J1SD15(48) [list 0  2] ; set pin([list 0 raz])     [list J1 48]
set J1SD15(49) [list 0 10]
set J1SD15(50) [list 0  3] ; set pin([list 0 codeurB]) [list J1 50] 
set J1SD15(51) [list 0 11]
set J1SD15(52) [list 0  4] ; set pin([list 0 NC])      [list J1 52] 
set J1SD15(53) [list 0 12] ; set pin([list 0 0V_Puissance])     [list J1 53]
set J1SD15(54) [list 0  5]
set J1SD15(55) [list 0 13]
set J1SD15(56) [list 0  6]
set J1SD15(57) [list 0 14]
set J1SD15(58) [list 0  7]
set J1SD15(59) [list 0 15] ; set pin([list 0 0V_Logique])     [list J1 59] 
set J1SD15(60) [list 0  8]

# nappe J2 -- 1 SubD25

set J2SD25(1)   1
set J2SD25(2)  14
set J2SD25(3)   2 
set J2SD25(4)  15
set J2SD25(5)   3
set J2SD25(6)  16
set J2SD25(7)   4
set J2SD25(8)  17
set J2SD25(9)   5
set J2SD25(10) 18
set J2SD25(11)  6
set J2SD25(12) 19
set J2SD25(13)  7
set J2SD25(14) 20
set J2SD25(15)  8 ; set pin(0V)    [list J2 15]
set J2SD25(16) 21
set J2SD25(17)  9
set J2SD25(18) 22
set J2SD25(19) 10
set J2SD25(20) 23
set J2SD25(21) 11
set J2SD25(22) 24
set J2SD25(23) 12 ; set pin(5V)    [list J2 23]
set J2SD25(24) 25
set J2SD25(25) 13

catch [listunset J1]
catch [listunset J2]
foreach x [array names pin] {
    set connecteur [lindex $pin($x) 0]
    set pinNum     [lindex $pin($x) 1]
    if {$connecteur == "J1"} {
        if {[info exists J1($pinNum)]} {
            error "ERREUR !!! : J1($pinNum) : $J1($pinNum) et $x"
        }
        set J1($pinNum) $x
    } elseif {$connecteur == "J2"} {
        if {[info exists J2($pinNum)]} {
            error "ERREUR !!! : J2($pinNum) : $J2($pinNum) et $x"
        }
        set J2($pinNum) $x
    } else {
        error "ERREUR !!! : connecteur \"$connecteur\" inconnu"
    }
}
unset x

set J1pins [lsort -integer [array names J1]]
set J2pins [lsort -integer [array names J2]]

catch [listunset SD15]
catch [listunset SD25]

foreach x [array names J1SD15] {
    set connecteur [lindex $J1SD15($x) 0]
    set pinNum     [lindex $J1SD15($x) 1]
    set connPin [list $connecteur $pinNum]
    
    if {[info exists SD15($connPin)]} {
        error "ERREUR !!! : SD15($connPin) : $SD15($connPin) et $x"
    }
    set SD15($connPin) $x
}
foreach x [array names J2SD25] {
    set pinNum $J2SD25($x)
    if {[info exists SD25($pinNum)]} {
        error "ERREUR !!! : SD25($pinNum) : $SD25($pinNum) et $x"
    }
    set SD25($pinNum) $x
}
unset x

proc compareListOfTwoInteger {l1 l2} {
    set i1 [lindex $l1 0]
    set i2 [lindex $l2 0]
    if {$i1 < $i2} {
        return -1
    } elseif {$i1 > $i2} {
        return 1
    }
    set i1 [lindex $l1 1]
    set i2 [lindex $l2 1]
    if {$i1 < $i2} {
        return -1
    } elseif {$i1 > $i2} {
        return 1
    }
    return 0
}


set D15pins [lsort -command compareListOfTwoInteger [array names SD15]]
set D25pins [lsort -integer [array names SD25]]

proc role {nom} {
    global inOffset outOffset bit
    if {[info exists inOffset($nom)]} {
        set role "in  $bit($nom) 0x__$inOffset($nom)"
    } elseif {[info exists outOffset($nom)]} {
        set role "out $bit($nom) 0x__$outOffset($nom)"
    } else {
        set role "              "
    }
}

puts [list]
foreach p $D15pins {
    set nom $J1($SD15($p))
    puts "D15 [lindex $p 0] [format %2d [lindex $p 1]] -> [role $nom] = $nom"
}
puts [list]
foreach p $D25pins {
    set nom $J2($SD25($p))
    puts "D25 [format %2d $p] -> [role $nom] = $nom"
}
unset p
