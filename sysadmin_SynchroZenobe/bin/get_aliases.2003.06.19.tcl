#!/bin/sh
# \
exec expect "$0" ${1+"$@@"}

# 28 janvier 2002 (FP) get_aliases.0.2.tcl
# 19 décembre 2002 (FP) Crée le fichier $P10/A/html/Lpn/databases/aliases
# et $P10/A/html/Lpn/databases/logins
# Il faudrait scinder en deux programmes
# 8 janvier 2003 (FP) changement des liens personnels
# 19 juin 2003 (FP) changement de DYNAMIC et test de l'exécution sur soda, passage du source en utf-8, codage des fichiers en iso8859-1

if {[info hostname] != "soda.lpn.prive"} {
    puts stderr "Doit être exécuté sur soda.lpn.prive et non sur [info hostname]."
    exit 1
}

set SMTP smtp
set DYNAMIC /var/www/html/p10admin/Lpn/dynamic/
set HTML ${DYNAMIC}/aliases.html
set DATABASES /var/www/html/p10admin/Lpn/databases
set TROMBINOSCOPE [file join $DATABASES trombines]
set TELNET_LOGIN_SLEEP 0.1
set PERIOD [expr {60*60*1000}]
set TMPFICH /tmp/md5sum
# set MD5SUM /home/p10admin/binSparcSolaris/md5sum
set MD5SUM md5sum

set SCRIPT [file join [pwd] [info script]]
while {[file type $SCRIPT] == "link"} {
    set SCRIPT [file readlink $SCRIPT]
}


if {$argc == 1} {
    set lnp [split $argv /]
    set name [lindex $lnp 0]
    set passwd [lindex $lnp 1]
} else {
    exp_send_user "login on $SMTP: "
    expect_user -re "(.*)\n"
    set name $expect_out(1,string)
    exp_stty -echo
    exp_send_user "password($name on $SMTP): "
    expect_user -re "(.*)\n"
    exp_send_user "\n"
    set passwd $expect_out(1,string)
    exp_stty echo
}

proc tclclockstamp {} {
    global SCRIPT
    set instant [clock seconds]
    return "\# créé automatiquement le [clock format $instant -format "%Y/%m/%d"] à [clock format $instant -format "%H:%M:%S"] par $SCRIPT"
}

proc verifie {lines md5sum} {
    global MD5SUM TMPFICH name

    set fichier $TMPFICH.$name
    set f [open $fichier w]
    fconfigure $f -encoding iso8859-1
    foreach l $lines {
        puts $f $l
    }
    close $f

    set rep [exec $MD5SUM $fichier]
    file delete $fichier

    if {[lindex $rep 0] != [lindex $md5sum 0]} {
        return 1
    } else {
        return 0
    }
}

proc getByTelnet {} {
    global SMTP DYNAMIC HTML TELNET_LOGIN_SLEEP TMPFICH MD5SUM
    # mieux en global en cas de plantage (pour ne pas montrer le passwd dans la pile)
    global name passwd 

    exp_spawn telnet $SMTP

    expect {
        -re "login: " {
            exp_sleep $TELNET_LOGIN_SLEEP ;# indispensable !?
            exp_send $name\r
        }
        timeout {
            puts stderr {No Login Prompt !}
            return {}
        }
    }
    
    expect {
        -re "Password: " {
            exp_sleep $TELNET_LOGIN_SLEEP ;# indispensable !?
            exp_send $passwd\r
        }
        timeout {
            puts stderr {No Password Prompt !}
            return {}
        }
    }

    expect {
        -re {(|$%) } {
            exp_send "stty raw; echo BEGIN.BEGIN.BEGIN; md5sum /etc/aliases; md5sum /etc/passwd; cat /etc/aliases; echo NEXT.NEXT.NEXT; cat /etc/passwd; echo END.END.END\r"
        }
        timeout {
            puts stderr {No \"\$\ " or \"%\ " Prompt !}
            return {}
        }
    }

    expect {
        -gl "END.END.END\r\n" {
        }
        timeout {
            puts stderr {No END.END.END !}
            return {}
        }
    }

    expect {
        -gl "BEGIN.BEGIN.BEGIN\n" {
        }
        timeout {
            puts stderr {No BEGIN.BEGIN.BEGIN !}
            return {}
        }
    }

    set reponseAliases [list]
    set reponsePasswd [list]
    set repFich reponseAliases

    expect {
        -re {([^\n]*)\n} {
            set ligne $expect_out(1,string)
            if {$ligne != "END.END.END"} {
                if {$ligne == "NEXT.NEXT.NEXT"} {
                    set repFich reponsePasswd
                } else {
                    lappend $repFich $ligne
                }
                exp_continue
            }
        }
        eof {set tout $expect_out(buffer)}
        timeout {
            puts stderr {Finit mal :}
            puts stderr expect_out(buffer)
            return {}
        }
    }

    exp_close
    exp_wait ;# indispensable pour ne pas avoir de <defunct>

    set md5sumAliases [lindex $reponseAliases 0]
    set md5sumPasswd [lindex $reponseAliases 1]
    set aliases [lrange $reponseAliases 2 end]
    set passwd $reponsePasswd

    if {[verifie $aliases $md5sumAliases] && [verifie $passwd $md5sumPasswd]} {
        puts stderr "Erreur de Transfert !"
        return {}
    }

    return [list $aliases $passwd]
}

proc creeDatabaseAliases {lines} {
    global DATABASES

    if {[catch {
        set f [open $DATABASES/aliases w]
	fconfigure $f -encoding iso8859-1
        puts $f $lines
        close $f
    } blabla]} {
        puts stderr "ERROR creeDatabaseAliases : $blabla"
    }
}

proc creeDatabaseLogin {lines} {
    global DATABASES

    set newLines [list]
    foreach l $lines {
        set l [split $l :]
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
        puts stderr "ERROR creeDatabaseLogin : $blabla"
    }

}

proc getAliases {} {

    global HTML DATABASES PERIOD

    set instant [clock seconds]
    set original [getByTelnet]

    if {$original == {}} {
        puts stderr ERREUR
    } else {
        
        set passwd [lindex $original 1]
        set original [lindex $original 0]

        creeDatabaseLogin $passwd
        creeDatabaseAliases $original

        set ERRORS [list]
        aliases_2 [aliases_1 $original] ALIAS REGULAR ERRORS
        aliases_calculeInverses ALIAS INVERSES REGULAR ERRORS
        set ret [aliases_feuilles ALIAS INVERSES]
        set feuilles [lindex $ret 0]
        set feuillesMultibranches [lindex $ret 1]
        set brindilles [lindex $ret 2]

        aliases_longConnect_1 $feuilles INVERSES LONGCONNECT ERRORS
        aliases_longConnect_2 INVERSES LONGCONNECT LONGALIAS LONGINVERSE    
        
        set goodBrindilles [list]
        foreach b $brindilles {
            if {[string match *.* $b]} {
                lappend goodBrindilles $b
            }
        }

        set html [aliases_html $instant ERRORS ALIAS LONGALIAS LONGINVERSE REGULAR $original $goodBrindilles]
        set f [open $HTML w]
	fconfigure $f -encoding iso8859-1
        puts -nonewline $f $html
        close $f
    }

    after $PERIOD getAliases

}

set INFO(aliases_1) {
    retourne une liste, un alias par élément
}

proc aliases_1 {lines} {
    set il 0
    set aliases [list]
    set alias {}
    foreach l $lines {
        incr il
        set firstChar [string index $l 0]
        if {$firstChar == "#"} continue
        if {$firstChar == " " || $firstChar == "\t"} {
            append alias $l
        } else {
            lappend aliases $alias
            set alias $l
        }
    }
    return $aliases
}

set INFO(aliases_2) {
    remplit le tableau des alias arrayName(left) = right, ...
    left est toujours en minuscules
    on retrouve l'écriture originale dans regularName($left)
}

proc aliases_2 {lines arrayName regularName errorsName} {
    upvar $arrayName array
    upvar $regularName regular
    upvar $errorsName errors

    if {[info exists array]} {
        unset array
    }
    if {[info exists regular]} {
        unset regular
    }
    foreach l $lines {
        if {$l == {}} continue
        set l [split $l :]
        if {[llength $l] != 2} {
            lappend errors "Error alias \"$l\""
            continue
        }
        set leftOrig [string trim [lindex $l 0]]
        set left [string tolower $leftOrig] 
        if {[info exists regular($left)] && $regular($left) != $leftOrig} {
            lappend errors "Alias identique écrit $regular($left) et $leftOrig"
        }
        set regular($left) $leftOrig
        set rightList [split [lindex $l 1] ,]
        set right [list]
        foreach r $rightList {
            set r [string trim $r]
            if {$r == {}} {
                lappend errors "Error un alias vide pour \"$l\""
            } else {
                lappend right $r
            }
        }
        if {[llength $right] == 0} {
            lappend errors "Pas d'alias pour \"$l\""
        } else {
            if {$left == {}} {
                lappend errors "alias vide pour:[split join $right ,]"
                continue
            }
            if {[info exists array($left)]} {
                lappend errors "alias écrasé $left:[split join $right ,]"
            }
            set array($left) $right
        }
    }
    return $errors
}

set INFO(aliases_calculeInverses) {
    calcule le tableau inverse
    tout est en minuscules
}
 
proc aliases_calculeInverses {aliasArrayName inverseArrayName regularName errorsName} {
    upvar $aliasArrayName aliasArray
    upvar $inverseArrayName inverseArray
    upvar $regularName regular
    upvar $errorsName errors

    if {[info exists inverseArray]} {
        unset inverseArray
    }
    foreach left [array names aliasArray] {
        foreach rightOrig $aliasArray($left) {
            set right [string tolower $rightOrig]
            if {![info exists regular($right)]} {
                if {[llength $aliasArray($left)] != 1} {
                    lappend errors "Pas d'alias pour \"$rightOrig\""
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

    if {![info exists inverseArray($noeud)]} return
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
    global TROMBINOSCOPE DATABASES DYNAMIC

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
    foreach left [lsort [array names LONGALIAS]] {
        if {[string match lpn-* $left] && [info exists LONGALIAS($left)]} {
            set value [list]
            foreach right $LONGALIAS($left) {
                lappend value $REGULAR($right)
            }
            puts ${alias_lpn-foobar} [list $left $value]
        }
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
    append+nl html {Fichier Original smtp.lpn.cnrs.fr:/etc/aliases<br>}
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

    append+nl html "<i>Donnees extraites automatiquement le [clock format $instant -format "%Y/%m/%d"] à [clock format $instant -format "%H:%M:%S"]
 par le programme get_aliases sur [info hostname]"
    append+nl html { (<a href="mailto:Fabrice.Pardo@@Lpn.cnrs.fr">fab</a>)</i>}
    append+nl html {<br>}
    append+nl html {<i>Pensez à recharger la page</i>}

    append+nl html {<hr width="100%" size="2" align="Left">}

    append+nl html {</body>}
    append+nl html {</html>}

    return $html
    
}


set dummy {}
getAliases
vwait dummy

