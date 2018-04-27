#!/bin/sh
# \
exec tclsh "$0" ${1+"$@"}

set CHANGES(fitres) {
    
}

package require fidev
# package require fctlm 0.3
package require superTable 1.5

set usage {

    POUR TLM simples

    1) mesures de resistances dans "mesures_fctlm_xxx"
    2) création du répertoire "fit_fctlm_resistances"
    3) création du fichier "fit_fctlm_resistances/paramFit.spt"
    4) lancement de "/usr/local/bin/fctlmfitres mesures_fctlm_xxx"
       cela crée le fichier "fit_fctlm_resistances/mesures_fctlm_xxx.spt"
}

# repertoire dans lequel on construit la nouvelle table

set repResul fit_resistances

# repertoire dans lequel on lit les tables

if {$argc != 1} {
    puts stderr "syntaxe : $argv0 <repertoire relatif>"
    exit 1
}

set ici [pwd]
cd $argv
set dir [file split [pwd]]
set rrdm [lindex $dir end]
set rrdm2 [join [lrange $dir [expr {[llength $dir] - 2}] end] /]
cd $ici

# lecture des paramètres de fit

set nameOfFileParam [file join $repResul paramFit.spt]
set nameOfTable *
if {[catch {superTable::fileToTable params $nameOfFileParam\
	nameOfTable Répertoire} iii]} {
    puts stderr "La lecture de la table  \"$nameOfFileParam\" a échoué :\n$iii"
    exit 1
}

if {[lsearch -exact [lindex $iii 0] $rrdm] < 0} {
    puts stderr "La table  \"$nameOfFileParam\" ne contient pas de ligne correspondant au Répertoire \"$rrdm\""
    exit 1
}

set iMaxForFit  $params([list $rrdm iMaxForFit])
set NLMax       $params([list $rrdm NLMax])

set fichResulName [file join $repResul ${rrdm}.spt]
set dirOfFichResulName [file dirname $fichResulName]
if {![file isdirectory $dirOfFichResulName]} {
    puts "création du répertoire $dirOfFichResulName"
    file mkdir $dirOfFichResulName
}

# calcul du fit et création de la table

proc ::fctlm::fitTable1 {tableName nameOfSptFile listImax} {
    upvar $tableName table
    
    set fichier [file tail $nameOfSptFile]
    set repert [file dirname $nameOfSptFile]
    set repert [file tail $repert]

    set nameOfTable "mes*"

    set n [::fctlm::readV+IFromSpt $nameOfSptFile nameOfTable tensions courants]
    puts -nonewline ", $n pts"
    
    foreach imax $listImax {
        set indiceDeLigne [list $repert  $fichier $imax]

        foreach {v i} [sublistsWithImax $tensions $courants $imax] {}
        set n [llength $v]    
        if {[catch {extractR $n $v $i i0} R]} {
	    puts stderr $R
	    # set R $R
	    set i0 NaN
	} else {
	    set R [format %.4f $R]
	    set i0 [format %.4g $i0]
	}

        foreach c "fichier repert imax n R i0" {
            set table([list $indiceDeLigne $c]) [set $c]
        }
    }    
}

proc ::fctlm::triCol11 {arrayName l1 l2} {
    upvar $arrayName array
    set i1 [list $l1 repert]
    set i2 [list $l2 repert]
    set c [string compare $array($i1) $array($i2)]
    if {$c != 0} {
        return $c
    }
    set i1 [list $l1 fichier]
    set i2 [list $l2 fichier]
    set c [string compare $array($i1) $array($i2)]
    if {$c != 0} {
        return $c
    }
    set i1 [list $l1 imax]
    set i2 [list $l2 imax]
    set c [expr {$array($i1) - $array($i2)}]
    if {$c < 0} {
        return -1
    } elseif {$c > 0} {
        return 1
    }
    return 0
}

proc fctlm::fitAll1 {fichResulName dir repert imaxForFit NLMax} {

    set blocs [list]

    set fichiers [glob [file join $dir *.spt]]
    set fichiers [lsort $fichiers]
    set nafiter [expr {[llength $fichiers]}]
    set n 0
    set depart [clock seconds]
    foreach nameOfSptFile $fichiers {
	lappend blocs $nameOfSptFile
            incr n
            puts -nonewline "[format %3d $nafiter] $nameOfSptFile"
	    fctlm::fitTable1 table1 $nameOfSptFile $imaxForFit
            incr nafiter -1
            set maintenant [clock seconds]
            set reste [expr {round(($maintenant-$depart)*double($nafiter)/double($n))}]
            puts ", reste $reste s"
    }

    set lignes1 [superTable::createLinesFromArray table1 "Fit Brut de $repert"\
		     -sortLines {::fctlm::triCol11}\
		     -orderOfCols {repert fichiers TYPE R n imax i0}]
 
    set lignes $lignes1

    puts "écriture du fichier"
    superTable::writeToFile $fichResulName $lignes

    return
}

fctlm::fitAll1 $fichResulName $rrdm $rrdm2 $iMaxForFit $NLMax

puts "Le fichier \"$fichResulName\" est écrit"
