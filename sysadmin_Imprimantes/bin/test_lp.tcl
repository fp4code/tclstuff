#!/usr/local/bin/tclsh

# Script Tcl (Fabrice Pardo) qui remplace la commande lp habituelle
# d'unix

# Definition de variables utiles

set imprimeAndDelete /home/sysadmin/Tcl/Imprimantes/imprimeAndDelete.tcl
set MP               /usr/openwin/bin/mp
set LS               /bin/ls
set NISMATCH         /usr/bin/nismatch
set WAITEND          0

#
# ----------------------------------------------------------------------
# Selection de l'imprimante :
# ----------------------------------------------------------------------

# On recupere l'argument de la ligne de commande qui est derriere "-d"
set i [lsearch -glob $argv {-d*}]

if {$i < 0 && [info exists env(PRINTER)]} {
    set imprimante $env(PRINTER)
    set j $i
} elseif {$i < 0} {
# Nouveau : impression automatique sur l'imprimante la plus proche de l'écran
    set DISPLAY $env(DISPLAY)
    set dpts [string first ":" $DISPLAY]
    set MACHINE [string range $DISPLAY 0 [expr $dpts -1]]
    set ip [lindex [exec $NISMATCH name=$MACHINE hosts.org_dir] 2]
    if {![regexp {([0-9]+\.[0-9]+\.[0-9]+\.)([0-9]+)} $ip tout debut fin]} {
        error "adresse IP $ip illisible"
    }
    if {$debut != "139.100.240."} {
        error "adresse IP $ip incorrecte"
    }
    if {$fin > 128 && $fin < 160} {
        set imprimante BatK
    } elseif {$fin > 160 && $fin < 192} {
        set imprimante BatC
    } elseif {$fin > 192 && $fin < 224} {
        set imprimante BatB
    } else {
        error "adresse IP $ip correspondant ni à BatK, ni à BatC ni à BatB"
    }
    set i -1
    set j -1
} else {
    set dede [lindex $argv $i]
    set j $i
    if {[string compare $dede "-d"] != 0} {
        set imprimante [string range $dede 2 end]
    } else {
        incr j
        if {[llength $argv] <= $j} {
            puts stderr "$argv0 : -d : manque \"Imprimante\""
            exit 1
        }
        set imprimante [lindex $argv $j]
    }
}
puts stderr "imprimante = $imprimante" 


# imprimante accessible via lp

#if {[lsearch $imprimante {4si_bag}] >= 0 || \
#     [lsearch $imprimante {tek220_bag}] >= 0 || \
#     [lsearch $imprimante {xtek220_bag}] >= 0 || \
#     [lsearch $imprimante {phaser}] >= 0 || \
#     [lsearch $imprimante {xphaser}] >= 0} {
#    eval exec /usr/bin/lp $argv
#    exit 0
#}



#
# ----------------------------------------------------------------------
# recherche des arguments et recherche des fichiers a imprimer
# ----------------------------------------------------------------------

set argv [concat [lrange $argv 0 [expr $i-1]] [lrange $argv [expr $j+1] end]]

while {[string match {-*} [lindex $argv 0]]} {
    set argum [string range [lindex $argv 0] 1 end]
    set lettre [string index $argum 0]
    if {[string first $lettre {clmpsw}] >= 0} {
        set argv [concat [string range $argum 1 end] [lrange $argv 1 end]]
    } elseif {[string first $lettre {fHnoPqStTry}] >= 0} {
        if {[string length $argum] > 1} {
            set argv [lrange $argv 1 end]
        } else {
            set argv [lrange $argv 2 end]
        }
    } else {
        puts stderr "$argv0 : Option illegale -- $lettre"
        exit 1
    }
}

set fichiers $argv

# puts stderr "fichiers = \"$fichiers\""

# ----------------------------------------------------------------------
# Appel de ipp
# ----------------------------------------------------------------------

# creation d'un repertoire pour stockage fichiers temporaires
set tmp /tmp/papif.$env(USER)
if {[catch {file mkdir $tmp} err]} {
    puts stdout $err
}

#
# ----------------------------------------------------------------------
# Procedure spoule
# ----------------------------------------------------------------------

proc spoule {args} {

    global MP WAITEND
    
    if {[llength $args] == 3} {
        if {[lindex $args 0] != "-inplace"} {
            error "\nERREUR DANS \"spoule $args\""
        }
        set args [lrange $args 1 end]
        set inplace 1
        set WAITEND 1
    } else {
        set inplace 0
    }
    set tmp [lindex $args 0]
    set fichiers [lindex $args 1]

    set tmpfic {}

    foreach f $fichiers {
	puts stderr "f = $f"
        if {!$inplace} {
            set tmpf $tmp/[clock format [clock seconds] -format %Y.%m.%d.%H.%M.%S]:[file tail $f]
        }
	puts stderr "tmpf = $tmpf";
        if {![file readable $f]} {
            puts "Fichier $f : non lisible"
        } else {
	    
	    set fifi [open $f r]
	    set magic [read $fifi 2]
	    close $fifi
	    puts stderr "fifi = $fifi"
	    puts stderr "magic = $magic"
	    if {$magic == "%!"} { 
		if {$inplace} {
		    lappend tmpfic -nodelete $f
		} else {
		    if {[catch {file copy $f $tmpf} err]} {
			puts stdout $err 
		    }
		    # puts stderr "cp"
		    lappend tmpfic $tmpf
		}
	    } elseif {[file size $f] <= 11000} {
		exec $MP -lo $f > $tmpf
		lappend tmpfic $tmpf
	    } else {
		global imprimante
		puts stderr ""
		puts stderr " ERREUR : Fichier $f : non PostScript et trop grand"
		puts stderr ""
		puts stderr " EXPLICATIONS :"
		puts stderr ""
		puts stderr " - Dans le but d'éviter de gaspiller du papier,"
		puts stderr "  le programme maison \"/usr/local/bin/lp\""
		puts stderr "  ne convertit automatiquement en PostScript"
		puts stderr "  que des fichiers texte de moins de 11000 caractères,"
		puts stderr " - Si vous êtes sûr de vouloir imprimer ce fichier texte,"
		puts stderr "  utilisez explicitement un programme de mise au format PostScript"
		puts stderr " - exemple exécutable texto :"
		puts stderr "        mp -lo -s $f $f | lp -d $imprimante"
		puts stderr ""
	    }
        }
    }
    return $tmpfic
}

#
# ----------------------------------------------------------------------
# Procedure spouleOne
# ----------------------------------------------------------------------

proc spouleOne {tmp} {

    set tmpfic {}

    set tmpf $tmp/[clock format [clock seconds] -format %Y.%m.%d.%H.%M.%S].stdin
    if {[file exists $tmpf]} {
        set iv 1
        while [file exists ${tmpf}#$iv] {
            incr iv
        }
        set tmpf ${tmpf}#$iv
    }
    
    fconfigure stdin -translation binary
    set standardIn [read -nonewline stdin]
    
    set magic [string range $standardIn 0 1]
# puts stderr "magic = $magic"
    if {$magic == "%!"} {
        set tmpChannel [open $tmpf w+]
        puts $tmpChannel $standardIn
        close $tmpChannel
        lappend tmpfic $tmpf
    } else {
        puts stderr "stdin non PostScript"
    }
    return $tmpfic
}

# ----------------------------------------------------------------------
# Procedure pageEntete
# ----------------------------------------------------------------------

proc pageEntete {} {
    global env
    
    set jour(Mon) lundi
    set jour(Tue) mardi
    set jour(Wed) mercredi
    set jour(Thu) jeudi
    set jour(Fri) vendredi
    set jour(Sat) samedi
    set jour(Sun) dimanche
    
    set mois(01) janvier
    set mois(02) f\\351vrier
    set mois(03) mars
    set mois(04) avril
    set mois(05) mai
    set mois(06) juin
    set mois(07) juillet
    set mois(08) ao\373t
    set mois(09) septembre
    set mois(10) octobre
    set mois(11) novembre
    set mois(12) d\\351cembre
    
    set secondes [clock seconds]
    set an [clock format $secondes -format "%Y"]
    set nomDuMois $mois([clock format $secondes -format "%m"])
    set numJour [clock format $secondes -format "%d"]
    set heure [clock format $secondes -format "%H:%M:%S"]
    set nomDuJour $jour([clock format $secondes -format "%a"])

    return "%!PS
%%Pages: 1
%%EndComments
%%BeginProlog
/mm \{72 mul 25.4 div\} def
%%EndProlog
%%Page: 1 1
/Times-Roman findfont
60 scalefont
setfont
20 mm 265 mm moveto
($env(USER)@l2m) show
/Times-Roman findfont
20 scalefont
setfont
20 mm 240 mm moveto
($nomDuJour $numJour $nomDuMois $an) show
20 mm 230 mm moveto
($heure) show
showpage
%%Trailer"
}

#
# ----------------------------------------------------------------------
# Programme principal
# ----------------------------------------------------------------------

if {$fichiers != ""} {
    if {$imprimante != "BatBL"} {
        set tmpfic [spoule $tmp $fichiers]
    } else {
        set tmpfic [spoule -inplace $tmp $fichiers]
    }
} else {
    set tmpfic [spouleOne $tmp]
}

if {$imprimante == "4si_bag"} {
    set entete [pageEntete]
    foreach fichier $tmpfic {
        set f [open $fichier r]
        fconfigure $f -translation binary
        set contenu [read -nonewline $f]
        close $f
        set f [open $fichier w]
        fconfigure $f -translation binary
        puts $f $entete
        puts $f $contenu
        close $f
    }
}

# puts stderr "tmpfic=\"$tmpfic\""
exec $LS -lrt $tmp

if {$tmpfic == {}} {
    exit 1
}

if {$WAITEND} {
    eval exec $imprimeAndDelete -waitend $imprimante $tmpfic
} else {
    eval exec $imprimeAndDelete $imprimante $tmpfic >& /dev/null &
}

exit 0

