#!/bin/sh
# the next line restarts using tclsh \
exec tclsh "$0" "$@"

# 3 mai 2000 (FP)
# optoplus2spt: transformation des fichiers Hyper Opto+ en supertables
# modifié de "cnet2spt"

# 20 juillet 2000 (FP)
# 23 février 2001 (FP)
# 8 juin 2001     (FP)
# 26 juillet 2001 (JLuc avec FP)
# La syntaxe des fichiers optoplus est modifiée


package require fidev
package require complexes
# package require sparams
package require superTable

proc errSyntax {} {
    global argv0
    puts stderr "syntaxe : $argv0 fichiers(glob un argument) repertoire"
    exit 1
}

proc interprete {regexp string args} {
puts $string
    if {![uplevel [list regexp $regexp $string dummy] $args]} {
	return -code error "\n    cannot regexp\n\"$regexp\"\n    for\n\"$string\""
    }
}

if {$argc == 2} {
    set fichiers [glob [lindex $argv 0]]
    set repertoire [lindex $argv 1]
} else {
    errSyntax
}

proc iunit {mAuA} {
    switch $mAuA {
        mA {return e-3}
        uA {return e-6}
        default {return -code error "Unité de courant inconnue: \"$mAuA\""} 
    }
}


proc readSFile {fichname} {

    set f [open $fichname r]
    set lignes [split [read -nonewline $f] \n] ; close $f
    
    set entete [lrange $lignes 0 12]
    set lcolnames [lindex $lignes 13]
    set ldata [lrange $lignes 14 end]
    
    set B1 "\[ \t\]"
    set BN "\[ \t\]*"
    set BS "\[ \t\]+"
        
    interprete "^!(../../..)${B1}(..:..)\$" [lindex $entete 0] params(DATE) params(HEURE)
    interprete "^!Plaque:${B1}(.*)"        [lindex $entete 1] params(PLAQUE) 
    interprete "^!Dispo:${B1}(.*)"       [lindex $entete 2] params(VARIETE) 
    interprete "^!Site:${B1}\$"            [lindex $entete 3]
    interprete "^!Mesure:${BS}\\\[S\\\] brut Reel Imaginaire\$" [lindex $entete 4]
    interprete "^!Configuration:	Ib & Vce fix.s	(.*)\$"       [lindex $entete 5] params(fichier)     
    interprete "^!${BS}Vbe${BS}(-?\[0-9.\]+)${BN}V${BS}Ibe${BS}(-?\[0-9.\]+)${BN}(mA|uA)${BN}\$" [lindex $entete 6] Vbe Ib Ibunit
    interprete "^!${BS}Vce${BS}(-?\[0-9.\]+)${BN}V${BS}Ice${BS}(-?\[0-9.\]+)${BN}(mA|uA)${BN}\$" [lindex $entete 7] Vce Ic Icunit
    interprete "^Param.tres extraits:\$" [lindex $entete 8]
    interprete "^!\\*\$" [lindex $entete 9]
    interprete "^!\\*\$" [lindex $entete 10]
    interprete "^!\\*\$" [lindex $entete 11]
    interprete "^!FREQ S11 S12 ..\$" [lindex $entete 12]
    interprete "^#${BN}Hz${BS}S${BS}RI${BS}R${BS}50\$" $lcolnames
    
    set nfreqLines [llength $ldata]
    
    set d [split $params(DATE) /]
    set params(DATE) [clock format [clock scan [lindex $d 1]/[lindex $d 0]/[lindex $d 2]] -format %Y/%m/%d]
    
    parray params

    set ident [list $params(DATE) $params(HEURE) $params(PLAQUE) $params(VARIETE)]
puts $ident

puts $Vbe

    set tablePolar([list {} Vbe]) $Vbe
    set tablePolar([list {} Vce]) $Vce
    set tablePolar([list {} Ic]) ${Ic}[iunit $Ibunit]
    set tablePolar([list {} Ib]) ${Ib}[iunit $Icunit]
           
puts [llength $ldata]       
    set freqs [list]
    foreach line $ldata {
	set l $line
	if {[llength $l] != 9} {
	    error "il devrait y avoir 9 colonnes sur la ligne \"$l\""
	}
	set freq [lindex $l 0]
	set table([list $freq freq]) $freq
	set table([list $freq s11_r]) [lindex $l 1]
	set table([list $freq s11_i]) [lindex $l 2]
	set table([list $freq s12_r]) [lindex $l 3]
	set table([list $freq s12_i]) [lindex $l 4]
	set table([list $freq s21_r]) [lindex $l 5]
	set table([list $freq s21_i]) [lindex $l 6]
	set table([list $freq s22_r]) [lindex $l 7]
	set table([list $freq s22_i]) [lindex $l 8]
    }
    set cols [list freq]
	foreach ii "11 12 21 22" {
	    foreach ri "r i" {
		lappend cols s${ii}_${ri}
	    }
    }

    set lignes {}

set tname [concat $ident Polarisation]
puts $tname

    append lignes [superTable::createLinesFromArray tablePolar $tname -orderOfCols {Vce Vbe Ic Ib}]



append lignes \n
set tname [concat $ident Sparams]
puts $tname
    append lignes [superTable::createLinesFromArray table $tname -sortLines sortFreq -orderOfCols $cols]

return $lignes

}

proc sortFreq {arrayName l1 l2} {
    upvar $arrayName array
    set case1 [list $l1 freq]
    set case2 [list $l2 freq]
    set retour [expr {$array($case1) - $array($case2)}]
#    puts [list $l1 $l2 $array($case1) $array($case2) $retour]
    if {$retour > 0.0} {
	return 1
    } elseif {$retour < 0.0} {
	return -1
    } else {
	return 0
    }
}

foreach fichname $fichiers {

    set err [catch {readSFile $fichname} lignes]
    
    if {$err} {
	puts stderr "ERREUR : \"$fichname\" -> $lignes"
        break
    }

    set newfichname [file tail $fichname]
    if {[string match *.dat $newfichname]} {
        set newfichname [string range $newfichname 0 end-4].spt
    } else {
        set newfichname ${newfichname}.spt
    }
    superTable::writeToFile [file join $repertoire $newfichname] $lignes

}

