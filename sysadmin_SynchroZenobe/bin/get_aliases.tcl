#!/bin/sh
# \
exec tclsh "$0" ${1+"$@@"}

# 28 janvier 2002 (FP) get_aliases.0.2.tcl
# 19 décembre 2002 (FP) Crée le fichier $P10/A/html/Lpn/databases/aliases
# et $P10/A/html/Lpn/databases/logins
# Il faudrait scinder en deux programmes
# 8 janvier 2003 (FP) changement des liens personnels
# 19 juin 2003 (FP) changement de DYNAMIC et test de l'exécution sur soda, passage du source en utf-8, codage des fichiers en iso8859-1
# 2 juillet 2003 (FP) rajout de AUTRES_ALIAS
# 2004-10-25 (FP) modif /etc/aliases -> /etc/mail/aliases (les administrateurs ont cassé le lien)
# 2006-01-31 (FP) zenobe est supprimé
# 2006-12-01 (FP) ajout de code_dur (si et sos-si sont en liste rouge !)
# 2007-10-11 (FP) suppression de rapac cnanoidf
# 2008-02-18 (FP) changement de si et sos-si -> lpn-si (si et sos-si sont en liste rouge !)
# 2008-04-21 (FP) suppression de si et sos-si                                                            
# 2008-04-21 (FP) construction de DATABASES/alicom
# 2008-09-16 (FP) passage à bob
# 2009-06-30 (FP) suppression de tous les projet-web... webmestre

if {[info hostname] != "bob.lpn.prive"} {
    puts stderr "Doit être exécuté sur bob.lpn.prive et non sur [info hostname]."
    exit 1
}

proc code_dur {&l} {
    upvar ${&l} l
#    lappend l "si :\tEric.Lecompte,\tLorenzo.Bernardi,\tOlivier.Oria,\tRoland.You"
#    lappend l "sos-si :\tEric.Lecompte,\tLorenzo.Bernardi,\tOlivier.Oria,\tRoland.You"
}

set AUTRES_ALIAS {jug helium contact centrale-techno seminaires lepetitnouveau salsa}

set DYNAMIC /local/www/html/p10admin/Lpn/dynamic/
set HTML ${DYNAMIC}/aliases.html
set DATABASES /local/www/html/p10admin/Lpn/databases
set TROMBINOSCOPE [file join $DATABASES trombines]
set SSH_LOGIN_SLEEP 0.1
set PERIOD [expr {60*60*1000}]
set TMPFICH /tmp/md5sum
# set MD5SUM /home/p10admin/binSparcSolaris/md5sum
set MD5SUM md5sum

set SCRIPT [file join [pwd] [info script]]
while {[file type $SCRIPT] == "link"} {
    set SCRIPT [file readlink $SCRIPT]
}


proc tclclockstamp {} {
    global SCRIPT
    set instant [clock seconds]
    return "\# créé automatiquement le [clock format $instant -format "%Y/%m/%d"] à [clock format $instant -format "%H:%M:%S"] par $SCRIPT"
}

proc creeDatabaseLogin {lines} {
    global DATABASES

    set newLines [list]
    foreach l $lines {
        set l [split $l :]
	puts stdout [list [lindex $l 0]  [lindex $l 2]  [lindex $l 3] [lindex $l 4]]
        lappend newLines [format "%-8s %6d %6d %s" [lindex $l 0]  [lindex $l 2]  [lindex $l 3] [lindex $l 4]]
    }
    set newLines [lsort $newLines]


    if {[catch {
        set f [open $DATABASES/login w]
	fconfigure $f -encoding iso8859-1
        puts $f [tclclockstamp]
        foreach l $newLines {puts $f $l}
        close $f
    } blabla]} {
        puts stdout "ERROR creeDatabaseLogin : $blabla"
    }

}

proc readFile name {
    set f [open $name r]
    set s [read -nonewline $f]
    close $f
    return [split $s \n]
}

proc getAliases {} {

    global HTML DATABASES PERIOD

    set instant [clock seconds]
        
    set passwd [readFile ~fab/Z/passwd]
    set listes [readFile ~fab/Z/alias-courriel.txt]
    
    creeDatabaseLogin $passwd
#    creeDatabaseAliases $listes $logins
    
    set ERRORS [list]
    set a1o [aliases_1 $listes]
puts "\na1o"
foreach e $a1o {puts $e}



    code_dur a1o
puts "\na1o after dur"
foreach e $a1o {puts $e}
    aliases_2 $a1o ALIAS REGULAR ERRORS

puts stdout "ERRORS = $ERRORS"
# 
parray ALIAS
parray REGULAR

    aliases_calculeInverses ALIAS INVERSES REGULAR ERRORS

puts stdout "ERRORS = $ERRORS"
parray INVERSES

    set ret [aliases_feuilles ALIAS INVERSES]


    set feuilles [lindex $ret 0]
    set feuillesMultibranches [lindex $ret 1]
    set brindilles [lindex $ret 2]
    
puts stdout "feuilles = $feuilles"
puts stdout "feuillesMultibranches = $feuillesMultibranches"
puts stdout "brindilles = $brindilles"

    aliases_longConnect_1 $feuilles INVERSES LONGCONNECT ERRORS

puts stdout "ERRORS = $ERRORS"
parray LONGCONNECT

    aliases_longConnect_2 INVERSES LONGCONNECT LONGALIAS LONGINVERSE    
    
puts stdout "longConnect"

    parray LONGALIAS

    set goodBrindilles [list]
    foreach b $brindilles {
	if {[string match *.* $b]} {
	    lappend goodBrindilles $b
	}
    }

puts stdout "goodBrindilles"
    
    set html [aliases_html $instant ERRORS ALIAS LONGALIAS LONGINVERSE REGULAR $listes $goodBrindilles]

puts stdout "aliases_html"

    set f [open $HTML w]
    fconfigure $f -encoding iso8859-1
    puts -nonewline $f $html
    close $f
}

set INFO(aliases_1) {
    retourne une liste, un alias par élément
}

proc aliases_1 {list_listes} {
    set alicom [open $::DATABASES/alias_comment w]
    fconfigure $alicom -encoding iso8859-1
    puts $alicom [tclclockstamp]


    set il 0
    set aliases [list]
    set alias {}
    set list_of_lines $list_listes
    foreach l $list_of_lines {
        incr il
        set firstChar [string index $l 0]
        if {$firstChar == "#"} {
	    if {[regexp {^#desc:[ 	]*([^ 	]*.+[^ 	]*)[ 	]*=[ 	]*([^ 	]*.+[^ 	]*)[ 	]*$} $l tout aa cc]} {
		puts $alicom "[string tolower $aa] = $cc"
	    } else {
		continue
	    }
	}
        if {$firstChar == " " || $firstChar == "\t"} {
            append alias $l
        } else {
            lappend aliases $alias
            set alias $l
        }
    }
    puts stdout "BEGIN\n$aliases\nEND"
    close $alicom
    return $aliases
}

set INFO(aliases_2) {
    remplit le tableau des alias ALIAS(left) = right, ...
    left est toujours en minuscules
    on retrouve l'écriture originale dans regularName($left)
}

proc aliases_2 {lines &ALIAS &REGULAR &ERRORS} {
    upvar ${&ALIAS} ALIAS
    upvar ${&REGULAR} REGULAR
    upvar ${&ERRORS} ERRORS

    if {[info exists ALIAS]} {
        unset ALIAS
    }
    if {[info exists REGULAR]} {
        unset REGULAR
    }
    foreach l $lines {
        if {$l == {}} continue
        set l [split $l :]
        if {[llength $l] != 2} {
            lappend ERRORS "Error alias \"$l\""
            continue
        }
        set leftOrig [string trim [lindex $l 0]]
        set left [string tolower $leftOrig] 
        if {[info exists REGULAR($left)] && $REGULAR($left) != $leftOrig} {
            lappend ERRORS "Alias identique écrit $REGULAR($left) et $leftOrig"
        }
        set REGULAR($left) $leftOrig
        set rightList [split [lindex $l 1] ,]
        set right [list]
        foreach r $rightList {
            set r [string trim $r]
            if {$r == {}} {
                lappend ERRORS "Error un alias vide pour \"$l\""
            } else {
                lappend right $r
            }
        }
        if {[llength $right] == 0} {
            lappend ERRORS "aliases_2 : Pas d'alias pour \"$l\""
        } else {
            if {$left == {}} {
                lappend ERRORS "alias vide pour:[join $right ,]"
                continue
            }
            if {[info exists ALIAS($left)]} {
                lappend ERRORS "alias écrasé $left:[join $right ,]"
            }
            set ALIAS($left) $right
        }
    }
    return $ERRORS
}

set INFO(aliases_calculeInverses) {
    calcule le tableau inverse
    tout est en minuscules
}


#                             ALIAS          INVERSES         REGULAR     ERRORS        
proc aliases_calculeInverses {aliasArrayName inverseArrayName regularName errorsName} {
    upvar $aliasArrayName aliasArray
    upvar $inverseArrayName inverseArray
    upvar $regularName regular
    upvar $errorsName errors

    if {[info exists inverseArray]} {
        unset inverseArray
    }
    foreach left [array names aliasArray] {
	puts stdout "left = $left, rightOrig = $aliasArray($left)"
        foreach rightOrig $aliasArray($left) {
            set right [string tolower $rightOrig]
            if {![info exists regular($right)]} {
		puts stdout "no regular($right)"
		puts stdout "aliasArray($left) = $aliasArray($left)"
                if {[llength $aliasArray($left)] != 1} {
                    lappend errors "aliases_calculeInverses : Pas d'alias pour \"$rightOrig\""
                } else {
                    set regular($right) $rightOrig
                }
            }
            lappend inverseArray($right) $left
        }
    }
} 

proc aliases_feuilles {aliasArrayName inverseArrayName} {
    upvar $aliasArrayName aliasArray
    upvar $inverseArrayName inverseArray
    set  good_feuilles [list]
    set bad_feuilles [list]
    set brindilles [list]
    
    foreach right [array names inverseArray] {
        if {![info exists aliasArray($right)]} {
            lappend feuilles $right
        }
    }
    foreach feuille $feuilles {
        if {[llength $inverseArray($feuille)] != 1} {
            lappend bad_feuilles $feuille
        } else {
            lappend good_feuilles $feuille
            lappend brindilles $inverseArray($feuille)
        }
    }
    return [list $good_feuilles $bad_feuilles $brindilles]
}

proc aliases_longConnect_1 {feuilles inverseArrayName longConnectName errorsName} {
    upvar $inverseArrayName inverseArray
    upvar $longConnectName longConnect
    upvar $errorsName errors

    if {[info exists longConnect]} {
        unset longConnect
    }
    
    foreach feuille $feuilles {
        aliases_longConnect_recurs $feuille [string tolower $inverseArray($feuille)] inverseArray longConnect errors
    }
    return $errors
}

proc aliases_longConnect_recurs {feuille noeud inverseArrayName longConnectName errorsName} {
    upvar $inverseArrayName inverseArray
    upvar $longConnectName longConnect
    upvar $errorsName errors

    if {![info exists inverseArray($noeud)]} {
	puts stdout "exists $inverseArrayName\($noeud\)"
	return
    }
    foreach left $inverseArray($noeud) {
        set left [string tolower $left]
        if {![string compare -nocase $left $noeud]} {
            lappend errors "bouclage circulaire avec \"$feuille\""
        } else {
            if {[info exists longConnect($left:$feuille)]} {
                incr longConnect($left:$feuille)
            } else {
                set longConnect($left:$feuille) 1
            }
            aliases_longConnect_recurs $feuille $left inverseArray longConnect errors
        }
    }
}

proc aliases_longConnect_2 {inverseArrayName longConnectName longAliasName longInverseName} {
    upvar $inverseArrayName inverseArray
    upvar $longConnectName longConnect
    upvar $longAliasName longAlias
    upvar $longInverseName longInverse

    if {[info exists longAlias]} {
        unset longAlias
    }
    if {[info exists longInverse]} {
        unset longInverse
    }
    
    foreach c [array names longConnect] {
        set c [split $c :]
        set left [lindex $c 0]
        set right $inverseArray([lindex $c 1])
        lappend longAlias($left) $right
        lappend longInverse($right) $left
    }

    foreach left [array names longAlias] {
        set longAlias($left) [lsort $longAlias($left)]
    }
    foreach right [array names longInverse] {
        set longInverse($right) [lsort $longInverse($right)]
    }
}


proc append+nl {sName string} {
    upvar $sName s
    append s $string\n
}

proc aliases_html {instant &ERRORS &ALIAS &LONGALIAS &LONGINVERSE &REGULAR original brindilles} {
    upvar ${&ERRORS} ERRORS
    upvar ${&ALIAS} ALIAS
    upvar ${&LONGALIAS} LONGALIAS
    upvar ${&LONGINVERSE} LONGINVERSE
    upvar ${&REGULAR} REGULAR
    global TROMBINOSCOPE DATABASES DYNAMIC AUTRES_ALIAS

    set html {}
    append html {<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">}
    append+nl html {<html>}
    append+nl html {<head>}
    append+nl html {  <meta http-equiv="content-type" content="text/html; charset=ISO-8859-1">}
    append+nl html {  <title>Alias courriel lpn.cnrs.fr</title>}
    append+nl html {</head>}
    append+nl html {<body>}

    append+nl html {<hr width="100%" size="2" align="Left">}

    append+nl html {<div align="Center"><h2>Alias courriel lpn.cnrs.fr<h2></div>}

    append+nl html {<hr width="100%" size="2" align="Left"><br>}

    append+nl html {<table cellpadding="2" cellspacing="2" border="1" width="100%">}
    append+nl html {  <tbody>}
    append+nl html {    <tr>}
    append+nl html {      <td valign="Top" align="Center">Prenom.Nom<br>+ fiche personnelle}
    append+nl html {      </td>}
    append+nl html {      <td valign="Top" align="Center">login<br>}
    append+nl html {      </td>}
    append+nl html {      <td valign="Top" align="Center">liste des alias}
    append+nl html {      </td>}
    append+nl html {    </tr>}

    
    set alias_login [open [file join $DATABASES alias_login] w]
    fconfigure $alias_login -encoding iso8859-1
    puts $alias_login [tclclockstamp]
    foreach right [lsort $brindilles] {
        if {[info exists LONGINVERSE($right)]} {
            set longinverse $LONGINVERSE($right)
        } else {
            set longinverse {}
        }
            puts $alias_login [list $ALIAS($right) $REGULAR($right) $longinverse]
    }
    close $alias_login

    set alias_lpn-foobar [open [file join $DATABASES alias_lpn-foobar] w]
    fconfigure ${alias_lpn-foobar} -encoding iso8859-1
    puts ${alias_lpn-foobar} [tclclockstamp]
    set conserves [list]
    foreach left [lsort [array names LONGALIAS]] {
        if {[string match lpn-* $left] && [info exists LONGALIAS($left)]} {
	    lappend conserves $left
	}
    }
    set conserves [concat $conserves  $AUTRES_ALIAS]
    foreach left $conserves {
	set value [list]
	foreach right $LONGALIAS($left) {
	    lappend value $REGULAR($right)
	}
	puts ${alias_lpn-foobar} [list $left $value]
    }
    close ${alias_lpn-foobar}

#    foreach right [lsort [array names LONGINVERSE]] 
    foreach right [lsort $brindilles] {
        append+nl html {    <tr>}
        append+nl html {      <td valign="Top">}
        append html {<a name="}
        append html $REGULAR($right)
        append html {"></a>}
        set perso [file join $DYNAMIC $REGULAR($right).html]
        if {[file exists $perso]} {
            append html "<a href=\"$REGULAR($right).html\">"
            append html $REGULAR($right)
            append html {</a>}
        } else {
            append html $REGULAR($right)
        }
        append html {<br>}
        append+nl html {      </td>}
        append+nl html {      <td valign="Top">}
        set first 1
        append html $ALIAS($right)
        append html {<br>}
        append+nl html {      </td>}
        append+nl html {      <td valign="Top">}
        if {[info exists LONGINVERSE($right)]} {
            foreach left $LONGINVERSE($right) {
                if {$first} {
                    set first 0
                } else {
                    append html {, }
                }
                append html {<a href="#}
                append html $left
                append html {">}
                append html $REGULAR($left)
                append html {</a>}
            }
        }
        append+nl html {      </td>}
        append+nl html {    </tr>}
    }
    append+nl html {  </tbody>}
    append+nl html {</table>}
    
    append+nl html {<hr width="100%" size="2" align="Left">}
    append+nl html {Alias directs :<br>}
    append+nl html {<hr width="100%" size="1" align="Left">}


    append+nl html {<table cellpadding="2" cellspacing="2" border="1" width="100%">}
    append+nl html {  <tbody>}


    foreach left [lsort [array names LONGALIAS]] {
        append+nl html {    <tr>}
        append+nl html {      <td valign="Top">}
        append html {<a name="}
        append html $left
        append html {"></a>}        
        append html $REGULAR($left)
        append html {<br>}
        append+nl html {      </td>}
        append+nl html {      <td valign="Top">}

        foreach right $LONGALIAS($left) {
            append html {<a href="#}
            append html $REGULAR($right)
            append html {">}
            append html $REGULAR($right)
            append html {</a>}
            append html {<br>}
        }
        append+nl html {      </td>}
        append+nl html {</dl>}
    }

    append+nl html {  </tbody>}
    append+nl html {</table>}

    append+nl html {    <hr width="100%" size="2" align="Left">}
    append+nl html {Fichier Original smtp.lpn.cnrs.fr:/etc/mail/aliases<br>}
    append+nl html {    <hr width="100%" size="1" align="Left">}

    append+nl html {<pre>}
    foreach ligne $original {
        append+nl html "$ligne"
    }
    append+nl html {</pre>}
    append+nl html {<hr width="100%" size="2" align="Left"><br>}

    if {$ERRORS != {}} {
        append+nl html {Erreurs :}
        append+nl html {<ul>}
        foreach erreur $ERRORS {
            append+nl html "<li><i>$erreur</i></li>"
        }
        append+nl html {</ul>}
        append+nl html {<hr width="100%" size="2" align="Left">}
    }

    append+nl html "<i>Données extraites automatiquement le [clock format $instant -format "%Y/%m/%d"] à [clock format $instant -format "%H:%M:%S"]
 par le programme get_aliases sur [info hostname]"
    append+nl html { (<a href="mailto:Fabrice.Pardo@Lpn.cnrs.fr">fab</a>)</i>}
    append+nl html {<br>}
    append+nl html {<i>Pensez à recharger la page</i>}

    append+nl html {<hr width="100%" size="2" align="Left">}

    append+nl html {</body>}
    append+nl html {</html>}

    return $html
    
}


getAliases

