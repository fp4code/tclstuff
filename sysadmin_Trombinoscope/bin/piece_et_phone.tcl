#!/bin/sh
# \
exec tclsh "$0" ${1+"$@@"}
#
# 2008-04-18 (FP)

package require Tcl 8.3
package require csv 0.7
package require struct::matrix  2.0.1

proc read_csv_in_matrix {mName file} {
    catch {$mName destroy}
    set f [open $file r]
    ::struct::matrix $mName
    ::csv::read2matrix $f $mName , auto
    close $f
}

proc read_passwd_in_matrix {mName file} {
    catch {$mName destroy}
    set f [open $file r]
    set lines [split [read -nonewline $f] \n]
    ::struct::matrix $mName
    $mName add columns 7
    foreach line $lines {
	$mName add row [split $line :]
    }    
    close $f
}

proc get_room {mName row} {
    switch $mName {
	m1 {$mName get cell 0 $row}
	m2 {$mName get cell 5 $row}
	default {return -code error "not for \"$mName\""}
    }
}

proc get_name {mName row} {
    switch $mName {
	m1 {$mName get cell 1 $row}
	m2 {$mName get cell 1 $row}
	mp {$mName get cell 4 $row}
	default {return -code error "not for \"$mName\""}
    }
}

proc get_names {mName} {
    switch $mName {
	m1 {$mName get column 1}
	m2 {$mName get column 1}
	mp {$mName get column 4}
	default {return -code error "not for \"$mName\""}
    }
}

proc get_login {mName row} {
    switch $mName {
	mp {$mName get cell 0 $row}
	default {return -code error "not for \"$mName\""}
    }
}

proc get_phone {mName row} {
    switch $mName {
	m1 {$mName get cell 2 $row}
	m2 {$mName get cell 4 $row}
	default {return -code error "not for \"$mName\""}
    }
}

proc get_begin {mName row} {
    switch $mName {
	m2 {$mName get cell 2 $row}
	default {return -code error "not for \"$mName\""}
    }
}

proc get_end {mName row} {
    switch $mName {
	m2 {$mName get cell 3 $row}
	default {return -code error "not for \"$mName\""}
    }
}

proc fill_passwd_normalized_names {arrayName mName names} {
    upvar $arrayName array
    set i 0
    foreach name $names {
	set name [join [string tolower $name]]	
	if {$name != {}} {
	    set array($name) [list $mName $i]
	}
	incr i
    } 
}

proc fill_admin_normalized_names {arrayName mName names} {
    upvar $arrayName array
    set i 0
    foreach name $names {
	set name [string tolower $name]
	set name [regsub -all {[éèêë]} $name e]
	set name [regsub -all {[î]} $name i]
	set name [regsub -all {[à]} $name a]
# puts $name
	set prenom [lindex $name end]
	set nom [lrange $name 0 end-1]
	set name [concat $prenom $nom] 
	if {$name != {}} {
	    set array($name) [list $mName $i]
	}
	incr i
    } 
}

proc fill_names {array1Name array2Name} {
    upvar $array1Name array1
    upvar $array2Name array2
    foreach name [array names array2] {
	foreach word $name {
	    if {$word != {}} {
		set v $array2($name)
		lappend v $name
		lappend array1($word) $v 
	    }
	}
    }
}


proc no_problemo0 {NPName ANNName PNNName} {
    upvar $NPName NP
    upvar $PNNName PNN
    upvar $ANNName ANN
    foreach name [array names PNN] {
	if {[info exists ANN($name)]} {
	    set NP($name) [list $ANN($name) $PNN($name)]
	    unset ANN($name)
	    unset PNN($name)
	}
    }
}

proc values_list {arrayName} {
    upvar $arrayName array
    set ret [list]
    foreach {k v} [array get array] {
	lappend ret $v
    }
    return $ret
}



read_csv_in_matrix m1 /home/fab/Z/Listing\ Alcatel.csv
read_csv_in_matrix m2 /home/fab/Z/Listing\ Alcatel2.csv
read_passwd_in_matrix mp /home/fab/Z/passwd

catch {unset PNN}
fill_passwd_normalized_names PNN mp [get_names mp]
catch {unset ANN}
fill_admin_normalized_names ANN m1 [get_names m1]
fill_admin_normalized_names ANN m2 [get_names m2]

catch {unset NP0}
no_problemo0 NP0 ANN PNN
catch {unset ANN(cdd)}
catch {unset ANN(stagiaires)}
catch {unset ANN(doctorants)}

catch {unset WA}
fill_names WA ANN

catch {unset WP}
fill_names WP PNN

catch {unset WW}
foreach w [array names WA] {
    if {[info exists WP($w)]} {
	foreach v $WP($w) {
	    lappend WW($w) $v
	}
    }
}

catch {unset TMP_GOOD}
foreach name [array names ANN] {
    foreach w $name {
	if {[info exists WW($w)] && [llength $WW($w)] == 1} {
	    set NP1($name) [list $ANN($name) [lrange [lindex $WW($w) 0] 0 1]]
	    set TMP_GOOD($name) {}
	    set nn [lindex $WW($w) 2]
	    catch {unset PNN($nn)}
	    unset WW($w)
	    continue
	}
    }
}
foreach name [array names TMP_GOOD] {
    unset ANN($name)
}
unset TMP_GOOD

catch {unset PROBLEMS}
foreach name [array names ANN] {
    set seen 0
    catch {unset TMP}
    foreach w $name {
	if {[info exists WW($w)]} {
	    foreach nmp $WW($w) {
		set TMP([list $ANN($name) [lrange $nmp 0 1]]) {}
		set seen 1
	    }
	}
    }
    if {$seen} {
	set PROBLEMS([lindex $nmp 2]) [array names TMP]
	unset ANN($name)
    }
}


puts "# généré automatiquement par [info script]"

foreach {k v} [array get ANN] {
    puts "# Inconnu dans LDAP : [[lindex $v 0] get row [lindex $v 1]]"
}

foreach {kkk vvv} [array get PROBLEMS] {
    foreach vv $vvv {
	set v [lindex $vv 0]
	set vp [lindex $vv 1]
	set login [get_login [lindex $vp 0] [lindex $vp 1]]
	set name [get_name [lindex $vp 0] [lindex $vp 1]]
	set admin [[lindex $v 0] get row [lindex $v 1]]
	puts "# AMBIGUITÉ : $login | $name | $admin"
    }
}

catch {unset X0}
foreach {k vv} [array get NP0] {
    foreach {v vp} $vv {
	set m [lindex $v 0]
	set mp [lindex $vp 0]
	set r [lindex $v 1]
	set rp [lindex $vp 1]
	set login [get_login $mp $rp]
	set X0([get_login $mp $rp]) $v
    }
}

catch {unset X1}
foreach {k vv} [array get NP1] {
    foreach {v vp} $vv {
	set m [lindex $v 0]
	set mp [lindex $vp 0]
	set r [lindex $v 1]
	set rp [lindex $vp 1]
	set login [get_login $mp $rp]
	set X1([get_login $mp $rp]) $v
    }
}

catch {unset X2}
foreach {k vvv} [array get PROBLEMS] {
    foreach vv $vvv {
	foreach {v vp} $vv {
	    set m [lindex $v 0]
	    set mp [lindex $vp 0]
	    set r [lindex $v 1]
	    set rp [lindex $vp 1]
	    set login [get_login $mp $rp]
	    set X2([get_login $mp $rp]) $v
	}
    }
}


proc normalize_phone {phone} {
    set np [regsub -all " " $phone ""]
    if {[string length $np] == 5 || [string range $np end-8 end-4] == "16963"} {
	return "3 [string range $np end-3 end]"
    }

}

proc put_result {type arrayName} {
    upvar $arrayName array
    puts "\n# $type :"
    foreach login [lsort [array names array]] {
	set v $array($login)
	set m [lindex $v 0]
	set r [lindex $v 1]
	set phone [normalize_phone [get_phone $m $r]]
	set room [get_room $m $r]
	set name [get_name $m $r]
	if {$m == "m1"} {
	    set other permanent
	} else {
	    set other "[get_begin $m $r] -> [get_end $m $r]"
	}
	puts [list $login $name $phone $room $other]
    }
}

put_result OK X0
put_result "Un peu douteux" X1
put_result "Très douteux" X2
