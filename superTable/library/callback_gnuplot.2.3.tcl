package provide tkstcb_gnuplot 2.3

package require superWidgetsScroll 1.0

set rien {rename return return_orig

proc return {args} {
    set locals [uplevel info locals]
    if {[llength $locals] != 0} { 
	puts stderr [list Warning, [info level -1] : restent $locals] 
    }
    return_orig $args

return -code code? ?-errorinfo  info?  ? - errorcode  code?
     ?string?
}
}

namespace eval ::tkSuperTable::callbacks {
    variable gnuplotConfigsDir [pwd]
}

# Crée une chaine représentant les lignes de données Gnuplot
# à partir de colonnes données d'une tkTable.
# La chaine doit être séparée et terminée par des "\n" mais elle ne doit pas contenir le "e" final
# La tkTable est à la sauce tkSuperTable et les colonnes sont données par leur nom.


proc tkSuperTable::callbacks::gnuplotDirectWithCleanCols {cleancolnames tkTable colnames} {

# puts stderr [list gnuplotDirectWithCleanCols $cleancolnames $tkTable $colnames]

    # Récupération du tableau associé à la tkTable

    upvar #0 [$tkTable cget -variable] tkTableArray

    # remplissage du tableau "ic" de correspondance entre les colonnes gnuplot
    # 1, 2, ... représentées par ($1), ($2), ...
    # Et les colonnes du tableau tkTableArray


    set iccvar 0
    foreach ccolname $cleancolnames {
	incr iccvar
	set icc($iccvar) [tkSuperTable::getColIndex $tkTable $ccolname]
    }
    set nccols $iccvar

    set icvar 0
    foreach colname $colnames {
	incr icvar
	set ic($icvar) [tkSuperTable::getColIndex $tkTable $colname]
    }
    set ncols $icvar

    # Construction des lignes de données gnuplot à partir du tableau "tkTableArray"
     
    set datas ""
    foreach ili [tkSuperTable::toutesLignes $tkTable] {
	set noOk 0
	for {set iccvar 1} {$iccvar <= $nccols} {incr iccvar} {
	    if {[info exists tkTableArray($ili,$icc($iccvar))] &&\
		    $tkTableArray($ili,$icc($iccvar)) != {}} {
		# puts stderr [list $ili,$iccvar -> $tkTableArray($ili,$icc($iccvar))]
		set noOk 1
		break
	    }
	}
	if {$noOk} continue
	# puts stderr OK
	for {set icvar 1} {$icvar <= $ncols} {incr icvar} {
	    if {[info exists tkTableArray($ili,$ic($icvar))]} {
		set val $tkTableArray($ili,$ic($icvar))
	    } else {
		set val "nc"
	    }
	    if {$icvar != 1} {
		append datas \t
	    }
	    append datas $val
	}
	append datas \n
    }
    # puts "datas =\n $datas"
    return $datas
}

proc tkSuperTable::callbacks::gnuplotDirectNoParano {sens tkTable colnames} {
    if {$sens == "M"} {
        set M 1
        set D 0
    } elseif {$sens == "D"} {
        set M 0
        set D 1
    } elseif {$sens == "MD"} {
        set M 1
        set D 1
    } else {
        return -code error "sens should be \"M\", \"D\" or \"MD\""
    }

    set cleancolnames {Se Sb Sc}

    # Récupération du tableau associé à la tkTable

    upvar #0 [$tkTable cget -variable] tkTableArray

    # tableau "icc" des colonnes qui doivent être vides 

    set iccvar 0
    foreach ccolname $cleancolnames {
	incr iccvar
	set icc($iccvar) [tkSuperTable::getColIndex $tkTable $ccolname]
    }
    set nccols $iccvar

    set cIe [tkSuperTable::getColIndex $tkTable Ie]

    # remplissage du tableau "ic" de correspondance entre les colonnes gnuplot
    # 1, 2, ... représentées pas ($1), ($2), ...
    # Et les colonnes du tableau tkTableArray

    set icvar 0
    foreach colname $colnames {
	incr icvar
	set ic($icvar) [tkSuperTable::getColIndex $tkTable $colname]
    }
    set ncols $icvar

    # Construction des lignes de données gnuplot à partir du tableau "tkTableArray"

    # nettoyage des lignes

    set goodLines [list]

    foreach ili [tkSuperTable::toutesLignes $tkTable] {
	set Ok 1
	for {set iccvar 1} {$iccvar <= $nccols} {incr iccvar} {
	    if {[info exists tkTableArray($ili,$icc($iccvar))] &&\
		    $tkTableArray($ili,$icc($iccvar)) != {}} {
		set Ok 0
		break
	    }
	}
	if {$Ok} {
            lappend goodLines $ili
        }
    }

    # montée/descente

    set nils [list]
    set max 1e99
    catch {unset ilmax}
    set ii 0

    foreach il $goodLines {
        if {$tkTableArray($il,$cIe) < $max} {
            set max $tkTableArray($il,$cIe)
            set ilmax $ii
        } elseif {$tkTableArray($il,$cIe) == $max} {
            lappend ilmax $ii
        }
        lappend nils $il
        incr ii
    }

    if {![info exists ilmax]} {
        return -code error "Warning: pas d'ilmax"
    }
    if {[llength $ilmax] != 2} {
        puts stderr "Warning: extrema n'est pas en 2 points : $ilmax"
    } 

    set ilsM [lrange $nils 0 [lindex $ilmax 0]]
    set ilsD [lrange $nils [lindex $ilmax end] end]

    set nils [list]

    # Nettoyage des mesures paranos
    
    if {$M} {
        set lastIe 1e99
        foreach il $ilsM {
            if {$tkTableArray($il,$cIe) < $lastIe} {
                lappend nils $il
                set lastIe $tkTableArray($il,$cIe)
            }
        }
    }

    if {$D} {
        set lastIe -1e99
        foreach il $ilsD {
            if {$tkTableArray($il,$cIe) > $lastIe} {
                lappend nils $il
                set lastIe $tkTableArray($il,$cIe)
            }
        }
    }
    
    set datas ""
    
    foreach ili $nils {
        for {set icvar 1} {$icvar <= $ncols} {incr icvar} {
            if {[info exists tkTableArray($ili,$ic($icvar))]} {
                set val $tkTableArray($ili,$ic($icvar))
            } else {
                set val "nc"
            }
            if {$icvar != 1} {
                append datas \t
            }
            append datas $val
        }
        append datas \n
    }
    # puts "datas =\n $datas"
    return $datas
}

proc tkSuperTable::callbacks::gnuplotDirect {tkTable colnames} {

    # Récupération du tableau associé à la tkTable

    upvar #0 [$tkTable cget -variable] tkTableArray

    # remplissage du tableau "ic" de correspondance entre les colonnes gnuplot
    # 1, 2, ... représentées pas ($1), ($2), ...
    # Et les colonnes du tableau tkTableArray

    set icvar 0
    foreach colname $colnames {
	incr icvar
	set ic($icvar) [tkSuperTable::getColIndex $tkTable $colname]
    }
    set ncols $icvar

    # Construction des lignes de données gnuplot à partir du tableau "tkTableArray"
     
    set datas ""
    foreach ili [tkSuperTable::toutesLignes $tkTable] {
	for {set icvar 1} {$icvar <= $ncols} {incr icvar} {
	    if {[info exists tkTableArray($ili,$ic($icvar))]} {
		set val $tkTableArray($ili,$ic($icvar))
	    } else {
		set val "nc"
	    }
	    if {$icvar != 1} {
		append datas \t
	    }
	    append datas $val
	}
	append datas \n
    }
    return $datas
}


     ###########################################################
     # La procédure appelée après chaque chargement de tkTable #
     ###########################################################


proc tkSuperTable::callbacks::gnuplot {tkTable} {

    # création ou récupération du toplevel d'interaction avec gnuplot

    set gW [createGnuplot]

    # tableau global des données associées au toplevel d'interaction

    upvar #0 privArray$gW privArray
    
    set privArray(plotOrFit) plot
    set privArray(tkTable) $tkTable
    tkSuperTable::callbacks::gnuplotDoIt $gW
}

proc tkSuperTable::callbacks::gnuplotDoIt {gW} {

    # tableau global des données associées au toplevel d'interaction

    upvar #0 privArray$gW privArray

    set privArray(plotEnCours) 0
    set tkTable $privArray(tkTable)

    if {![info exists privArray(plotOrFit)]} {
	return
    }

    # récupération du tableau ligne,colonne associé à la tkTable

    set arrayName [$tkTable cget -variable]

    # récupération du nom de la procédure d'initialisation et de récupération des valeurs de case
    
    # noms des colonnes gnuplot $1 $2 ... $12

    set colnames [list]
    for {set icvar 1} {$icvar <= 12} {incr icvar} {
	set var $privArray(var:$icvar)
	set var [string trim $var " \t"]
	set var [subst -nobackslashes -nocommands -novariables $var]
	if {$var != {}} {
	    lappend colnames $var
	}
    }

    # calcul du tableau (TAB separated) gnuplot
    # La dernière ligne doit comporter un \n

    set computeGpDatas $privArray(var:0)
    if {[regexp "^\[ \t]*$" $computeGpDatas]} {
	set computeGpDatas [list tkSuperTable::callbacks::gnuplotDirect]
    }
# puts [concat $computeGpDatas [list $tkTable $colnames]]
    set datas [eval $computeGpDatas [list $tkTable $colnames]]
    append datas "e"

    # construction de la commande gnuplot

    set privArray(plotEnCours) 1
    if {$privArray(plotOrFit) == "plot"} {
	set commande ""
	set nCourbes 0
	if {[info exists privArray(heldCommands)]} {
	    foreach c $privArray(heldCommands) {
		incr nCourbes
		if {$nCourbes == 1} {
		    append commande "plot"
		} else {
		    append commande ","
		}
		append commande $c
	    }
	}
	# on réinitialise nCourbes
	set nNewCourbes 0
	for {set i 1} {$i <= 16} {incr i} {
	    if {$privArray(plotIt:$i)} {
		incr nCourbes
		incr nNewCourbes
		if {$nCourbes == 1} {
		    append commande "plot"
		} else {
		    append commande ","
		}
		append commande " \"-\" $privArray(i1:$i)"
		if {$privArray(i2:$i) != ""} {
		    append commande " title \"$privArray(i2:$i)\""
		}
		if {$privArray(i3:$i) != ""} {
		    append commande " $privArray(i3:$i)"
		}
	    }
	}
    } elseif {$privArray(plotOrFit) == "hold"} {
	set nCourbes 0
	for {set i 1} {$i <= 16} {incr i} {
	    set commande ""
	    if {$privArray(plotIt:$i)} {
		incr nCourbes
		append commande " \"-\" $privArray(i1:$i)"
		if {$privArray(i2:$i) != ""} {
		    append commande " title \"$privArray(i2:$i)\""
		}
		if {$privArray(i3:$i) != ""} {
		    append commande " $privArray(i3:$i)"
		}
		lappend privArray(heldCommands) $commande
	    }
	}
    } elseif {$privArray(plotOrFit) == "fit"} {
        set commande "fit [$gW.fit.i1 get] \"-\" [$gW.fit.i2 get] via [$gW.fit.i3 get]"
	set nNewCourbes 1
    }

    if {$privArray(plotOrFit) == "hold"} {
	for {set i $nCourbes} {$nCourbes > 0} {incr nCourbes -1} {
	    append privArray(heldDatas) $datas
	    append privArray(heldDatas) \n
	}

    } else {

	if {$privArray(debug)} {
	    puts "gnuplot> $commande"
	}
	puts $privArray(channel) $commande
	
	# envoi des données à gnuplot
	
	if {[info exists privArray(heldDatas)] && $privArray(heldDatas) != ""} {
	    if {$privArray(debug)} {
		puts -nonewline $privArray(heldDatas)
	    }
	    puts  -nonewline $privArray(channel) $privArray(heldDatas)
	}
	if {$privArray(debug)} {
	    puts "$nNewCourbes fois:"
	    puts $datas
	}
	for {set i $nNewCourbes} {$i > 0} {incr i -1} {
	    puts $privArray(channel) $datas
	}
	if {$privArray(debug)} {
	    puts "fin de la boucle"
	}
    }
    set $privArray(plotEnCours) 0
}

proc tkSuperTable::callbacks::gnuplotSeePlotParams {gW} {
    upvar #0 privArray$gW privArray

    set current $privArray(paramsOfCurve#)
    $gW.plot.i1 configure -textvariable privArray$gW\(i1:$current)
    $gW.plot.i2 configure -textvariable privArray$gW\(i2:$current)
    $gW.plot.i3 configure -textvariable privArray$gW\(i3:$current)
}

proc tkSuperTable::callbacks::gnuplotLoadConfig {gW} {
    upvar #0 privArray$gW privArray
    variable gnuplotConfigsDir 

    set txt {}

    set fichier [tk_getOpenFile \
	    -defaultextension .sptgcp \
	    -filetypes {{{gnuplot params} *.sptgcp}} \
	    -initialdir $gnuplotConfigsDir\
	    -title {Paramètres pour gnuplot} ]
    if {$fichier != {}} {
	set gnuplotConfigsDir [file dirname $fichier]
    }
    set f [open $fichier r]

    for {set i 1} {$i <= 16} {incr i} {
	set permis(plotIt:$i) {}
	set permis(i1:$i) {}
	set permis(i2:$i) {}
	set permis(i3:$i) {}
    }
    set permis(paramsOfCurve#) {}
    for {set i 0} {$i <= 12} {incr i} {
	set permis(var:$i) {}
    }
    set permis(fit:i1) {}
    set permis(fit:i2) {}
    set permis(fit:i3) {}

    set lignes [split [read -nonewline $f] \n]
    close $f

    set ili 0
    set end 0
    foreach l $lignes {
	incr ili
	if {$end} {
	    append txt $l\n
            continue
	}
	if {[regexp "^\[ \t]*#" $l]} {
	    # commentaire
	    continue
	}
	if {[llength $l] != 2} {
	    if {$l != "TEXT"} {
		puts stderr [list ligne $ili incorrecte $l]
	    } else {
		$gW.ftxt.txt delete 1.0 end
		set end 1
	    }
	    continue
	}
	set key [lindex $l 0]
	set value [lindex $l 1]
	if {[info exists permis($key)]} {
	    set privArray($key) $value
	}
    }
    if {[regexp -indices {^([ \n\t]*)} $txt ii]} {
        set txt [string range $txt [expr {[lindex $ii 1] + 1}] end]
    }
    if {[regexp -indices {([ \n\t]*)$} $txt ii]} {
        set txt [string range $txt 0 [expr {[lindex $ii 0] - 1}]]
    }
    $gW.ftxt.txt insert end $txt
}

proc tkSuperTable::callbacks::gnuplotSaveConfig {gW} {
    upvar #0 privArray$gW privArray
    variable gnuplotConfigsDir 

    set fichier [tk_getSaveFile \
	    -defaultextension .sptgcp \
	    -filetypes {{{gnuplot params} *.sptgcp}} \
	    -initialdir $gnuplotConfigsDir\
	    -title {Paramètres pour gnuplot} ]
    if {$fichier != {}} {
	set gnuplotConfigsDir [file dirname $fichier]
    }

    set f [open $fichier w]
    puts $f "# paramètres pour tkSuperTable::callbacks::gnuplot"
    for {set i 1} {$i <= 16} {incr i} {
	puts $f [list plotIt:$i $privArray(plotIt:$i)]
	puts $f [list i1:$i $privArray(i1:$i)]
	puts $f [list i2:$i $privArray(i2:$i)]
	puts $f [list i3:$i $privArray(i3:$i)]
    }
    puts $f [list paramsOfCurve# $privArray(paramsOfCurve#)]
    for {set i 0} {$i <= 12} {incr i} {
	puts $f [list var:$i $privArray(var:$i)]
    }
    puts $f [list fit:i1 $privArray(fit:i1)]
    puts $f [list fit:i2 $privArray(fit:i2)]
    puts $f [list fit:i3 $privArray(fit:i3)]

    puts $f TEXT
    puts $f [$gW.ftxt.txt get 1.0 end]
    close $f
}

proc tkSuperTable::callbacks::externExec {gW programEntry colsEntry} {
    upvar #0 privArray$gW privArray

    set channel [open "|[$programEntry get] 2>@ stderr"  w+]
    fconfigure $channel -buffering line

    set colnames [$colsEntry get]
    set computeGpDatas $privArray(var:0)
    if {[regexp "^\[ \t]*$" $computeGpDatas]} {
	set computeGpDatas [list tkSuperTable::callbacks::gnuplotDirect]
    }

    puts [list computeGpDatas = $computeGpDatas]

    set tkTable $privArray(tkTable)
    puts [concat $computeGpDatas [list $tkTable $colnames]]

    set datas "@@$tkSuperTable::SUPERTABLES(spt,[winfo parent [winfo parent $tkTable]])\n"
    append datas @$colnames\n
    append datas [eval $computeGpDatas [list $tkTable $colnames]]
    # Le double retour chariot qui doit interrompre le réception des données
    append datas \n
    puts $channel $datas
    puts stderr "externExec: datas envoyé à $channel"
    set retour [gets $channel]
    puts stderr "externExec: retour lu sur $channel"
    close $channel
    puts stderr "externExec: reçu \" $retour\", passé à gnuplot..."
    puts $privArray(channel) $retour
}

proc tkSuperTable::callbacks::createGnuplot {} {

    set gW .gnuplotCommands

    if {[info exists $gW]} {
	set i 2
	set gW .gnuplotCommands#$i
	while {[info exists $gW]}  {
	    incr i
	    set gW .gnuplotCommands#$i
	}
	unset i
    }

    upvar #0 privArray$gW privArray

    if {[winfo exists $gW]} {
	# il faudrait tester privArray(plotEnCours)
        $gW.plot.buttons.replot configure\
		-command "tkSuperTable::callbacks::gnuplotPlot $gW"
    } else {        
        set privArray(channel) [open "|gnuplot 2>@ stderr" w]
        fconfigure $privArray(channel) -buffering line

        toplevel $gW

        frame $gW.vars    -relief sunken
        frame $gW.plot    -relief sunken
        frame $gW.plot.courbes -relief sunken
        frame $gW.fit

	frame $gW.ftxt
        text  $gW.ftxt.txt -width 40 -height 10
        $gW.ftxt.txt insert end {set log y}
	$gW.ftxt.txt insert end \n
        $gW.ftxt.txt insert end \n
        $gW.ftxt.txt insert end {f(x) = a*x + b}
        $gW.ftxt.txt insert end \n
        $gW.ftxt.txt insert end {set terminal postscript}
	$gW.ftxt.txt insert end \n
        $gW.ftxt.txt insert end {set output "| lp"}
	$gW.ftxt.txt insert end \n
        $gW.ftxt.txt insert end {replot}
	$gW.ftxt.txt insert end \n
        $gW.ftxt.txt insert end {set output}
	$gW.ftxt.txt insert end \n
        $gW.ftxt.txt insert end {set terminal X11}
	$gW.ftxt.txt insert end \n

        label $gW.lpvars -text "préparation"
        entry $gW.pvars -width 30 -textvariable privArray$gW\(var:0)

        label $gW.lvars -text "variables"
        
        for {set i 1} {$i <= 12} {incr i} {
	    label $gW.vars.l$i -text "(\$$i) :"
	    entry $gW.vars.$i -width 10 -textvariable privArray$gW\(var:$i)
	}

        label $gW.plot.l1 -text "plot"
        entry $gW.plot.i1 -width 40
        
        label $gW.fit.l1 -text "fit"
        entry $gW.fit.i1 -width 40 -textvariable privArray$gW\(fit:i1)
        $gW.fit.i1 delete 0 end
        $gW.fit.i1 insert 0 {[:] f(x)}
        
        label $gW.plot.l2 -text "title"
        entry $gW.plot.i2 -width 40
        
        label $gW.fit.l2 -text "..."
        entry $gW.fit.i2 -width 40 -textvariable privArray$gW\(fit:i2)
        $gW.fit.i2 delete 0 end
        $gW.fit.i2 insert 0 {using ( ($1)):( ($2))}
        
        label $gW.plot.l3 -text "..."
        entry $gW.plot.i3 -width 40
                
        label $gW.fit.l3 -text "via"
        entry $gW.fit.i3 -width 40 -textvariable privArray$gW\(fit:i3)
        $gW.fit.i3 delete 0 end
        $gW.fit.i3 insert 0 {a, b}

        button $gW.sendtxt -text "send\nselected\ncommands" -command "tkSuperTable::callbacks::sendtxt $gW.ftxt.txt $privArray(channel)"

	frame $gW.plot.buttons
        button $gW.plot.buttons.replot -text plot -command "tkSuperTable::callbacks::gnuplotPlot $gW"
        button $gW.plot.buttons.hold -text hold -command "tkSuperTable::callbacks::gnuplotHold $gW"
        button $gW.plot.buttons.free -text free -command "tkSuperTable::callbacks::gnuplotFree $gW"
        button $gW.fit.fit -text fit -command "tkSuperTable::callbacks::gnuplotFit $gW"

	button $gW.save -text "save\nconfig" -command "tkSuperTable::callbacks::gnuplotSaveConfig $gW"
	button $gW.load -text "load\nconfig" -command "tkSuperTable::callbacks::gnuplotLoadConfig $gW"

        checkbutton $gW.debug -text debug -variable privArray$gW\(debug)

	label $gW.lcourbes -text "courbes"

	# 2 "for" indépendants pour la navigation (TAB, Shift/TAB)
	for {set i 1} {$i <= 16} {incr i} {
	    radiobutton $gW.plot.courbes.r$i -variable privArray$gW\(paramsOfCurve#) -value $i\
		    -command "tkSuperTable::callbacks::gnuplotSeePlotParams $gW"
	}
	for {set i 1} {$i <= 16} {incr i} {
	    checkbutton $gW.plot.courbes.s$i -variable privArray$gW\(plotIt:$i)
	}

	label $gW.plot.lscourbes -text trace
	label $gW.plot.lrcourbes -text définit

        grid configure\
		$gW.plot.courbes.s1\
		$gW.plot.courbes.s2\
		$gW.plot.courbes.s3\
		$gW.plot.courbes.s4\
		$gW.plot.courbes.s5\
		$gW.plot.courbes.s6\
		$gW.plot.courbes.s7\
		$gW.plot.courbes.s8\
		$gW.plot.courbes.s9\
		$gW.plot.courbes.s10\
		$gW.plot.courbes.s11\
		$gW.plot.courbes.s12\
		$gW.plot.courbes.s13\
		$gW.plot.courbes.s14\
		$gW.plot.courbes.s15\
		$gW.plot.courbes.s16\
		-sticky news

        grid configure\
		$gW.plot.courbes.r1\
		$gW.plot.courbes.r2\
		$gW.plot.courbes.r3\
		$gW.plot.courbes.r4\
		$gW.plot.courbes.r5\
		$gW.plot.courbes.r6\
		$gW.plot.courbes.r7\
		$gW.plot.courbes.r8\
		$gW.plot.courbes.r9\
		$gW.plot.courbes.r10\
		$gW.plot.courbes.r11\
		$gW.plot.courbes.r12\
		$gW.plot.courbes.r13\
		$gW.plot.courbes.r14\
		$gW.plot.courbes.r15\
		$gW.plot.courbes.r16\
		-sticky news

	for {set i 1} {$i <= 16} {incr i} {
	    grid columnconfigure $gW.plot.courbes [expr {$i - 1}] -weight 1
	}

	for {set i 1} {$i <= 16} {incr i} {
	    set j [expr {$i + 1}]
	    if {$j > 12} {
		set j 1
	    }
	    set privArray(i1:$i) "using ( (\$1)):( (\$$j))"
	    set privArray(i2:$i) {}
	    set privArray(i3:$i) {}
	}
	for {set i 12} {$i <= 16} {incr i} {
	    set privArray(i1:$i) "using ( (\$1)):( (\$1))"
	}
	set privArray(paramsOfCurve#) 1
	set privArray(plotIt:1) 1
	# invoke ??
	tkSuperTable::callbacks::gnuplotSeePlotParams $gW

        frame $gW.externExec
        button $gW.externExec.exec -text exec -command "tkSuperTable::callbacks::externExec $gW $gW.externExec.program $gW.externExec.cols"
        entry $gW.externExec.program
        entry $gW.externExec.cols -width 20
        $gW.externExec.program insert 0 "/home/fab/A/fidev/Tcl/superTable/bin/essaiExternExec.tcl"
        $gW.externExec.cols insert 0 {Ic Vce}
        grid configure $gW.externExec.exec $gW.externExec.program $gW.externExec.cols -sticky ewns
        grid columnconfigure $gW.externExec 0 -weight 0
        grid columnconfigure $gW.externExec 1 -weight 1
        grid columnconfigure $gW.externExec 2 -weight 0

        grid configure $gW.lpvars   -     $gW.pvars      -    -sticky ewns
        grid configure $gW.lvars    -     $gW.vars       -    -sticky ewns
        grid configure $gW.save  $gW.load $gW.plot    $gW.fit -sticky ewns
        grid configure $gW.debug    -        ^           ^    -sticky ewns
        grid configure    x         x     $gW.externExec -    -sticky ewns
        grid configure $gW.sendtxt  -     $gW.ftxt       -    -sticky ewns

        grid columnconfigure $gW      0 -weight 0
        grid columnconfigure $gW      1 -weight 0
        grid columnconfigure $gW      2 -weight 1
        grid columnconfigure $gW      3 -weight 1

	grid rowconfigure $gW 0 -weight 0
	grid rowconfigure $gW 1 -weight 0
	grid rowconfigure $gW 2 -weight 0
	grid rowconfigure $gW 3 -weight 0
	grid rowconfigure $gW 4 -weight 1

	widgets::packWithScrollbar $gW.ftxt txt

        grid configure\
		$gW.vars.l1 $gW.vars.1\
		$gW.vars.l2 $gW.vars.2\
		$gW.vars.l3 $gW.vars.3\
		$gW.vars.l4 $gW.vars.4\
		$gW.vars.l5 $gW.vars.5\
		$gW.vars.l6 $gW.vars.6\
		-sticky ewns
        grid configure\
		$gW.vars.l7 $gW.vars.7\
		$gW.vars.l8 $gW.vars.8\
		$gW.vars.l9 $gW.vars.9\
		$gW.vars.l10 $gW.vars.10\
		$gW.vars.l11 $gW.vars.11\
		$gW.vars.l12 $gW.vars.12\
		-sticky ewns
	grid columnconfigure $gW.vars  0 -weight 0
	grid columnconfigure $gW.vars  1 -weight 1
	grid columnconfigure $gW.vars  2 -weight 0
	grid columnconfigure $gW.vars  3 -weight 1
	grid columnconfigure $gW.vars  4 -weight 0
	grid columnconfigure $gW.vars  5 -weight 1
	grid columnconfigure $gW.vars  6 -weight 0
	grid columnconfigure $gW.vars  7 -weight 1
	grid columnconfigure $gW.vars  8 -weight 0
	grid columnconfigure $gW.vars  9 -weight 1
	grid columnconfigure $gW.vars 10 -weight 0
	grid columnconfigure $gW.vars 11 -weight 1

	grid configure $gW.plot.lscourbes $gW.plot.courbes -sticky ewns
	grid configure $gW.plot.lrcourbes    ^             -sticky ewns
        grid configure $gW.plot.l1        $gW.plot.i1      -sticky ewns
        grid configure $gW.plot.l2        $gW.plot.i2      -sticky ewns
        grid configure $gW.plot.l3        $gW.plot.i3      -sticky ewns
        grid configure $gW.plot.buttons      -             -sticky ewns
        
	grid configure $gW.plot.buttons.replot $gW.plot.buttons.hold $gW.plot.buttons.free -sticky ewns
	grid columnconfigure $gW.plot.buttons 0 -weight 1
	grid columnconfigure $gW.plot.buttons 1 -weight 0
	grid columnconfigure $gW.plot.buttons 2 -weight 0

        grid columnconfigure $gW.plot 0 -weight 0
        grid columnconfigure $gW.plot 1 -weight 1

	label $gW.fit.ldummy
	label $gW.fit.ldummy2

        grid configure $gW.fit.ldummy  x       -sticky ewns
        grid configure $gW.fit.ldummy2 x       -sticky ewns
        grid configure $gW.fit.l1   $gW.fit.i1 -sticky ewns
        grid configure $gW.fit.l2   $gW.fit.i2 -sticky ewns
        grid configure $gW.fit.l3   $gW.fit.i3 -sticky ewns
        grid configure $gW.fit.fit     -       -sticky ewns

        grid columnconfigure $gW.fit  0 -weight 0
        grid columnconfigure $gW.fit  1 -weight 1

        bind $gW.ftxt <Destroy> "close $privArray(channel)"
    }
    return $gW
}

     ################################################
     # procédures de relance manuelle d'un callback #
     ################################################

proc tkSuperTable::callbacks::gnuplotPlot {gW} {
    upvar #0 privArray$gW privArray

    set privArray(plotOrFit) plot
    tkSuperTable::callbacks::gnuplotDoIt $gW
}

proc tkSuperTable::callbacks::gnuplotFree {gW} {
    upvar #0 privArray$gW privArray

    set privArray(heldCommands) {}
    set privArray(heldDatas) {}
}

proc tkSuperTable::callbacks::gnuplotHold {gW} {
    upvar #0 privArray$gW privArray

    set privArray(plotOrFit) hold
    tkSuperTable::callbacks::gnuplotDoIt $gW
}

proc tkSuperTable::callbacks::gnuplotFit {gW} {
    upvar #0 privArray$gW privArray

    set privArray(plotOrFit) fit
    tkSuperTable::callbacks::gnuplotDoIt $gW
}

proc tkSuperTable::callbacks::sendtxt {txt channel} {
    if {![catch {$txt get sel.first sel.last} commande]} {
        puts $channel $commande
    }
}

# enregistrement du callback dans le menu

set tkSuperTable::callbacks::CALLBACKS(gnuplot) {}












