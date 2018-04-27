set fichier "/home/asdex/caract/Profil_Optique/Aixtron/Aix2651/040123/04 01 23 AIXTRON_01.SDFA"
set f [open $fichier r]
set lignes [split [read -nonewline $f] \n] ; close $f

set rien {
    set xr  [1e-4:4e-4]
    set yr  [1e-4:4e-4]
    set zr  [0:1e-6]
    splot "~/Z/out.dat"

}

set fout [open /home/fab/Z/out.dat w]

set version [lindex $lignes 0]

set i 1
set para1 [list]
foreach l [lrange $lignes 1 end] {
    incr i
    if {[regexp {^([^ 	]+)[ 	]*=[ 	]*(.*)} $l tout a b]} {
	if {[info exists DATA($a)]} {
	    puts stderr "Attention, doublon pour \"$a\" : \"$DATA($a)\" et \"$b\""
	}
	set DATA($a) $b
    } else {
	break
    }
}
if {$l != "*"} {
    return -code error "Ligne $i, \"*\" attendu, \"$l\" vu"
}

for {set ili 0} {$ili < $DATA(NumProfiles)} {incr ili} {
    set y [expr {$ili*$DATA(Yscale)}]

    set data [lindex $lignes $i]
    incr i
    
    if {[llength $data] != $DATA(NumPoints)} {
	return -code error "Lignes $i, attendu $DATA(NumPoints) nombres, vu [llength $data] ; confusion entre NumPoints et NumProfiles ?"
    }

    for {set ico 0} {$ico < $DATA(NumPoints)} {incr ico} {
	set z [expr {[lindex $data $ico]*$DATA(Zscale)}]
	set x [expr {$ico*$DATA(Xscale)}]
	puts $fout "$x\t$y\t$z"
	
    }
    puts $fout {}

}
set l [lindex $lignes $i]
incr i
if {$l != "*"} {
    return -code error "Ligne $i, \"*\" attendu, \"$l\" vu"
}

set toutvu 1
foreach l [lrange $lignes $i end] {
    incr i
    if {[regexp {^([^ 	]+)[ 	]*=[ 	]*(.*)} $l tout a b]} {
	if {[info exists DATA($a)]} {
	    puts stderr "Attention, doublon pour \"$a\" : \"$DATA($a)\" et \"$b\""
	}
	set DATA($a) $b
    } else {
	break
	set toutvu 0
    }
}

if {!$toutvu} {
    puts stderr "reste des lignes :"
    foreach  l [lrange $lignes $i end] {
	puts stderr $l
    }
}


parray DATA