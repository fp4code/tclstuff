#!/usr/local/bin/tclsh

# 13 juillet 1999 (FP): changement radical: les vecteurs colonne deviennent des vecteurs ligne
# 20 juillet 2000 (FP): S'il y a trop de mesures, scilab disjoncte (too many names)
#                       Les noms de variables sont tronqués à 24 caractères -> On supprime $dispo, et on met le fichier .scilab dans le répertoire
# 29 novembre 2000 (FP): suppression du bug _10_ au lieu de _100_ pour 1V
# 29 novembre 2000 (FP): rajout de "reste_"


package require fidev; package require scilab

if {$argc != 1} {
    puts stderr "syntaxe: $argv0 repertoire_de_dispo"
}

cd $argv

set dispo [file tail $argv]
cd ..

set tid [::scilab::pvm_spawn /home/fab/A/fidev/scilab/essai_pvm/esclave.sce]
::scilab::exec $tid getf('/home/fab/A/fidev/scilab/sparams/sparams_readSriFile.sci')
::scilab::exec $tid getf('/home/fab/A/fidev/scilab/sparams/sparams_readSmdFile.sci')


proc stringReplace {s old new} {
    set ret ""
    set ii [string length $old]
    incr ii 1
    while {[set i [string first $old $s]] >= 0} {
	incr i -1
	if {$i >= 0} {
	    append ret [string range $s 0 $i]
	}
	append ret $new
	incr i $ii
	set s [string range $s $i end]
	if {$s == ""} {
	    return $ret
	}
    }
    append ret $s
    return $ret
}

proc lit {tid dir dispo params} {
    # construction d'un fichier provisoire
    if {[regexp {^(([0-9]+)()|([0-9]*)p([0-9]*))(V|mA|uA)(([0-9]+)()|([0-9]*)p([0-9]*))(V|mA|uA)(.*)$} $params tout xtt x0 xd x1 x2 xiv ytt y0 yd y1 y2 xiv reste] != 1} {
	error "cannot regexp \"$params\""
    }
puts stderr [list $tout -> $y0 $y1 $y2]
    if {$reste != {}} {
        puts stderr "reste \"$reste\""
    }
    if {$x0 != {}} {
	set x [format %02d $x0]
	append x 0
    } else {
	if {$x1 == {}} {
	    set x1 0
	}
	if {$x2 == {}} {
	    set x2 0
	}
	set x [format %02d $x1]$x2
    }
    if {$y0 != {}} {
	set y [format %1d $y0]
	append y 00
    } else {
	if {$y1 == {}} {
	    set y1 0
	}
	if {$y2 == {}} {
	    set y2 0
	}
	set y [format %1d $y1]$y2
    }

    # le nom de variables scilab ne peut pas commencer par un chiffre. On commence donc par "_"
    # set prefix _${dispo}_${x}_${y}_
    if {$reste == {}} {
        set prefix _${x}_${y}_
    } else {
        set prefix _${x}_${y}_${reste}_
    }
    set ftmp ~/tmp/sparams${prefix}.tmp
    set tables [exec /usr/local/bin/sptdump [file join $dir $dispo ${params}.spt]]

    set tables_string "${prefix}tables = \["
    set first 1
    foreach table $tables {
	if {$first} {
	    set first 0
	} else {
	    append tables_string ";"
	}
	append tables_string "'$table'"
    }
    append tables_string "\]"
    ::scilab::exec $tid $tables_string

    set VcVbIcIb [exec /usr/local/bin/sptdump [file join $dir $dispo ${params}.spt]  *Polarisation Vce Vbe Ic Ib ]
    set VcVbIcIb [stringReplace $VcVbIcIb \t " "]
    ::scilab::exec $tid "${prefix}VcVbIcIb = \[$VcVbIcIb\]'"

    set err [catch {exec /usr/local/bin/sptdump [file join $dir $dispo ${params}.spt] *Sparams} message]
    if {$err} {
        return -code error "error sptdump on ${params}.spt: $message"
    }
    set colonnes [lindex $message 0]
    puts stderr "colonnnes = $colonnes"

    # ATTENTION ATTENTION ATTENTION
    # Dans le mode Réel/Imaginaire, on a s11 s12 s21 s22
    # Dans le mode Module/Degrés, on a s11 s21 s12 s22

    puts [list fichier = $ftmp]
    if {[lsort $colonnes] == [lsort {freq s11_r s11_i s12_r s12_i s21_r s21_i s22_r s22_i}]} {
        exec /usr/local/bin/sptdump [file join $dir $dispo ${params}.spt] *Sparams freq s11_r s11_i s12_r s12_i s21_r s21_i s22_r s22_i > $ftmp
        # le nom de variables scilab ne peut pas commencer par un chiffre. On commence donc par "_"
        ::scilab::exec $tid "\[${prefix}f, ${prefix}s11, ${prefix}s12, ${prefix}s21, ${prefix}s22\] = sparams_readSriFile('$ftmp');"
    } elseif {[lsort $colonnes] == [lsort {freq s11_m s11_deg s21_m s21_deg s12_m s12_deg s22_m s22_deg}]} {
        exec /usr/local/bin/sptdump [file join $dir $dispo ${params}.spt] *Sparams freq s11_m s11_deg s21_m s21_deg s12_m s12_deg s22_m s22_deg > $ftmp
        # le nom de variables scilab ne peut pas commencer par un chiffre. On commence donc par "_"
        ::scilab::exec $tid "\[${prefix}f, ${prefix}s11, ${prefix}s12, ${prefix}s21, ${prefix}s22\] = sparams_readSmdFile('$ftmp');"
    } else {
        return -code error "Colonnes anormales: $colonnes"
    }
    return $prefix
}

set PREFIXES [list]

set LIST [list]
foreach f [glob $dispo/*.spt] {
    lappend LIST [file rootname [file tail $f]]
}

foreach m $LIST {
    puts $m
    if {[catch {lit $tid . $dispo $m} prefix] == 1} {
	puts stderr $prefix
    } else {
	lappend PREFIXES $prefix
    }
}

set PREFIXES [lsort $PREFIXES]

puts "PREFIXES = $PREFIXES"

set scilabString {[}
set first 1
foreach p $PREFIXES {
    if {$first} {
	set first 0
    } else {
	append scilabString ";"
    }
    append scilabString "'$p'"
}

append scilabString {]}

puts [list ::scilab::exec $tid "_${dispo}_prefixes = $scilabString"]
::scilab::exec $tid "_${dispo}_prefixes = $scilabString"

# set scilabFile [pwd]/${dispo}.scilab
set scilabFile [pwd]/${dispo}/${dispo}.scilab
if {[file exists $scilabFile]} {
    file delete $scilabFile
}

set scilabString {save('}
append scilabString "${scilabFile}'"
append scilabString ",_${dispo}_prefixes"
foreach p $PREFIXES {
    append scilabString ",${p}tables,${p}VcVbIcIb,${p}f,${p}s11,${p}s12,${p}s21,${p}s22"
}
append scilabString {)}

::scilab::exec $tid $scilabString

::scilab::exec $tid quit

puts done

exit
