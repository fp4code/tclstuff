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

puts stderr "images = [array names ETATS "Ciao image list*"]"

set image 0
foreach imName [array names ETATS "Ciao image list*"] {
    set start $PARAMETER([list $imName {Data offset}])
    set dataLength [string trim $PARAMETER([list $imName {Data length}])]

    set end [expr {$start + $dataLength - 1}]

    set imageData [string range $data $start $end]
    
    set bytesPerPixel [string trim $PARAMETER([list $imName Bytes/pixel])]
    set sampsPerLine [string trim $PARAMETER([list $imName Samps/line])]
    set dataOffset [string trim $PARAMETER([list $imName {Data offset}])]

    puts [list $dataLength $bytesPerPixel $sampsPerLine]
    
    set sampsPerCol [expr {$dataLength / $bytesPerPixel / $sampsPerLine}]
    if {$bytesPerPixel != 2} {
	return -code error "bytesPerPixel = $bytesPerPixel != 2"
    }
    if {$dataLength != $bytesPerPixel * $sampsPerLine * $sampsPerCol} {
	return -code error "dataLength calculated incorrect"
    }
    if {$image == 0} {
	set fff /home/fab/Z/[file tail $filename].pgm
    } else {
	set fff /home/fab/Z/[file tail $filename]\#$image.pgm
    }


    set pgmle [open $fff w]
    puts $pgmle P2
    puts $pgmle "${sampsPerLine} ${sampsPerCol}"
    
    binary scan $imageData s[expr {$sampsPerLine * $sampsPerCol}] zdatale
    
    set minle [lindex $zdatale 0]
    set maxle $minle
    foreach z $zdatale {
	if {$z < $minle} {
	    set minle $z
	} elseif {$z > $maxle} {
	    set maxle $z
	}
    }
    
    puts $pgmle [expr {$maxle - $minle + 1}]
    
    set i 0
    for {set x 0} {$x < $sampsPerLine} {incr x} {
	for {set y 0} {$y < $sampsPerCol} {incr y} {
	    set zle [lindex $zdatale $i]
	    incr i 1
	    puts $pgmle [expr {($zle-$minle)}]
	}
    }
    
    close $pgmle
    
    incr image
}


set rien {
set commande [list  convert -depth 16 -size ${sampsPerLine}x${sampsPerCol}+${dataOffset} gray:$filename $fff]
puts $commande
eval exec $commande
}

