proc tkSuperTable::callbacks::gnuplotPlot {win} {
    global plotOrFit
    set plotOrFit plot
    tkSuperTable::callbacks::gnuplot $win
}

proc tkSuperTable::callbacks::gnuplotFit {win} {
    global plotOrFit
    set plotOrFit fit
    tkSuperTable::callbacks::gnuplot $win
}

proc tkSuperTable::callbacks::gnuplot {win} {
    global gnuplotChannel plotEnCours gnuplotDebug plotOrFit

    set plotEnCours 0
    # puts stderr "createGnuplot $win appelé"
    set gW [createGnuplot $win]
    # puts stderr "createGnuplot terminé"

    if {![info exists plotOrFit]} {
	return
    }

    # récupération du tableau associé à la table
    upvar #0 [$win cget -variable] tableau
    # récupération des index des colonnes

    set ncvar 0
    for {set icvar 1} {$icvar <= 6} {incr icvar} {
	set ic($icvar) [tkSuperTable::getColIndex $win [$gW.axes.$icvar get]]
    }

  # boucle sur tous les index deligne
    set plotEnCours 1
    if {$plotOrFit == "plot"} {
        set commande "plot \"-\" [$gW.plot.i1 get] title \"[$gW.plot.i2 get]\" [$gW.plot.i3 get]"
    } elseif {$plotOrFit == "fit"} {
        set commande "fit [$gW.fit.i1 get] \"-\" [$gW.fit.i2 get] via [$gW.fit.i3 get]"
    }
    puts $gnuplotChannel $commande
    if {$gnuplotDebug} {
        puts "gnuplot> $commande"
    }
    foreach ili [tkSuperTable::toutesLignes $win] {
	for {set icvar 1} {$icvar <= 6} {incr icvar} {
	    if {[info exists tableau($ili,$ic($icvar))]} {
		set val $tableau($ili,$ic($icvar))
	    } else {
		set val "nc"
	    }
	    if {$icvar != 1} {
		if {$gnuplotDebug} {
		    puts -nonewline \t
		}
		puts -nonewline $gnuplotChannel \t
	    }
	    if {$gnuplotDebug} {
		puts -nonewline $val
	    }
	    puts -nonewline $gnuplotChannel $val
	}
	if {$gnuplotDebug} {
	    puts {}
	}
	puts $gnuplotChannel {}
    }
  # termine le plot
    set plotEnCours 0
    if {$gnuplotDebug} {
	puts "e"
    }
    puts $gnuplotChannel "e"
}


proc tkSuperTable::callbacks::createGnuplot {win} {
    global gnuplotChannel plotEnCours gnuplotWin gnuplotDebug
puts [list win = $win]
    set gnuplotWin $win
    set gW .gnuplotCommands
    if {![winfo exists $gW]} {
        set gnuplotChannel [open "|gnuplot 2>@ stderr" w]
        fconfigure $gnuplotChannel -buffering line

puts "toplevel $gW"
        toplevel $gW

        frame $gW.axes -relief sunken
        frame $gW.plot -relief sunken
        frame $gW.fit

        text $gW.txt -width 40 -height 10
        $gW.txt insert end {set log y} ; $gW.txt insert end \n
        $gW.txt insert end \n
        $gW.txt insert end {f(x) = a*x + b}
        $gW.txt insert end \n
        $gW.txt insert end {set terminal postscript} ; $gW.txt insert end \n
        $gW.txt insert end {set output "| lp"} ; $gW.txt insert end \n
        $gW.txt insert end {replot} ; $gW.txt insert end \n
        $gW.txt insert end {set output} ; $gW.txt insert end \n
        $gW.txt insert end {set terminal X11} ; $gW.txt insert end \n

        label $gW.laxes -text "axes"
        
        label $gW.axes.l1 -text "(\$1) :"
        entry $gW.axes.1 -width 10

        label $gW.axes.l2 -text "(\$2) :"
        entry $gW.axes.2 -width 10

        label $gW.axes.l3 -text "(\$3) :"
        entry $gW.axes.3 -width 10

        label $gW.axes.l4 -text "(\$4) :"
        entry $gW.axes.4 -width 10

        label $gW.axes.l5 -text "(\$5) :"
        entry $gW.axes.5 -width 10

        label $gW.axes.l6 -text "(\$6) :"
        entry $gW.axes.6 -width 10

        label $gW.plot.l1 -text "plot"
        entry $gW.plot.i1 -width 40
        $gW.plot.i1 delete 0 end
        $gW.plot.i1 insert 0 {using ( ($1)):( ($2))}
        
        label $gW.fit.l1 -text "fit"
        entry $gW.fit.i1 -width 40
        $gW.fit.i1 delete 0 end
        $gW.fit.i1 insert 0 {[:] f(x)}
        
        label $gW.plot.l2 -text "title"
        entry $gW.plot.i2 -width 40
        set titre [[winfo parent [winfo parent $win]].titre cget -text]
        $gW.plot.i2 delete 0 end
        $gW.plot.i2 insert 0 $titre
        
        label $gW.fit.l2 -text "..."
        entry $gW.fit.i2 -width 40
        $gW.fit.i2 delete 0 end
        $gW.fit.i2 insert 0 {using ( ($1)):( ($2))}
        
        label $gW.plot.l3 -text "..."
        entry $gW.plot.i3 -width 40
                
        label $gW.fit.l3 -text "via"
        entry $gW.fit.i3 -width 40
        $gW.fit.i3 delete 0 end
        $gW.fit.i3 insert 0 {a, b}

        button $gW.sendtxt -text "send\nselected\ncommands" -command "tkSuperTable::callbacks::sendtxt $gW.txt $gnuplotChannel"

        button $gW.plot.replot -text replot -command "tkSuperTable::callbacks::gnuplotPlot $gnuplotWin"
        button $gW.fit.fit -text fit -command "tkSuperTable::callbacks::gnuplotFit $gnuplotWin"
        checkbutton $gW.debug -text debug -variable gnuplotDebug

        grid configure $gW.laxes   $gW.axes    -    -sticky ewns
        grid configure $gW.debug   $gW.plot $gW.fit -sticky ewns
        grid configure $gW.sendtxt $gW.txt     -    -sticky ewns

        grid configure\
		$gW.axes.l1 $gW.axes.1\
		$gW.axes.l2 $gW.axes.2\
		$gW.axes.l3 $gW.axes.3\
		$gW.axes.l4 $gW.axes.4\
		$gW.axes.l5 $gW.axes.5\
		$gW.axes.l6 $gW.axes.6\
		-sticky ewns

        grid configure $gW.plot.l1 $gW.plot.i1 -sticky ewns
        grid configure $gW.plot.l2 $gW.plot.i2 -sticky ewns
        grid configure $gW.plot.l3 $gW.plot.i3 -sticky ewns
        grid configure $gW.plot.replot -       -sticky ewns
        
        grid configure $gW.fit.l1 $gW.fit.i1 -sticky ewns
        grid configure $gW.fit.l2 $gW.fit.i2 -sticky ewns
        grid configure $gW.fit.l3 $gW.fit.i3 -sticky ewns
        grid configure $gW.fit.fit   -       -sticky ewns

# A VOIR pour le faire sur $gW
        grid columnconfigure $gW 0 -weight 0
        grid columnconfigure $gW 1 -weight 1
        grid columnconfigure $gW.plot 0 -weight 0
        grid columnconfigure $gW.plot 1 -weight 1
        grid columnconfigure $gW.fit 0 -weight 0
        grid columnconfigure $gW.fit 1 -weight 1
        bind $gW.txt <Destroy> "close $gnuplotChannel"
    } else {
        
        set titre [[winfo parent [winfo parent $win]].titre cget -text]
        $gW.plot.i2 delete 0 end
        $gW.plot.i2 insert 0 $titre
        $gW.plot.replot configure -command {
# il faudrait tester plotEnCours
            tkSuperTable::callbacks::gnuplotPlot $gnuplotWin
        }
    }
    return $gW
}

proc tkSuperTable::callbacks::sendtxt {txt gnuplotChannel} {
    if {![catch {$txt get sel.first sel.last} commande]} {
        puts $gnuplotChannel $commande
    }
}


# enregistrement du callback dans le menu

set tkSuperTable::callbacks::CALLBACKS(gnuplot) {}





  proc gnuplot.old {_win} {
      global gnuplotChannel plotEnCours gnuplotDebug
puts "entré dans gnuplot $_win"
      set plotEnCours 0
      set gW [createGnuplot $_win]
    # récupération du tableau associé à la table
      upvar #0 [$_win cget -variable] tableau
    # récupération des index des colonnes
      set _colonnes [tkSuperTable::toutesColonnes $win]
      set _i 0
      foreach _co $colonnes {
	  set _ico($_co) $_i
	  incr _i
      }
      
  
    # boucle sur tous les index deligne
      set plotEnCours 1
      set commande "plot \"-\" [$gW.i1 get] title \"[$gW.i2 get]\" [$gW.i3 get]"
      puts $gnuplotChannel $commande
      if {$gnuplotDebug} {
	  puts "gnuplot> $commande"
      }
  
      set lignes [list]
      foreach ili [tkSuperTable::toutesLignes $_win] {
	  
	  if {[info exists tableau($ili,$ic1)] &&
	      [info exists tableau($ili,$ic2)]} {
	      lappend lignes [list $V $I)]
	  }
      }
  
      foreach ligne $lignes {
	  {
	      puts $gnuplotChannel [join $ligne \t]
	  }
      }
    # termine le plot
      set plotEnCours 0
      puts $gnuplotChannel "e"
  
  }
