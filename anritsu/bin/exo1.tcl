namespace eval anritsu::db {
    variable COLNAMES
    variable L
    variable C
    variable GROUP
    variable CH
    variable W_COLNAMES
    variable W_COMMANDS
}

proc anritsu::db::read_file {filename} {
    variable COLNAMES
    variable L
    variable C
    variable GROUP
    variable CH
    variable W_COLNAMES
    variable W_COMMANDS

    set f [open $filename]
    fconfigure $f -encoding iso8859-1 -translation binary
    set lignes [read $f]
    close $f

    set lignes [split $lignes \r]
    set COLNAMES [split [lindex  $lignes 0] \t]
    set NCOLS [llength $COLNAMES]
   
    # Construction du tableau L nom_de_commande -> liste_des_cellules

    set i 0
    for {set i 1} {$i < [llength $lignes]} {incr i} {
	set value [lindex $lignes $i]
	if {$value==""} continue 
	set l [split $value \t] 
	
    # ---------------------------------------------------------

	set ncol [llength $l]
	
	if {$ncol!=$NCOLS}  {puts "erreur ligne $i j'ai $ncol éléments au lieu de $NCOLS"}
	
	puts [list $i [lindex $l 0] [lindex $l 1]]
	set L([lindex $l 0]) $l
    } 
    
    # Construction d'un tableau C : nom_de_colonne -> indice_de_colonne
    
    set ic 0
    foreach c $COLNAMES {
	set C($c) $ic
	incr ic
    }

    # liste des noms de commandes
    
    set COMMANDS [array names L]
    
    catch {unset GROUP}
    
    # tableau GROUP : nom_de_commande -> nom_de_groupe (ex: {DISPLAY (Ch 5)})
    
    foreach c $COMMANDS {
	set case [contenu $c {Group}]
	lappend GROUP($case) $c 
    }
    
    # extraction du numéro de chapitre à partir du nom de groupe
    # tableau CH : numéro_de_chapitre -> liste_de_commandes_du_chapitre
    
    catch {unset CH}
    
    foreach g [lsort [array names GROUP]] {
	if {![regexp {\(Ch ([0-9]+)\)$} $g tout ch]} {
	    set ch 0
	}
	lappend CH($ch) $g
    }

    set W_COMMANDS 0
    foreach c $COMMANDS {
	set w [string length $c]
	if {$w > $W_COMMANDS} {
	    set W_COMMANDS $w
	}
    }

    set W_COLNAMES 0
    foreach c $COLNAMES {
	set w [string length $c]
	if {$w > $W_COLNAMES} {
	    set W_COLNAMES $w
	}
    }
}

proc anritsu::db::contenu {commande colonne} {
    variable C
    variable L
    set ligne $L($commande)
    set case [lindex $ligne $C($colonne)]
    return $case
}

proc anritsu::db::contenus {commande} {
    variable L
    variable COLNAMES
    set cellules $L($commande)

    foreach col $COLNAMES {
	puts "[format %40s $col] : [anritsu::db::contenu $commande $col]"
    }
}

# affichage des commandes, par chapitre

proc anritsu::db::affiche_tout {} {
    variable CH
    variable GROUP
    foreach ch [lsort -integer [array names CH]] {
	puts "\n*** chapitre $ch ***"
	set group $CH($ch)
	foreach g [lsort $group] {
	    puts "\ngroupe \"$g\" :\n"
	    puts "   [lsort $GROUP($g)]"
	    foreach commande [lsort $GROUP($g)] {
		puts {}
		anritsu::db::contenus $commande
	    }
	}
    }
}

proc anritsu::db::affiche_chapitres_niveau0 {} {
    variable CH
    foreach ch [lsort -integer [array names CH]] {
	puts "anritsu::db::chapitre $ch"
    }
}

proc anritsu::db::affiche_chapitres_niveau1 {} {
    variable CH
    foreach ch [lsort -integer [array names CH]] {
	puts "anritsu::db::chapitre $ch"
	foreach group [lsort $CH($ch)] {
	    puts "  $group"
	}
    }
}

proc anritsu::db::affiche_chapitres_niveau2 {} {
    variable CH
    variable GROUP
    foreach ch [lsort -integer [array names CH]] {
	puts "chapitre $ch"
	foreach group [lsort $CH($ch)] {
	    puts "  $group"
	    foreach commande [lsort $GROUP($group)] {
		puts "    $commande"
	    }
	}
    }
}

proc anritsu::db::affiche_chapitres_niveau3 {} {
    variable CH
    variable GROUP
    variable COLNAMES
    variable W_COLNAMES
    variable W_COMMANDS
    foreach ch [lsort -integer [array names CH]] {
	puts "\nchapitre $ch"
	foreach group [lsort $CH($ch)] {
	    puts "\n  groupe $group"
	    foreach commande [lsort $GROUP($group)] {
		puts "\n    $commande"
		foreach colname $COLNAMES {
		    set value [anritsu::db::contenu $commande $colname]
		    set value [string trim $value]
		    if {$value != {}} {
#			puts "       [format "%-${W_COMMANDS}s %-${W_COLNAMES}s %s" $commande $colname $value]"
			puts "    [format "%-${W_COMMANDS}s%-${W_COLNAMES}s %s" {} $colname $value]"
		    }
		}
	    }
	}
    }
}

anritsu::db::read_file l.dat


#anritsu::db::affiche_chapitres_niveau0
#anritsu::db::affiche_chapitres_niveau1
#anritsu::db::affiche_chapitres_niveau2
anritsu::db::affiche_chapitres_niveau3
# affiche_tout


set ch8 {
    

}


set ch5 {
    *RST reset
    RST  idem
    *TRG
    WFS


    ONP

    NP51
    NP101
    NP201
    NP401
    NP801
    NP1601


}

set HELP(Formats) {
    <NR1> {1 0} {-29} {30,-2,5}
    <NR2> {1.0} {-0.0015} {12.7,-10.1}
    <NR2> {1.0E9} {7.056E3} {9.0E2,3.42E2}
    <NRf> l'un des formats <NR1>, <NR2> ou <NR3>
    <String> {"1/15/98"} {"Save ""cal_file"" now."}  {'Save "cal_file" now.'} 7 bits
    <Arbitrary ASCII> {Wiltron,37247A,123456,1.0<0A^EOI>} <- \n en même temps que EOI, 7 bits
    <Arbitrary Block> {#273<73 octets>} <- 2 donne le nombre de chiffres du nombre "73"
	{#0<les octets><0A^EOI>} <- \n en même temps que EOI
}


set HELP(SRQ) {
    définition du masque de SRQ : IPM *SRE
    
    lecture du masque de SRQ : *SRE?

    lecture du mot de statut : OPB *STB?

    Standard-ESR 
    Extended-ESR
    Limits-ESR

}