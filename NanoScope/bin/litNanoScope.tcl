# 6 décembre 2002

set filename [lindex $argv 0]
# set filename /home/nathalie/W/Z/11201539.001
set file [open $filename r]
fconfigure $file -encoding binary -translation binary

set data [read -nonewline $file] ; puts lu

set headerLast [string first \x1a $data]
set header [string range $data 0 [expr {$headerLast - 1}]]
set header [lrange [split $header \n] 0 end-1]

catch {unset ETATS}
catch {unset PARAMETER}
set ili 0
set ETAT INCONNU
foreach li $header {
    incr ili
    if {[string index $li 0] != "\\"} {
        puts stderr "ligne $ili pas du type \"\\\" : \"$li\""
        continue
    }
    if {[string index $li end] != "\r"} {
        puts stderr "ligne $ili pas terminé par \"\\r\""
        continue
    }
    set li [string range $li 1 end-1]
    if {[string index $li 0] == "*"} {
        set etat [string range $li 1 end]
        if {[info exists ETATS($etat)]} {
            set iv 1
            set etat_ "$etat \#$iv"
            while {[info exists ETATS($etat_)]} {
                incr iv
            }
            set etat $etat_
        }
        set ETATS($etat) {}
        set ETAT $etat
        continue
    }
    set split [string first : $li]
    if {$split == -1} {
        puts stderr "ligne $ili manque \":\: : \"\\$li\""        
    }
    if {[string index $li 0] == "@" && $split == 2} {
        set split2 [string first : $li [expr {$split + 2}]]
        if {$split2 != -1} {
            set split $split2
        }
    }
    set key [string range $li 0 [expr {$split - 1}]]
    set value [string range $li [expr {$split + 1}] end]

    set bigkey [list $ETAT $key]
    if {[info exists PARAMETER($bigkey)]} {
        set iv 1
        set bigkey [list $ETAT "$key \#$iv"]
        while {[info exists PARAMETER($bigkey)]} {
            incr iv
            set bigkey [list $ETAT "$key \#$iv"]
        }
    }
    set PARAMETER($bigkey) $value
}


set imName "Ciao image list"
set imageData [string range $data $PARAMETER([list $imName {Data offset}]) end]
puts $PARAMETER([list $imName {Data length}])
#if {[string length $imageData] != $PARAMETER([list $imName {Data length}])} {
#    return -code error "différnce de taille : \[string length \$imageData\] = [string length $imageData], \$PARAMETER([list $imName {Data length}]) = $PARAMETER([list $imName {Data length}])"
#}


set dataLength $PARAMETER([list $imName {Data length}])
set bytesPerPixel $PARAMETER([list $imName Bytes/pixel])
set sampsPerLine $PARAMETER([list $imName Samps/line])
set sampsPerCol [expr {$dataLength / $bytesPerPixel / $sampsPerLine}]
if {$bytesPerPixel != 2} {
    return -code error "bytesPerPixel = $bytesPerPixel != 2"
}
if {$dataLength != $bytesPerPixel * $sampsPerLine * $sampsPerCol} {
    return -code error "dataLength calculated incorrect"
}

puts "convert -depth 16 -size ${sampsPerLine}x${sampsPerCol}+$PARAMETER([list $imName {Data offset}]) gray:$filename toto.tif"
exec convert -depth 16 -size ${sampsPerLine}x${sampsPerCol}+$PARAMETER([list $imName {Data offset}]) gray:$filename toto.tif

set pgm [open toto.pgm w]
puts $pgm P2
puts $pgm "${sampsPerLine} ${sampsPerCol}"

binary scan $imageData s[expr {$sampsPerLine * $sampsPerCol}] zdata

set min [lindex $zdata 0]
set max $min
foreach z $zdata {
    if {$z < $min} {
        set min $z
    } elseif {$z > $max} {
        set max $z
    }
}

puts $pgm [expr {$max - $min + 1}]



set couleurs [list]
set i 0
for {set x 0} {$x < $sampsPerLine} {incr x} {
    set r [list]
    for {set y 0} {$y < $sampsPerCol} {incr y} {
        set z [lindex $zdata $i]
        incr i 1
        set v [expr {round(($z-$min)*$f)}]
        lappend r [format "#%02x%02x%02x" $v $v $v]
    }
    lappend couleurs $r
}

image create photo im1 -width 256 -height 256
im1 put $couleurs

label .l1 -image im1
pack .l1
