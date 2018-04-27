#!/usr/local/bin/wish

package require fidev
package require asdex
package require tbs2
package require superTable
package require superWidgetsListbox

proc ::asdex::listePretriTbs2 {repertoire level1ArrName geomArrName} {
    upvar $level1ArrName Arr
    upvar $geomArrName geomArr

    set fitas [::superTable::allTablesInDirectory $repertoire]
puts stderr "fitas = $fitas"

    foreach fita $fitas {
	foreach {f tables} $fita {}
	foreach t $tables {
		set regexp {^ ([^ ]*) .*diode[^ ]* .*$}
		if {![regexp $regexp $t tout echantillon dispo]} {
		    puts stderr "Cannot regexp \"$t\""
		    break
		}
		set bloc [string range $dispo 0 2]
		set geom [string range $dispo 3 end]
		set x [list $f $t]
		lappend geomArr($geom) [list $Ic $f $t]
	}
    }
#    return $fita
}

proc ::asdex::listeIbIcTbs2 {repertoire level1ArrName geomArrName} {
    upvar $level1ArrName Arr
    upvar $geomArrName geomArr

    set fitas [::superTable::allTablesInDirectory $repertoire]
puts stderr "fitas = $fitas"

    foreach fita $fitas {
	foreach {f tables} $fita {}
	foreach t $tables {
	    if {[string range $t 0 6] == "diodeBE"} {
		set regexpibic {{^IbIc.* \(Vc = ([^\)]*)\) ([^ ]*) .* bipolaire (.*)$} $t tout Vc echantillon dispo]}
		set regexpbe {^diodeBE Dir.* \(Ic=([^\)]*)\) ([^ ]*) .* bipolaire (.*)$}
		if {![regexp $regexpbe $t tout Ic echantillon dispo]} {
		    puts stderr "Cannot regexp \"$t\""
		    break
		}
		set bloc [string range $dispo 0 2]
		set geom [string range $dispo 3 end]
		set x [list $f $t]
		lappend Arr($Ic) [list $geom $f $t]
		lappend geomArr($geom) [list $Ic $f $t]
	    }
	}
    }
#    return $fita
}

proc ::asdex::traiteIbIc {win globArrayName level1 geom fichierTable} {
    upvar #0 $globArrayName P

    foreach {fichier table} $fichierTable {}
    puts [list $win $level1 $geom $fichier $table]
    set indexes [::superTable::fileToTable a $fichier table tb]
    set tbs [lindex $indexes 0]
    set VeList [list]
    set VbList [list]
    set VcList [list]
    set IeList [list]
    set IbList [list]
    set IcList [list]
    set ItotList [list]
    set tbList [list]
    set tb0 [lindex $tbs 0]
    set jour [::superTable::getCell a $tb0 jour]
    set heure [::superTable::getCell a $tb0 heure]

    puts stderr "PATCH A VIRER : abs()"

    foreach tb $tbs {
	if {[::superTable::getCell a $tb Se] != {}} continue
	if {[::superTable::getCell a $tb Sb] != {}} continue
	if {[::superTable::getCell a $tb Sc] != {}} continue
	foreach c {Ve Vb Vc Ie Ib Ic Itot tb} {
	    lappend ${c}List [expr abs([::superTable::getCell a $tb $c])]
	}
    }
    set P(Ve) $VeList
    set P(Vb) $VbList
    set P(Vc) $VcList
    set P(Ie) $IeList
    set P(Ib) $IbList
    set P(Ic) $IcList
    set P(Itot) $ItotList
    set P(tb) $tbList

    if {[llength $VeList] < 5} {
	error "Le fortran va tout planter"
    }

    eval $P(callback) $globArrayName
}

proc ::asdex::traitePretri {win globArrayName level1 geom fichierTable} {
    upvar #0 $globArrayName P

    foreach {fichier table} $fichierTable {}
    puts [list $win $level1 $geom $fichier $table]
    set indexes [::superTable::fileToTable a $fichier table t]
    set ts [lindex $indexes 0]
    set VList [list]
    set IList [list]
    set tList [list]
    set t0 [lindex $ts 0]

    puts stderr "PATCH A VIRER : abs()"

    foreach tb $tbs {
	if {[::superTable::getCell a $t statut] != {}} continue
	foreach c {V I t} {
	    lappend ${c}List [expr abs([::superTable::getCell a $tb $c])]
	}
    }
    set P(V) $VList
    set P(I) $IList
    set P(t) $tList

    if {[llength $VeList] < 5} {
	error "Le fortran va tout planter"
    }

    eval $P(callback) $globArrayName
}

proc ::asdex::creeListBox {repertoire globArrayName} {

    if {[info exists level1Array]} {unset level1Array}
    if {[info exists geomArr]} {unset geomArr}
    
    ::asdex::listeIbIcTbs2 $repertoire level1Array geomArr
#    ::asdex::listePretriTbs2 $repertoire level1Array geomArr
    
    set level1List [lsort -real [array names level1Array]]
    set geomList [lsort -command  ::tbs2::triGeom [array names geomArr]]

    destroy .choixMesure

    set cm [toplevel .choixMesure]
    set l [::widgets::listbox $cm]
    $l configure -width 132
    ::widgets::listboxSetType3 $l [list ::asdex::traiteIbIc %W $globArrayName]
#    ::widgets::listboxSetType3 $l [list ::asdex::traitePretri %W $globArrayName]
    
    foreach level1 $level1List {
	$l insert end $level1 level1
	$l insert end \n
	set gt [lsort -command ::tbs2::triGeomAsFirstElem $level1Array($level1)]
	set lastGeom {}
	foreach elem $gt {
	    foreach {geom fich table} $elem {}
	    if {$geom != $lastGeom} {
		$l insert end "    "
		$l insert end $geom level2
		$l insert end \n
	    }
	    $l insert end "      "
	    $l insert end [list $fich $table] level3
	    $l insert end \n
	}
    }
}


# ::asdex::creeListBox /home/asdex/data/SF4/SF4.3.1/ibic