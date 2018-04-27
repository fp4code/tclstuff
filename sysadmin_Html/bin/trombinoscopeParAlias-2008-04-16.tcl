#!/bin/sh
#\
exec tclsh "$0" ${1+"$@"}

# 19 d�cembre 2002 (FP)
# 23 d�cembre 2002 (FP)
# 19 juin 2003 (FP) changement de DYNAMIC et test de l'ex�cution sur soda,
#                   passage du source en utf-8, codage des fichiers en iso8859-1
# 1-2 juillet 2003 (FP) tdom
# 2007-10-23 (FP) d�tection des orphelins
# 2008-02-18 prise en compte de ceux qui n'ont pas de login

package require tdom 0.7.7
package require fidev
package require fidev_xh 0.1                
  
if {[info hostname] != "soda.lpn.prive"} {
    puts stderr "Doit �tre ex�cut� sur soda.lpn.prive et non sur [info hostname]."
    exit 1
}

set BASE  /local/www/html/p10admin/
set DYNAMIC   Lpn/dynamic
set DATABASES Lpn/databases
set CHANGER /Lpn/donneTaPhoto.html

package require fidev
package require fichUtils 0.2

proc readLines {file} {
    global BASE DATABASES FICHIERS
    set fifi [file join $BASE $DATABASES $file]
    lappend FICHIERS $file
    set f [open $fifi r]
    set lines [read -nonewline $f]
    close $f
    set ret [list]
    foreach l [split $lines \n] {
        if {![regexp "^\#" $l] && ![regexp {^[\t ]*$} $l]} {
            lappend ret $l
        }
    }
    return $ret
}

set SCRIPT [file join [pwd] [info script]]
while {[file type $SCRIPT] == "link"} {
    set SCRIPT [file readlink $SCRIPT]
}

foreach l [readLines login] {
    set login [lindex $l 0]
    set name [lrange $l 3 end]
    set NAME($login) $name
}

foreach l [readLines alias_login] {
    set login [lindex $l 0]
    set regular [lindex $l 1]
    set aliases [lindex $l 2]
    set REGULAR($login) $regular
    set ALIASES($login) $aliases
}

foreach l [readLines alias_lpn-foobar] {
    set alias [lindex $l 0]
    set regulars [lindex $l 1]
    set REGULARS($alias) $regulars
}

foreach l [readLines piece_et_phone] {
    if {[llength $l] % 2 != 1} {
        return -code error "erreur dans piece_et_phone, ligne \"$l\""
    }
    set PIETE([lindex $l 0]) [lrange $l 1 end]
}

foreach login [array names NAME] {
    if {[info exists REGULAR($login)]} {
        set LOGIN($REGULAR($login)) $login
    } else {
        puts stderr "No regular alias for $login ($NAME($login))"
    }
}

set INFO {
    NAME      login -> "Prenom Nom"
    LOGIN     Prenom.Nom -> login
    REGULAR   login      -> Prenom.Nom
    ALIASES   login      -> lpn...
    REGULARS  lpn-foobar -> "Prenom1.Nom1 Prenom2.Nom2 ..."
}

parray REGULARS

proc anl {sName string} {
    upvar $sName s
    append s $string\n
}

proc a {sName string} {
    upvar $sName s
    append s $string
}

proc printNames {} {
    global REGULAR
    set allNames ""
    set largest 0
    foreach login [array names REGULAR] {
        lappend allNames $REGULAR($login)
        set longueur [string length $REGULAR($login)]
        if {$longueur > $largest} {
            set largest $longueur
        }
    }
    incr largest
    foreach aa [lsort $allNames] {
        # puts [format %-${largest}s $aa]
    }
}

printNames

catch {unset CLIC_A_FAIRE}

proc avertissement {body} { 
    set ts [xh::Es $body {
	table {border 0 cellspacing 0 align center summary "cr�ation" width 95%}
	tbody {}
	tr {}
	td {rowspan 1 colspan 1 class address-page-signature}
    }]

    set instant [clock seconds]
    xh::E $ts br



    xh::T $ts "Ce trombinoscope est construit �pisodiquement � partir de la base de donn�e des alias de courriel."
    xh::T $ts "S'il est incorrect, consultez le "
    xh::ET $ts a [list href http://arclight.lpn.prive/html/soda/alias-courriel.txt] "fichier de r�f�rence. "
    xh::T $ts "Si ce fichier n'est pas � jour, pr�venez "
    xh::ET $ts a [list href mailto:lwb@lpn.cnrs.fr] LWB
    xh::T $ts ". S'il est � jour, demandez la reconstruction du trombinoscope � "
    xh::ET $ts a [list href mailto:fabrice.pardo@lpn.cnrs.fr] FP
    xh::T $ts ". Il est possible de "
    xh::ET $ts a [list href $::CHANGER] changer
    xh::T $ts " sa photo."

    xh::E $ts br
    xh::E $ts br
    xh::T $ts "Cr�� le [clock format $instant -format %Y-%m-%d] � [clock format $instant -format %H:%M:%S] par"
    xh::ET [xh::E $ts ul {}] li {class file-list} "[info hostname]:$::SCRIPT"
    xh::T $ts " � partir des fichiers (Cf. le "
    xh::ET $ts a [list href http://satiric.lpn.prive/wiki/index.php/Informatique/Trombinoscope] "wiki de proc�dure"
    xh::T $ts ")"
    set ul [xh::E $ts ul]
    foreach f $::FICHIERS {
	xh::ET [xh::E $ul li {class file-list}] a [list href /$::DATABASES/$f class file-list] "$f"
    }
}

proc create_html {html filename} {
    set fifi [file join $::BASE $::DYNAMIC $filename]
    xh::toFile $html $fifi
    unset html
    puts stderr "\nxh::tidy $fifi"
    xh::tidy $fifi

} 


foreach login [array names REGULAR] {
    set regular $REGULAR($login)
    if {![info exists NAME($login)]} continue
    set name $NAME($login)
    set html [xh::new]
    xh::C $html "== automatically generated by [::fidev::fichUtils::followLinks $SCRIPT] =="
    set head [xh::E $html head]
    set body [xh::E $html body {class body-sheet}]
    xh::E $head meta {http-equiv "content-type" content "text/html; charset=ISO-8859-1"}
#    xh::E $head link {type text/css href /css/ibm_v13r1.css rel stylesheet}
    xh::E $head link {type text/css href /css/phydis_styles.css rel stylesheet}
    xh::ET $head title {} $NAME($login)
       
    set btsb [xh::Es $body {
	table {border 0 cellspacing 0 class table-sheet-border cellpadding 1 width 95% align center summary "table-sheet-border"}
	tbody {}
	tr {}
	td {rowspan 1 colspan 1}
    }]
    set 2cols0 [xh::E $btsb table {border 0 cellspacing 0 cellpadding 5 width 100% summary "deux colonnes"}]
    set tr [xh::E $2cols0 tr]
    set tdg [xh::E $tr td {valign top class td-sheet}]
    set tdd [xh::E $tr td {valign middle width 100% class td-sheet}]
    unset tr
    
    if {[file exists [file join $BASE $DATABASES trombines $regular.gif]]} {
        set image "../databases/trombines/$regular.gif"
        set clic 0
    } else {
        set image "../databases/trombines/clic.gif"
        set clic 1
	set CLIC_A_FAIRE($regular) {}
    }
    if {$clic} {
	set node [xh::E $tdg a {href "../donneTaPhoto.html"}]
    } else {
	set node $tdg
    }
    xh::E $node img [list src $image align middle border 0 ALT $name]

    set 2cols [xh::E $tdd table {border 0 summary "coordonn�es de $name"}]
    
    set tr [xh::E $2cols0 tr]
    xh::ET $tr td {colspan 1 valign top align center class td-sheet} $name
    xh::E $tr td {class td-sheet}

    set tr [xh::E $2cols tr]    
    set tkey [xh::E $tr td]
    set tvalue [xh::E $tr td]
    xh::T $tkey email
    xh::ET $tvalue a [list href "mailto:${regular}@Lpn.cnrs.fr" class personne] "${regular}@Lpn.cnrs.fr"

    set tr [xh::E $2cols tr]    
    set tkey [xh::E $tr td]
    set tvalue [xh::E $tr td]
    xh::T    $tkey  "alias"
    set first 1
    set lpnas [list]
    set autres [list]
    foreach ali $ALIASES($login) {
	if {[info exists REGULARS($ali)]} {
            lappend lpnas $ali
        } else {
            lappend autres $ali
        }
    }
    foreach ali [lsort $lpnas] {
        if {$first} {
            set first 0
        } else {
 	    xh::T $tvalue ", "
       }
	xh::ET $tvalue a [list href "trombines_${ali}.html" class personne] $ali
    }
    foreach ali [lsort $autres] {
        if {$first} {
            set first 0
        } else {
	    xh::T $tvalue ", "
        }
	xh::ET $tvalue a [list href "aliases.html\#${ali}" class personne] $ali
    }

    set tr [xh::E $2cols tr]    
    set tkey [xh::E $tr td]
    set tvalue [xh::E $tr td]
    xh::T $tkey "pi�ce (t�l.)"
    if {[info exists PIETE($regular)]} {
        set first 1
        foreach {p t} $PIETE($regular) {
            if {$first} {
                set first 0
            } else {
		xh::T $tvalue ", "
            }
            xh::T $tvalue " ${p} \(${t}\)"
        }
    } else {
        puts stderr "Pas de pi�ce/t�l. pour $regular"
    }


    set tr [xh::E $2cols tr]    
    set tkey [xh::E $tr td]
    set tvalue [xh::E $tr td]
    xh::T $tkey login
    xh::T $tvalue $login
    
    avertissement $body
    create_html $html $regular.html
}


foreach alias [array names REGULARS] {
    set html [xh::new]
    xh::C $html "== automatically generated by [::fidev::fichUtils::followLinks $SCRIPT] =="
    set head [xh::E $html head]
    set body [xh::E $html body {class body-sheet}]
    xh::E $head meta {http-equiv "content-type" content "text/html; charset=ISO-8859-1"}
#    xh::E $head link {type text/css href /css/barre_section-fill.css rel stylesheet}
#    xh::E $head link {type text/css href /css/barre_styles.css rel stylesheet}
    xh::E $head link {type text/css href /css/phydis_styles.css rel stylesheet}
    xh::ET $head title {} $alias

    xh::E $body a {name top id top shape rect}
    xh::E $body br

    ############ ##### deux colonnes ###

    set btsb [xh::Es $body {
	table {border 0 cellspacing 0 class table-sheet-border cellpadding 1 width 95% align center summary "table-sheet-border"}
	tbody {}
	tr {}
	td {rowspan 1 colspan 1}
    }]
    set 2cols [xh::E $btsb table {border 0 cellspacing 0 cellpadding 2 width 100% summary "deux colonnes"}]

    set tr0 [xh::E $2cols tr]
#    set tdlogo [xh::E $tr0 td {rowspan 2 align left valign top cellpadding 0 border 0 class td-fond-logo}]
    set tdlogo [xh::E $tr0 td {rowspan 2 align left valign top class td-fond-logo}]
#    set tdtitre [xh::E $tr0 td {cellpadding 0 border 0 class td-fond-logo}]
    set tdtitre [xh::E $tr0 td {class td-fond-logo}]
    set trchoix [xh::E $2cols tr]
    set tdchoix [xh::E $trchoix td {class td-nav-bar height 21}]

#    set a [xh::E $tdlogo a {href http://www.cnrs.fr}]
#    xh::E $a img [list src /i/symbCNRSmed.gif alt "Logo du LPN" border no]    
    set a [xh::E $tdlogo a {href http://www.lpn.cnrs.fr}]
    xh::E $a img [list src /i/logo_lpn57transp.gif alt "Logo du CNRS" border no]    
#    xh::ET $a span {} "INTRANET"

    set mainlink mainlink ;# ibm
    set highlight highlight ;# ibm

    set mainlink a-nav-bar
    set highlight a-nav-bar-current

    xh::T $tdchoix "\u00a0"
    xh::ET $tdchoix a [list href http://www.cnrs.fr class $mainlink] CNRS
    xh::ET $tdchoix span {class divider} "\u00a0\u00a0|\u00a0\u00a0"
    xh::ET $tdchoix a [list href http://www.lpn.cnrs.fr class $mainlink] LPN
    xh::ET $tdchoix span {class divider}  "\u00a0\u00a0|\u00a0\u00a0"
    xh::ET $tdchoix a [list href http://www.lpn.prive class $mainlink] Intranet
    xh::ET $tdchoix span {class divider}  "\u00a0\u00a0|\u00a0\u00a0"
    xh::ET $tdchoix a [list href http://soda.lpn.prive class $highlight] Phydis
    xh::ET $tdchoix span {class divider}  "\u00a0\u00a0|\u00a0\u00a0"
    xh::ET $tdchoix a [list href http://www.google.com class $mainlink] Google 
    
    set tr [xh::E $2cols tr]
    set tdg [xh::E $tr td {valign top class td-sheet}]
    set tdd [xh::E $tr td {valign top width 100% class td-sheet}]
    unset tr 2cols
    
    ######################## colonne de gauche ###
    
#    set table [xh::E $tdg table {border 0 cellspacing 0 cellpadding 0 cols 1 width "91" summary "colonne de gauche"}]
    set table [xh::E $tdg table {border 0 cellspacing 0 cellpadding 0 width "91" summary "colonne de gauche"}]
    xh::ET [xh::E [xh::E $table tr] td {class uslnavplain}] b {} "Autres alias"
#    xh::E $td img {src "images/site_navig_haut.jpg" height 28 width 91 ALT "alias :"}
    foreach aliasbis [lsort [array names REGULARS]] {
	set tr [xh::E $table tr]
	set td [xh::E $tr td]
        if {$alias == $aliasbis} {
            xh::ET $td span {class uslnav-this} $aliasbis
        } else {
	    xh::ET $td a [list class uslnav href "trombines_${aliasbis}.html"] $aliasbis
        }
	unset td tr
    }

    xh::ET [xh::E $tdtitre center] b {} "Alias $alias"

    ######################## colonne de droite ###
    
    set table [xh::E $tdd table [list width 100% border 0 cellpadding 2 cellspacing 2 summary "Trombines de l'alias $alias"]]
    
    set ic 0
    
#    set tr0 [xh::E $table tr {height 49%}]
#    set tr1 [xh::E $table tr {height 20%}]
    set tr0 [xh::E $table tr {}]
    set tr1 [xh::E $table tr {}]
    
    foreach regular $REGULARS($alias) {
	if {![info exists LOGIN($regular)]} {
	    puts stderr "No login for $regular"
	    set name "$regular (no LDAP)"
	} else {
            set name $NAME($LOGIN($regular))
        }
        if {[file exists [file join $BASE $DATABASES trombines $regular.gif]]} {
            set image "../databases/trombines/$regular.gif"
            set clic 0
        } else {
            set image "../databases/trombines/clic.gif"
            set clic 1
        }
        if {$ic > 4} {
            set ic 0
#	    set tr0 [xh::E $table tr {height 49%}]
#	    set tr1 [xh::E $table tr {height 20%}]
	    set tr0 [xh::E $table tr {}]
	    set tr1 [xh::E $table tr {}]
        }
	set td [xh::E $tr0 td {width "20%" height "49%" valign "middle" align "center"}]
	set div [xh::E $td div {align "center"}]
        if {$clic} {
	    set node [xh::E $div a {href "../donneTaPhoto.html"}]
        } else {
	    set node [xh::E $div a [list href ${regular}.html]]
	}
	xh::E $node img [list src $image align middle border 0 alt $name]
	unset node div td
	set td [xh::E $tr1 td {width "20%" height "17%" align "center" valign "middle"}]
	xh::ET $td a [list href ${regular}.html class personne] $name
        incr ic
    }
    
#    xh::E $tdd hr

    avertissement $body
    create_html $html trombines_$alias.html
}

catch {unset stagiaires}
foreach r $REGULARS(lpn-stagiaires) {
    set stagiaires($r) {}
}

set clics [list]
set clics_stagiaires [list]
foreach r $REGULARS(lpn-tous) {
    if {[info exists CLIC_A_FAIRE($r)]} {
	if {[info exists stagiaires($r)]} {
	    lappend clics_stagiaires $r
	} else {
	    lappend clics $r
	}
    }
}
set parNoms_stagiaires [list]
set maxNom_stagiaires 0

puts "\n Sans photo, par pr�nom (stagiaires)"
foreach clic [lsort $clics_stagiaires] {
    puts $clic
    set np [split $clic .]
    if {[llength $np] != 2} {
	return -code error "Alias \"$clic\" incorrect"
    }
    set n [lindex $np 1]
    set p [lindex $np 0]
    set ln [string length $n]
    if {$ln > $maxNom_stagiaires} {
	set maxNom_stagiaires $ln
    }
    lappend parNoms_stagiaires [list $n $p]
}
set parNoms [list]
set maxNom 0
puts "\n Sans photo, par pr�nom (sauf stagiaires)"
foreach clic [lsort $clics] {
    puts $clic
    set np [split $clic .]
    if {[llength $np] != 2} {
	return -code error "Alias \"$clic\" incorrect"
    }
    set n [lindex $np 1]
    set p [lindex $np 0]
    set ln [string length $n]
    if {$ln > $maxNom} {
	set maxNom $ln
    }
    lappend parNoms [list $n $p]
}

puts "\n Sans photo, par nom ${maxNom_stagiaires} (stagiaires)"
foreach np [lsort $parNoms_stagiaires] {
    set n [lindex $np 0]
    set p [lindex $np 1]
    puts [format "%-${maxNom_stagiaires}s %s" $n $p]
}
puts "\n Sans photo, par nom ${maxNom} (sauf stagiaires)"
foreach np [lsort $parNoms] {
    set n [lindex $np 0]
    set p [lindex $np 1]
    puts [format "%-${maxNom}s %s" $n $p]
}

puts "\n Calcul des orphelins"
foreach login [array names REGULAR] {
    set regular $REGULAR($login)
    set ORPHAN($login) $regular
}
foreach regular $REGULARS(lpn-tous) {
    if {![info exists LOGIN($regular)]} {
	puts stderr "No login for $regular"
	continue
    }
    set login $LOGIN($regular)
    if {![info exists ORPHAN($login)]} {
	puts stderr "Special $login"
	continue
    }
    unset ORPHAN($login)
}
puts stderr "Orphelins = \"[lsort [array names ORPHAN]]\""


