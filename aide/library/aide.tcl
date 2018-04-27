package provide aide 1.2

source [file dirname [info script]]/newproc.2017-05-22.tcl

# important pour récupérer la touche Help sur les boutons
tk_focusFollowsMouse

set HELP(HELP) {
HELP(sujet) : tableau global contenant la description du mot "sujet"
}

namespace eval aide {

    namespace export nondocumente
      proc nondocumente {win} {
	  global HELP
	  foreach f [winfo children $win] {
	      if {![info exists HELP($f)]} {
		  puts stderr "$f Non documenté"
		  set dodo "Pas d'information explicite pour l'instant sur $f\n"
	      } else {
		  set dodo $HELP($f)
	      }
	      WIN_DOCUMENT $f $dodo
	      nondocumente $f
	  }
      }
      
      proc WIN_DOCUMENT {win contenu} {
	  global HELP
	  set HELP($win) $contenu
	  bind $win <KeyRelease-Help> "::aide::waide %W"
	  bind $win <KeyRelease-F1> "::aide::waide %W"
      }
      
      proc selectaide {win} {
	  global HELP
	  set mot [$win get sel.first sel.last]
	  set mot [string trim $mot " \n\t\r"]
	  if {[info exists HELP($mot)]} {
	      if {[winfo exists $mot]} {
		  waide $mot
	      } else {
		  $win insert end "\n$HELP($mot)"
	      }
	  } elseif {[PerformAproposSearch $mot]!=0} {
	      [winfo parent [winfo parent $win]].mes configure \
		  -text "appel de tchelp \"$mot\""
	  } else {
	      [winfo parent [winfo parent $win]].mes configure \
		  -text "Pas d'information spécifique sur \"$mot\""
	  }
      }
      
      proc see_prog {window text} {
	  $text insert end "\n"
	  $text yview end
	  $text insert end "                    ******************************\n"
	  $text insert end "\nObjet    : $window\n"
	  $text insert end "\nNature   : [winfo class $window]\n"
	  catch {pack info $window} tp
	  $text insert end "\nPacking  : $tp\n"
	  catch {grid info $window} tp
	  $text insert end "\nGriding  : $tp\n"
	  if {![catch {$window configure -command} tp]} {
	      $text insert end "\nCode     : \n"
	      $text insert end "[lindex $tp 4]\n"
	  }
	  $text insert end "\nBindings :"
	  set lb [bind $window]
	  if {$lb == {}} {
	      $text insert end " néant\n";
	  } else {
	      $text insert end "\n"
	  }
	  foreach bibi $lb {
	      $text insert end "$bibi [bind $window $bibi]\n"
	  }
	  $text insert end "\nConfigure :\n"
	  set concon [$window configure]
	  foreach bibi $concon {
	      $text insert end "$bibi\n"
	  }
      }
      
      proc nameSpaceHier {nf} {
	  set retour [list $nf]
	  set ncs [namespace children $nf]
	  foreach nc [lsort $ncs] {
	      set retour [concat $retour [nameSpaceHier $nc]]
	  }
	  return $retour
      } 

      proc man {text} {
	  global FILEOFPROC
	  set mot [$text get sel.first sel.last]
	  set mot [string trim $mot " \n\t\r"]
	  $text insert end "\n"
	  $text yview end
      
	  $text insert end "                    ******************************\n"
	  
        catch {exec man -F -M /prog/Tcl/man $mot} mama
        $text insert end $mama
        $text insert end "\n"
    }	      
      
      proc see_code {text} {
	  global FILEOFPROC
	  set mot [$text get sel.first sel.last]
	  set mot [string trim $mot " \n\t\r"]
      #    set debut [$text index end]
	  $text insert end "\n"
	  $text yview end
      
	  $text insert end "                    ******************************\n"
	  
	  if {[catch {namespace eval :: [list namespace origin $mot]} momo]} {
	      set mots {}
	      foreach n [nameSpaceHier ::] {
		  foreach m [lsort [namespace eval $n [list info procs $mot]]] {
		      if {$n == "::"} {
			  lappend mots $m
		      } else {
			  lappend mots ${n}::$m
		      }
		  }
	      }
	  } else {
	      set n [namespace qualifiers $momo]
	      if {$n == {}} {
		  set nana "::"
	      } else {
		  set nana $n
	      }
	      set mot [namespace tail $momo]
	      set momo [namespace eval $nana [list info procs $mot]]
	      if {$momo == {}} {
		  $text insert end "${n}::$mot est une commande native, pas une procédure\n"
		  return 1
	      } else {
		  set mots [list ${n}::$momo]
	      }
	  }
	  if {[llength $mots] > 1} {
	      $text insert end "il y ambiguité, sélectionnez une ligne :\n\n"
	      foreach mot $mots {
		  $text insert end "    $mot\n"
	      }
	      return 1
	  } elseif {[llength $mots] == 0} {
	      $text insert end "il n'y a aucune procédure \"$mot\" dans aucun namespace\n"
	      return 1
	  } else {
	      set mot [lindex $mots 0]
	  }
      
	  if {[info exists FILEOFPROC($mot)]} {
	      $text insert end "$FILEOFPROC($mot)\n\n"
	  }
      
	  $text insert end "proc $mot {"
	  set espace {}
	  foreach a [info args $mot] {
	      if {$espace == {}} {
		  set espace " "
	      } else {
		  $text insert end $espace
	      }
	      if {[info default $mot $a def]} {
		  $text insert end "{$a $def}"
	      } else {
		  $text insert end $a
	      }
	  }
	  $text insert end "} {"
	  $text insert end "[info body $mot]"
	  $text insert end "}\n"
      #    $text yview $debut
      }
      
      proc edite {text} {
	  set fifi [$text get sel.first sel.last]
	  set fifi [string trim $fifi " \n\t\r"]
      # A VOIR
	  exec emacs $fifi &
      }
      
      proc waide {window} {
	  global HELP
	  set win $window.aide
	  if {[winfo exists $win]} {
	      wm deiconify $win
	      raise $win ;# cette étape a l'air lente,
			  # beaucoup plus lente qu'une destruction et relance !!
	      update ;# inutile ?
	  } else {
	      toplevel $win
	      wm title $win "Aide sur $window"
      
	      frame $win.stxt
	      set txt [text $win.stxt.t]
	      set sb [scrollbar $win.stxt.sb]
	      $win.stxt.sb configure -command "$win.stxt.t yview"
	      $win.stxt.t configure -yscrollcommand "$win.stxt.sb set"
	      pack $win.stxt.sb -side left -fill y
	      pack $win.stxt.t -fill both
      
	      $txt insert 0.0 $HELP($window)
      
	      label $win.minihelp -relief sunken
	      pack $win.minihelp -side bottom -expand 1 -fill x
	      frame $win.bts
	      pack $win.bts -side bottom
	      button $win.bts.exit -text close -command "destroy $win"
	      button $win.bts.code -text "info obj." -command "::aide::see_prog $window $txt"
	      button $win.bts.codex -text "code" -command "::aide::see_code $txt"
	      button $win.bts.man -text "man" -command "::aide::man $txt"
	      button $win.bts.edite -text "édite" -command "::aide::edite $txt"
	      pack $win.bts.edite $win.bts.man $win.bts.codex $win.bts.code $win.bts.exit -side left
	      label $win.mes
	      pack $win.mes -side bottom
	      ui_minihelp $win.minihelp $win.bts.edite {édite le fichier correspondant à la sélection}
	      ui_minihelp $win.minihelp $win.bts.codex {affiche le code de la procédure sélectionnée (* accepté)}
	      ui_minihelp $win.minihelp $win.bts.exit {ferme la fenêtre}
	      ui_minihelp $win.minihelp $win.bts.code "affiche les caractistiques de $window"
	      
      # il faut mettre les boutons avant le text pour qu'ils ne se fassent pas bouffer        # lors d'un resize
      
      
	      pack $win.stxt -expand 1 -fill both
	      $txt tag bind sel <KeyRelease-Help> {::aide::selectaide %W}
	      nondocumente $win
	  }
      }
      
      
      # Repris de 
      # tclhelp.tcl --
      #
      # Tk program to access Extended Tcl & Tk help pages.  Uses internal functions
      # of TclX help command.
      # 
      #------------------------------------------------------------------------------
      # Copyright 1993-1995 Karl Lehenbauer and Mark Diekhans.
      #
      # Permission to use, copy, modify, and distribute this software and its
      # documentation for any purpose and without fee is hereby granted, provided
      # that the above copyright notice appear in all copies.  Karl Lehenbauer and
      # Mark Diekhans make no representations about the suitability of this
      # software for any purpose.  It is provided "as is" without express or
      # implied warranty.
      #------------------------------------------------------------------------------
      # $Id: aide.tcl,v 1.2 2003/05/05 08:09:15 fab Exp $
      #------------------------------------------------------------------------------
      
      
      #------------------------------------------------------------------------------
      # Display a file in a top-level text window.
      
      proc DisplayPage {page} {
	  set fileName [file tail $page]
      
	  set w ".tkhelp-[translit "." "_" $page]"
      
	  if {[winfo exists $w]} {
	      destroy $w
	  }
	  toplevel $w
      
	  wm title $w "Help on '$page'"
	  wm iconname $w "Help: $page"
	  wm minsize $w 1 1
	  frame $w.frame -borderwidth 10
      
	  scrollbar $w.frame.yscroll -relief sunken \
	      -command "$w.frame.page yview"
	  text $w.frame.page -yscrollcommand "$w.frame.yscroll set" \
	      -width 80 -height 20 -relief sunken -wrap word
	  pack $w.frame.yscroll -side right -fill y
	  pack $w.frame.page -side top -expand 1 -fill both
      
	  if {[catch {
		  set contents [read_file [help:ConvertPath $page]]
	      } msg]} {
	      set contents $msg
	  }
	  $w.frame.page insert 0.0 $contents
	  $w.frame.page configure -state disabled
      
	  button $w.dismiss -text Dismiss -command "destroy $w"
	  pack $w.dismiss -side bottom -fill x
	  pack $w.frame -side top -fill both -expand 1
      }
      
      #---------------------------------------------------------------------------
      #put a line in the reference display for this apropos entry we've discovered
      #
      proc DisplayAproposReference {e path description rf} {
      
      
	  upvar $rf aproposReferenceFrame
	      
	  set frame $aproposReferenceFrame.e$e
	  frame $frame
	  pack $frame -side top -anchor w
      
	  button $frame.button -text $path -width 30 \
	      -command "::aide::DisplayPage /$path"
	  pack $frame.button -side left
      
	  label $frame.label -text $description
	  pack $frame.label -side left
      
      }
      
      #---------------------------------------------------------------------------
      #the actual search is cadged from "apropos" in the tclx help system
      #
      proc PerformAproposSearch {regexp} {
      puts stderr "PerformAproposSearch $regexp"
	  global TCLXENV
      
	  if {$regexp == {}} {
	      return 0
	  }
	  
	  if {[winfo exists .apropos_$regexp]} {
	      wm deiconify .apropos_$regexp
	      raise .apropos_$regexp
	      return -1
	  }
	      
	  toplevel .apropos_$regexp
	  wm minsize .apropos_$regexp 1 1
      
	  # put in the dismiss button
	  set w .apropos_$regexp.buttonFrame
	  frame $w
	  pack $w -side bottom -fill x
	  button $w.dismiss -text Dismiss -command "destroy .apropos_$regexp"
	  pack $w.dismiss -side bottom -fill x
      
	  frame .apropos_$regexp.canvasFrame
	  set w .apropos_$regexp.canvasFrame
      
	  canvas $w.canvas -yscrollcommand "$w.yscroll set" \
		  -xscrollcommand "$w.xscroll set" \
		  -width 15c -height 5c -relief sunken
      
	  scrollbar $w.yscroll -relief sunken \
	      -command "$w.canvas yview"
      
	  scrollbar $w.xscroll -relief sunken -orient horiz \
	      -command "$w.canvas xview"
      
	  pack $w.xscroll -side bottom -fill x
	  pack $w.yscroll -side right -fill y
	  pack $w.canvas -in $w -expand yes -fill both
	  pack $w -side bottom -expand yes -fill both
      
	  #  start variables and clean up any residue from previous searches
	  set w .apropos_$regexp.canvasFrame
	  set aproposEntryNumber 0
	  .apropos_$regexp.canvasFrame.canvas delete all
	  set aproposReferenceFrame $w.canvas.frame
	  catch {destroy .apropos_$regexp.canvasFrame.failed}
      
	  # create the frame we'll pack matches into and put it into the canvas
	  frame $aproposReferenceFrame
	  set referenceFrameItem \
	      [$w.canvas create window 2 2 -window $aproposReferenceFrame -anchor nw]
      
	  set TCLXENV(help:lineCnt) 0
      
	  set entries {}
	  
	  # set up scan context
	  set ch [scancontext create]
	  scanmatch -nocase $ch $regexp {
	      set p [lindex $matchInfo(line) 0]
	      lappend entries $aproposEntryNumber
	      set path($aproposEntryNumber) $p
	      set desc($p) [lrange $matchInfo(line) 1 end]
	      incr aproposEntryNumber
	  }
      
	  # perform search
	  foreach dir [help:RootDirs] {
	      foreach brief [glob -nocomplain $dir/*.brf] {
		  set briefFH [open $brief]
		  scanfile $ch $briefFH
		  close $briefFH
	      }
	  }
      
	  # delete scan context
	  scancontext delete $ch
	  
	  # if nothing matched, complain
	  if {$aproposEntryNumber == 0} {
	      destroy .apropos_$regexp
	      return 0
	  }
      
	  foreach e $entries {
	      set p $path($e)
	      DisplayAproposReference $e $p $desc($p) aproposReferenceFrame
	  }
	  
	  # force display to update so we can find out our bounding box
	  update
      
      
	  # set the canvas scrollregion to the size of the bounding box
	  lassign [.apropos_$regexp.canvasFrame.canvas bbox $referenceFrameItem] \
	      dummy dummy xSize ySize
	  .apropos_$regexp.canvasFrame.canvas configure -scrollregion \
	      "0 0 $xSize $ySize"
	  return $aproposEntryNumber
      }

}
