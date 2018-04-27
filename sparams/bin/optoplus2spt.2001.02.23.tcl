#!/bin/sh
# the next line restarts using tclsh \
exec tclsh "$0" "$@"

# 3 mai 2000 (FP)
# optoplus2spt: transformation des fichiers Hyper Opto+ en supertables
# modifié de "cnet2spt"

# 20 juillet 2000 (FP)
# La syntaxe des fichiers optoplus est modifiée

# 23 février 2001 (FP)
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
    
    set entete [list]
    set lcolnames {}
    set ldata [list]
    foreach l $lignes {
        switch [string index $l 0] {
            "!" {lappend entete $l}
            "#" {
                if {$lcolnames != {}} {
                    return -code error "deux lignes commençant par \"#\""
                }
                set lcolnames $l
            }
            default {lappend ldata $l}
        }
    }


    set B1 "\[ \t\]"
    set BN "\[ \t\]*"
    set BS "\[ \t\]+"
 
    set il -1
       
    interprete "^!PLAQUE:${B1}(.*)"        [lindex $entete [incr il]] params(PLAQUE) 
    interprete "^!VARIETE:${B1}(.*)"       [lindex $entete [incr il]] params(VARIETE) 
    interprete "^!SITE:(.*)\$"       [lindex $entete [incr il]] params(SITE)
    interprete "^!DATE:${B1}(.*)${B1}HEURE:${B1}(.*)\$" [lindex $entete [incr il]] params(DATE) params(HEURE)
          
    interprete "^!POLAR:${B1}(.*)"         [lindex $entete [incr il]] params(POLAR)     
    interprete "^!fichier:${B1}(.*)"       [lindex $entete [incr il]] params(fichier)     
    interprete "^!MES:${B1}(.*)"           [lindex $entete [incr il]] params(MES1)     
    interprete "^!(.*)"               [lindex $entete [incr il]] params(MES2)     
    
    interprete "^!\\\[S\\\] brut\$" [lindex $entete [incr il]]

    interprete "^!FREQ S11 S12 ..\$" [lindex $entete [incr il]]

    interprete "^#${BN}Hz${BS}S${BS}RI${BS}R${BS}50\$" $lcolnames
    
    set nfreqLines [llength $ldata]
    
    set d [split $params(DATE) /]
    set params(DATE) [clock format [clock scan [lindex $d 1]/[lindex $d 0]/[lindex $d 2]] -format %Y/%m/%d]
    
    parray params

    set ident [list $params(DATE) $params(HEURE) $params(PLAQUE) $params(VARIETE)]
puts $ident
    interprete {^Vbe=[ \t]+(-?[0-9.]+)[ \t]+V Ib=[ \t]+(-?[0-9.]+)[ \t]+(mA|uA)$} $params(MES1) Vbe Ib Ibunit
    interprete {^Vce=[ \t]+(-?[0-9.]+)[ \t]+V Ic=[ \t]+(-?[0-9.]+)[ \t]+(mA|uA)$} $params(MES2) Vce Ic Icunit

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

