package provide fctlm_geom 0.2

package require fidev
package require superTable
package require listUtils

namespace eval fctlm_geom {}

set HELP(::fctlm_geom::readGeom) {
    $allLines : contenu d'un fichier, typiquement "geom.txt"
    $marques  : liste de numéros lignes délimitant les tables
    $nameOfTableA : nom de variable contenant le nom de la table de géométrie fctlm, du genre "geom.spt 81214.6 xxA"
    $nameOfTableB : nom de variable contenant le nom de la table de géométrie fctlm, du genre "geom.spt 81214.6 xxB"

    Corrige les valeurs en calibrant sur la période
}

proc ::fctlm_geom::readGeom {allLines marques nameOfTableAName nameOfTableBName} {

    upvar $nameOfTableAName nameOfTableA
    upvar $nameOfTableBName nameOfTableB

    set rangeA [::superTable::linesOfTable $allLines $marques nameOfTableA]
    set rangeB [::superTable::linesOfTable $allLines $marques nameOfTableB]

    set tableA [lrange $allLines [lindex $rangeA 0] [lindex $rangeA 1]]
    set tableB [lrange $allLines [lindex $rangeB 0] [lindex $rangeB 1]]

    set retA [::superTable::readTable $allLines $rangeA gDataA TYPE]
    set retB [::superTable::readTable $allLines $rangeB gDataB TYPE]

    foreach {lignesA c1A c2A} $retA {}
    foreach {lignesB c1B c2B} $retB {}

    unset allLines marques

    set dispoA [lindex $nameOfTableA end]
    set dispoB [lindex $nameOfTableB end]

    # la nouvelle table rassemble les deux tables A et B
    # son nom est de la forme "geom.spt 81214.6"
    set nameOfTable [lrange $nameOfTableA 0 [expr {[llength $nameOfTableA] - 2}]]

    set etalon_250   [::superTable::getCell gDataA etalon_192 250]
    set etalon_192   [::superTable::getCell gDataA etalon_192 192]
    set etalon_lVide [::superTable::getCell gDataA etalon_192 lVide]
    set etalon_facteur [expr {250./$etalon_250}]

    # liste des lignes de Floating Contacts
    set withFC [list]

    foreach AB {A B} {
        upvar 0 dispo$AB dispo
        upvar 0 lignes$AB lineIndex
        upvar 0 gData$AB gData

        if {$AB == "B"} {
	    puts "du B on ne traite que \"CC\""
	    set lineIndex "CC"
	}

	# pour chaque ligne de la table A puis B
	foreach l $lineIndex {
	    
	    # on construit un nouvel index de ligne rassemblant les deux tables A et B
	    set lNew [list $dispo $l]

	    # on introduit les valeurs des colonnes formant l'index
	    ::superTable::setCell gDNew $lNew TYPE $l
	    ::superTable::setCell gDNew $lNew DISPO $dispo
	    
	    # on lit la colonne donnant le zoom de mesure standard
	    set zoom [::superTable::getCell gData $l zoom]
	    
	    if {$l == "CC"} {
		
		# court-circuit

		setValAndZoom gData gDNew zoomLocal $l $lNew $zoom {larMesa larMetal longueur}

		
	    } elseif {$l == "etalon_192"} {
		
		# etalonnage des grandes dimensions
		
		setValAndZoom gData gDNew zoomLocal $l $lNew $zoom {lVide 250}
		
		set cellNew [list [list $dispo $l] 250]
		# lappend facteurs($zoomLocal($cellNew)) [expr {250./$gDNew($cellNew)}]
		
	    } elseif {$l == "Vide"} {
		# la colonne larMesa est manquante
		
		# dispo vide
		
		setValAndZoom gData gDNew zoomLocal $l $lNew $zoom lVide
		::superTable::setCell gDNew $lNew larMesaTh [::superTable::getCell gData $l larMesaTh]
		
	    } elseif {[superTable::getCell gData $l nFant] == 1} {
		# la colonne larMesa est manquante
		
		# Un seul contact flottant de grande dimension => pas d'espace
		
		lappend withFC [list $dispo $l]
		
		set lTh [superTable::getCell gData $l lTh]
		set eTh [superTable::getCell gData $l eTh]
		::superTable::setCell gDNew $lNew nFant 1
		
		setValAndZoom gData gDNew zoomLocal $l $lNew $zoom {eGauche lCentre eDroit}
		::superTable::setCell gDNew $lNew larMesaTh [::superTable::getCell gData $l larMesaTh]
		
	    } else {
		
		# plusieurs contacts flottants
		
		lappend withFC $lNew
		
		set lTh [::superTable::getCell gData $l lTh]
		set eTh [::superTable::getCell gData $l eTh]
		::superTable::setCell gDNew $lNew nFant [superTable::getCell gData $l nFant]
		::superTable::setCell gDNew $lNew pas   [expr {$lTh + $eTh}]
		
		setValAndZoom gData gDNew zoomLocal $l $lNew $zoom {eGauche lGauche eCentre lCentre eDroit lDroite}
		::superTable::setCell gDNew $lNew larMesaTh [::superTable::getCell gData $l larMesaTh]
		
		set pas [expr [superTable::getCell gDNew $lNew lCentre] + [superTable::getCell gDNew $lNew eCentre]]
		set facteur [expr {($lTh+$eTh)/$pas}]
		if {[::superTable::getCell zoomLocal $lNew eCentre] == [::superTable::getCell zoomLocal $lNew lCentre]} {
		    lappend facteurs([::superTable::getCell zoomLocal $lNew eCentre]) $facteur
		}
	    }
	}
    }
    unset l lNew lineIndex gData

    puts "zooms = [array names facteurs]"
    foreach f [array names facteurs] {
	set facteursMoyens($f) [::listUtils::calcMoy $facteurs($f)]
	puts [list zoom=$f moyenne=$facteursMoyens($f) $facteurs($f)]
    }

    set listOfFacteursMoyens [list]
    foreach f [array names facteursMoyens] {
	lappend listOfFacteursMoyens $facteursMoyens($f)
    }
    set facteurMoyen [listUtils::calcMoy $listOfFacteursMoyens]
    puts [list facteurMoyen=$facteurMoyen $listOfFacteursMoyens]
    foreach e [lsort -command {fctlm_geom::sortOnVal vides} [array names vides]] {
        puts [list $vides($e) $e]
    }

    # normalisation des valeurs
    foreach cellNew [array names gDNew] {
        if {[info exists zoomLocal($cellNew)]} {
            set z $zoomLocal($cellNew)
            if {[info exists facteursMoyens($z)]} {
                set val [expr {$facteursMoyens($z)*$gDNew($cellNew)}]
		set val [format %.2f $val]
                set gDNew($cellNew) $val
	    } else {
		set val [expr {$facteurMoyen*$gDNew($cellNew)}]
		set val [format %.2f $val]
		set gDNew($cellNew) [list $val i] ;# signifie étalonnage incorrect
	    }
	}
    }

    set lVides_2 [list]
    set withOneFlottant [list]
    foreach lNew $withFC {
        set nFant [superTable::getCell gDNew $lNew nFant]
	set ok 1
        if {$nFant == 1} {

	    # un seul fantôme

	    lappend withOneFlottant $lNew
            foreach v {eGauche eDroit lCentre} {
                set c [superTable::getCell gDNew $lNew $v]
                if {[llength $c] == 1} {
		    set $v $c
		} else {
		    set ok 0
		    set $v [lindex $c 0]
		}
	    }
	    set Vide_1 [expr {$eGauche + $lCentre + $eDroit}]
	} else {

	    # N fantômes, calibration éventuellement possible

            foreach v {eGauche eDroit lCentre eCentre} {
                set c [superTable::getCell gDNew $lNew $v]
                if {[llength $c] == 1} {
		    set $v $c
		} else {
		    set ok 0
		    set $v [lindex $c 0]
		}
	    }
            if {$ok} {
		# calibration complete
		set f [expr {[superTable::getCell gDNew $lNew pas]/($lCentre+$eCentre)}]
		set esp [expr {$f*$eCentre}]
		set len [expr {$f*$lCentre}]
	    } else {
		# On calcule la longueur de fantôme à partir du pas et de l'espace
		set esp $eCentre
		set len [expr {[superTable::getCell gDNew $lNew pas] - $esp}]
	    }
	    superTable::setCell gDNew $lNew e [format %.2f $esp]
	    superTable::setCell gDNew $lNew l [format %.2f $len]
	    # longueur de vide calibrée brute
	    set Vide_1 [expr {$eGauche + $nFant*$lCentre + ($nFant-1)*$eCentre + $eDroit}]
	    # longueur de vide calculée de façon optimale
	    set Vide_2 [expr {$eGauche + $nFant*$len + ($nFant-1)*$esp + $eDroit}]
	    set Vide_2 [format %.2f $Vide_2]
	    lappend lVides_2 $Vide_2
	    superTable::setCell gDNew $lNew lVide_2 $Vide_2
	}
        set Vide_1 [format %.2f $Vide_1]
	if {$ok} {
	    superTable::setCell gDNew $lNew lVide_1 $Vide_1
	} else {
	    superTable::setCell gDNew $lNew lVide_1 [list $Vide_1 i]
	}
    }
    set lVideMoy 0.0
    set i 0
    foreach lv2 $lVides_2 {
        set lVideMoy [expr {$lVideMoy + $lv2}]
	incr i
    }
    set lVideMoy [expr {$lVideMoy/$i}]
    set lVideMoy [format %.2f $lVideMoy]
    foreach lNew $withFC {
        set nFant [superTable::getCell gDNew $lNew nFant]
	superTable::setCell gDNew $lNew lVideMoy $lVideMoy
        if {$nFant == 1} {
            foreach v {eGauche eDroit} {
                set $v [superTable::getCell gDNew $lNew $v]
	    }
	    set len [expr {$lVideMoy - $eGauche - $eDroit}]
	    superTable::setCell gDNew $lNew l $len
	}
    }
    superTable::setCell    gDNew [list $dispoA Vide] lVideMoy $lVideMoy
    
    superTable::deleteCell gDNew [list $dispoA etalon_192] DISPO
    superTable::deleteCell gDNew [list $dispoA etalon_192] TYPE
    superTable::deleteCell gDNew [list $dispoA etalon_192] lVide
    superTable::deleteCell gDNew [list $dispoA etalon_192] 250

    set out [list]
    lappend out "@@représentants géométriques de $nameOfTable"
    lappend out "@global {CC A} {CC B}"
    lappend out "   [set dispoA]    [set dispoA]    [set dispoB]"
    lappend out "# Une liste {xxx.xx i} signifie que l'étalonnage du MEB n'a pas été possible"
    lappend out "# Les paramêtres optimaux sont \"lVideMoy\", \"e\" et \"l\""
    set out [concat $out [superTable::createLinesFromArray gDNew "mesures étalonnées à partir de $nameOfTable" \
	    -sortLines ::fctlm_geom::sortOnNFant\
	    -orderOfCols {TYPE l lGauche lCentre lDroite e eCentre nFant pas eGauche eDroit lVide_1 lVide_2 lVideMoy}]]
    return $out
}

proc ::fctlm_geom::readQuality {dir} {
    
}


set HELP(::fctlm_geom::setValAndZoom) {
    Les cases de la ligne de $oldArrayName indexée par $oldLineIndex
    contiennent une valeur et éventuellement un zoom
    La valeur est recopiée dans le tableau $newArrayName sur la ligne $newLineIndex dans la même colonne
    Le zoom, s'il existe, est recopié dans $zoomArrayName.
    S'il n'existe pas, on recopie $zoomStandard
}

proc ::fctlm_geom::setValAndZoom {oldArrayName newArrayName zoomArrayName oldLineIndex newLineIndex zoomStandard columns} {
    upvar $oldArrayName oldArray
    upvar $newArrayName newArray
    upvar $zoomArrayName zoomArray
    foreach col $columns {
	set oldCellKey [list $oldLineIndex $col]
	set newCellKey [list $newLineIndex $col]
	set cellVal $oldArray($oldCellKey)
	if {[llength $cellVal] == 1} {
	    set  newArray($newCellKey) $cellVal
	    set zoomArray($newCellKey) $zoomStandard
	} else {
	    set  newArray($newCellKey) [lindex $cellVal 0]
	    set zoomArray($newCellKey) [lindex $cellVal 1]
	}
    }
}

proc ::fctlm_geom::sortOnNFant {arrayName a1 a2} {
    upvar $arrayName array
    if {[catch {set array([list $a1 nFant])} n1]} {set n1 -1}
    if {[catch {set array([list $a2 nFant])} n2]} {set n2 -1}
    return [expr $n2 - $n1]
}


proc ::fctlm_geom::sortOnVal {arrayName a1 a2} {
    upvar $arrayName array
    set v [expr {$array($a1) - $array($a2)}]
    if {$v<0} {
	return -1
    } elseif {$v>0} {
	return 1
    } else {
	return 0
    }
}

proc ::fctlm_geom::readGeomAndQuality {dir geomspt} {
    set lignes [superTable::getLines [file join $dir ${geomspt}]]
    set marques [superTable::marqueTables $lignes]
    set names [superTable::nomsDesTables $lignes $marques]
    foreach n $names {
	puts $n
    }

    set nameOfTableA "*geom*.spt [file tail $dir] *A"
    set nameOfTableB "*geom*.spt [file tail $dir] *B"

    set out [list]
    set out [concat $out [::fctlm_geom::readGeom $lignes $marques nameOfTableA nameOfTableB]]
    set out [concat $out [::fctlm_geom::readQuality $dir]]
    return $out
}
