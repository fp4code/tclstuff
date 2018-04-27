#!/bin/sh
# The next line is executed by /bin/sh, but not tcl \
exec tclsh "$0" ${1+"$@"}

package require fidev
package require fctlmPart1 0.6
package require superTable 1.5

set usage {
    1) mesures de resistances dans "mesures_fctlm_xxx"
    2) cr�ation du r�pertoire "fit_fctlm_resistances"
    3) cr�ation du fichier "fit_fctlm_resistances/paramFit.spt"
    4) lancement de "/usr/local/bin/fctlmfitres mesures_fctlm_xxx"
       cela cr�e le fichier "fit_fctlm_resistances/mesures_fctlm_xxx.spt"
}

# repertoire dans lequel on construit la nouvelle table

set repResul fit_fctlm_resistances

# repertoire dans lequel on lit les tables

if {$argc != 1} {
    puts stderr "syntaxe : $argv0 <repertoire relatif>"
    exit 1
}

# construction
# de rrdm  = mesures_fctlm_xxx
# et rrdm2 = MELBA_pG_H6624.base/mesures_fctlm_xxx

set ici [pwd]
cd $argv
set dir [file split [pwd]]
set rrdm [lindex $dir end]
set rrdm2 [eval file join [lrange $dir [expr {[llength $dir] - 2}] end]]
cd $ici

# lecture des param�tres de fit NLMax, iMaxForFit et NumDisList

set nameOfFileParam [file join $repResul paramFit.spt]
set nameOfTable *
if {[catch {superTable::fileToTable params $nameOfFileParam\
	nameOfTable R�pertoire} iii]} {
    puts stderr "La lecture de la table  \"$nameOfFileParam\" a �chou� :\n$iii"
    exit 1
}

if {[lsearch -exact [lindex $iii 0] $rrdm] < 0} {
    puts stderr "La table  \"$nameOfFileParam\" ne contient pas de ligne correspondant au R�pertoire \"$rrdm\""
    exit 1
}

set iMaxForFit  $params([list $rrdm iMaxForFit])
set NLMax       $params([list $rrdm NLMax])
set NumDisList  $params([list $rrdm NumDisList])

# d�finition du fichier de r�sultats et cr�ation du chemin

set fichResulName [file join $repResul ${rrdm}.spt]
set dirOfFichResulName [file dirname $fichResulName]
if {![file isdirectory $dirOfFichResulName]} {
    puts "cr�ation du r�pertoire $dirOfFichResulName"
    file mkdir $dirOfFichResulName
}

# calcul du fit et cr�ation de la table

fctlm::fitAll $fichResulName $rrdm $rrdm2 $iMaxForFit $NLMax $NumDisList
