#!/bin/sh
# \
exec tclsh "$0" ${1+"$@"}

# 1999/12/21 (FP) gros nettoyage. Les imprimantes Apple sont abandonnées
# 2002/02/06 (FP) ajout de .ps au suffixe. L'imprimante imprime texto les fichier .txt !
# insuffisant en fait : il a.txt.b.ps est imprimé texto par la lexmark optra-S !

package require fidev
package require unix
package require fichUtils

set MP /usr/openwin/bin/mp
set LS /bin/ls
set WAITEND 0
set IMPRIMANTE(BatBL) lex-b1
set IMPRIMANTE(BatB) lex-b2
set IMPRIMANTE(BatC) lex-c1
set IMPRIMANTE(BatK) lex-k1
set IMPRIMANTE(lex-b1) lex-b1
set IMPRIMANTE(lex-b2) lex-b2
set IMPRIMANTE(lex-c1) lex-c1
set IMPRIMANTE(lex-k1) lex-k1

set LPFTP [::fidev::fichUtils::whereIsScript]/lpftp.tcl

# recherche de l'imprimante

set i [lsearch -glob $argv {-d*}]

if {$i < 0 && [info exists env(PRINTER)]} {
    set imprimante $env(PRINTER)
    set j $i
} elseif {$i < 0} {
# Nouveau : impression automatique sur l'imprimante la plus proche de l'écran
    set DISPLAY $env(DISPLAY)
    set dpts [string first ":" $DISPLAY]
    set MACHINE [string range $DISPLAY 0 [expr $dpts -1]]
    if {$MACHINE == ""} {
	set MACHINE [info hostname]
    }
    set ip [lindex [lindex [::unix::gethostbyname $MACHINE] 2] 0]
    if {![regexp {([0-9]+\.[0-9]+\.[0-9]+\.)([0-9]+)} $ip tout debut fin]} {
        error "adresse IP $ip illisible"
    }
set rien {
    if {$debut != "10.6.0."} {
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
}

    set imprimante BatK

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

set imprimante [string trim $imprimante]

# recherche des arguments et recherche des fichiers

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

# appel de ipp

set tmp /tmp/papif.$env(USER)
# cree les parents
if {[catch {file mkdir $tmp} err]} {
    puts stdout $err
}

proc formatte {source dest} {
    if [file exists /usr/openwin/bin/mp] {
	exec /usr/openwin/bin/mp -lo -s $source $source > $dest
    } elseif [file exists /usr/bin/enscript] {
	exec /usr/bin/enscript -p $dest --media=A4 $source
    }
}

proc spoule {args} {

    set tmp [lindex $args 0]
    set fichiers [lindex $args 1]

    set tmpfic [list]

    foreach f $fichiers {
        if {![file readable $f]} {
            puts "Fichier $f : non lisible"
	    continue
	}
	    
	set fifi [open $f r]
	set magic [read $fifi 2]
	close $fifi

	if {$magic == "%!"} { 
		lappend tmpfic 0 $f
	} elseif {([file size $f] <= 11000)} {
            set tmpf $tmp/[clock format [clock seconds] -format %Y.%m.%d.%H.%M.%S]:[file tail $f].ps
	    formatte $f $tmpf
	    lappend tmpfic 1 $tmpf
	} else {
	    global imprimante
	    puts stderr ""
	    puts stderr " ERREUR : Fichier $f : non PostScript et trop grand ou pour Lexmark"
	    puts stderr ""
	    puts stderr " EXPLICATIONS :"
	    puts stderr ""
	    puts stderr " - Dans le but d'éviter de gaspiller du papier,"
	    puts stderr "  le programme maison \"/usr/local/bin/lp\""
	    puts stderr "  ne convertit automatiquement en PostScript"
	    puts stderr "  que des fichiers texte de moins de 11000 caractères,"
	    puts stderr " - Si vous êtes sûr de vouloir imprimer ce fichier texte,"
	    puts stderr "  utilisez explicitement un programme de mise au format PostScript"
	    puts stderr " - exemple exécutable texto sur Sun :"
	    puts stderr "        mp -lo -s $f $f | lp -d $imprimante"
	    puts stderr ""
	}
    }
    return $tmpfic
}

proc spouleStdin {tmp} {

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
    return [list 1 $tmpfic]
}

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

puts "\$fichiers = $fichiers"

if {$fichiers != ""} {
    set tmpfic [spoule $tmp $fichiers]
} else {
    set tmpfic [spouleStdin $tmp]
}

puts stderr "tmpfic=\"$tmpfic\""
# exec $LS -lrt $tmp

if {$tmpfic == {}} {
    exit 1
}

if {![info exists IMPRIMANTE($imprimante)]} {
    puts stderr "pas d'imprimante \"$imprimante\""
    parray IMPRIMANTE
    exit 1
}

foreach {delete fichier} $tmpfic {
#    puts "exec $LPFTP  $IMPRIMANTE($imprimante) $fichier"
    exec $LPFTP $IMPRIMANTE($imprimante) $fichier >&@ stdout
    if {$delete == 1} {
	file delete $fichier
    }
}

exit 0

