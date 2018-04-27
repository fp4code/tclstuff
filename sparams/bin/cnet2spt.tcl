#!/usr/local/bin/tclsh

package require fidev
package require complexes
package require sparams
package require superTable

proc errSyntax {} {
    global argv0
    puts stderr "syntaxe : $argv0 fichiers repertoire"
    exit 1
}

proc cleanLine {line} {
    if {[string index $line 0] == "\0"} {
        return [string range $line 1 end]
    } else {
        return $line
    }
}

proc interprete {regexp string args} {
puts $string
    if {![uplevel [list regexp $regexp $string dummy] $args]} {
	error [list cannot regexp $regexp $string]
    }
}

if {$argc == 2} {
    set fichiers [glob [lindex $argv 0]]
    set repertoire [lindex $argv 1]
} else {
    errSyntax
}

proc readSFile {fichname} {

    set f [open $fichname r]
    set lignes [split [read -nonewline $f] \n] ; close $f
    
    set entete [lrange $lignes 0 4]
    set lnfreq [lindex $lignes 5]
    set lcolnames [lindex $lignes 6]
    set ldata [lrange $lignes 7 end]
    
    set B1 "\[ \t\]"
    set BN "\[ \t\]*"
    set BS "\[ \t\]+"
        
    interprete "^!'${BN}PLAQUE${BN}:${B1}(.*)${B1}DISPO${BN}:${B1}(.*)'\$" [lindex $entete 0] params(PLAQUE) params(DISPO)
    
    interprete "^!'${BN}TYPE${BN}:${B1}(.*)${B1}POSIT${BN}:${B1}(.*)'\$" [cleanLine [lindex $entete 1]] params(TYPE) params(POSIT)
    
    interprete "^!'${BN}DATE${BN}:${B1}(.*)${B1}HEURE${BN}:${B1}(.*)'\$" [cleanLine [lindex $entete 2]] params(DATE) params(HEURE)
          
    interprete "^!'${BN}POLAR${BN}:${B1}(.*)${BN}MES:${B1}(.*)\$" [cleanLine [lindex $entete 3]] params(POLAR) params(MES)
    
    interprete "^!'${BN}MONTAGE${BN}:${BN}(.*)'\$" [cleanLine [lindex $entete 4]] params(MONTAGE)
    
    interprete "^!${BN}(\[1-9\]\[0-9\]*)\$" [cleanLine $lnfreq] nfreq
    
    interprete "^#${BN}Hz${BS}S${BS}MA${BS}R${BS}50\$" [cleanLine $lcolnames]
    
    set nfreqLines [llength $ldata]
    
    set params(DATE) [clock format [clock scan $params(DATE)] -format %Y/%m/%d]
    
    parray params

    set ident [list $params(DATE) $params(HEURE) $params(PLAQUE) $params(POSIT) $params(MONTAGE)]
puts $ident
    interprete {^([0-9.]+)V/([0-9.]+)mA/([0-9.]+)V/([0-9.]+)mA$} $params(MES) Vbe Ib Vce Ic
puts $Vbe

    set tablePolar([list {} Vbe]) $Vbe
    set tablePolar([list {} Vce]) $Vce
    set tablePolar([list {} Ic]) ${Ic}e-3
    set tablePolar([list {} Ib]) ${Ib}e-3
       
    if {$nfreq != $nfreqLines} {
	set last [expr {$nfreqLines - 1}]
	if {[cleanLine [lindex $ldata $last]] == {}} {
	    incr last -1
	    incr nfreqLines -1
	    set ldata [lrange $ldata 0 $last]
	} else {
	    error "il devrait y avoir $nfreq fréquences, j'ai $nfreqLines lignes"
	}
    }
    
puts [llength $ldata]       
    set freqs [list]
    foreach line $ldata {
	set l [cleanLine $line]
	if {[llength $l] != 9} {
	    error "il devrait y avoir 9 colonnes sur la ligne \"$l\""
	}
	set freq [lindex $l 0]
	set table([list $freq freq]) $freq
	set table([list $freq s11_m]) [lindex $l 1]
	set table([list $freq s11_deg]) [lindex $l 2]
	set table([list $freq s21_m]) [lindex $l 3]
	set table([list $freq s21_deg]) [lindex $l 4]
	set table([list $freq s12_m]) [lindex $l 5]
	set table([list $freq s12_deg]) [lindex $l 6]
	set table([list $freq s22_m]) [lindex $l 7]
	set table([list $freq s22_deg]) [lindex $l 8]
    }
    set cols [list freq]
	foreach ii "11 21 12 22" {
	    foreach ri "m deg" {
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
    }

    superTable::writeToFile $repertoire/[file tail ${fichname}].spt $lignes

}

