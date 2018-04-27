set programme {
    set ter /width:255
    dir /free
    dir /full du0:[1,3]
    vfy /lo
    crea /dir du0:[perdus]
    rename *.j01;* [perdus]
    rename *.p01;* [perdus]
    rename P.CMD;4 [perdus]
    rename P.CMD;5   [perdus]
    rename PLANNING.CMD;4 [perdus]
    rename PLANNING.CMD;5 [perdus]
    rename KERMIT.CMD;4 [perdus]
    rename CONV.CMD;1   [perdus]
    rename CONV.CMD;5   [perdus]
    rename SLCCUR.DAT;2 [perdus]
    rename EDTINI.EDT;2 [perdus]
    rename EDTINI.EDT;3 [perdus]
    rename EDTINI.EDT;4 [perdus]
    rename *.epl;* [perdus]
    rename *.ltl;* [perdus]
    rename *.pdl;* [perdus]
    rename BZ. [perdus]
    rename CROI0690.;1 [perdus]
    rename D.;1 [perdus]
    rename F.;1 [perdus]
    rename FET21.;1 [perdus]
    rename FETLGMESA.;1 [perdus]
    rename GA.;1 [perdus]
    rename LF1OHMIC.;1 [perdus]
    rename LFOH.;1 [perdus]
    rename MAR1.;1 [perdus]
    rename TXT.;1 [perdus]

  
rename CONV.CMD;1   [perdus]
rename MULGUI.DAT;1 [perdus]
rename *.EOL;* [perdus]
rename KERMIT.INI;1 [perdus]
rename AATEST.JO1;1 [perdus]
rename SPIRALEC2.JOU;1 [perdus]
rename GRAV1.LST;1 [perdus]
rename YONG1.MES;1 [perdus]
rename LIN.OBJ;2 [perdus]
rename LZFASY.OBJ;1 [perdus]
rename SPIRALEC2.TMP;2 [perdus]
rename LIN.TSK;1 [perdus]
rename LZFASY.TSK;1 [perdus]
rename NEMO.TXT;1 [perdus]
rename QUESTEL.TXT;1 [perdus]
rename TRY.TXT;1 [perdus]
rename MASQTR2.X;1 [perdus]



rename .;3 [perdus]
rename EDTINI.EDT;2 [perdus]
rename P.CMD;4 [perdus]
rename EDTINI.EDT;3 [perdus]
rename VERSION.CMD;4 [perdus]
rename VMR.CMD;4 [perdus]
rename CONV.CMD;5 [perdus]
rename KERMIT.CMD;4 [perdus]
rename PLANNING.CMD;4 [perdus]
rename JJS.CMD;4 [perdus]
rename EDTINI.EDT;4 [perdus]
rename DIR.CMD;5 [perdus]
rename P.CMD;5 [perdus]
rename EDTINI.EDT;5 [perdus]
rename P.CMD;6 [perdus]
rename CONV.CMD;6 [perdus]
rename KERMIT.CMD;5 [perdus]
rename PLANNING.CMD;5 [perdus]
rename JJS.CMD;5 [perdus]
rename EDTINI.EDT;6 [perdus]
rename EDTINI.EDT;7 [perdus]
rename P.CMD;7 [perdus]
rename CONV.CMD;7 [perdus]
rename PATREAD.CMD;8 [perdus]
rename KERMIT.CMD;6 [perdus]
rename PLANNING.CMD;6 [perdus]
rename JJS.CMD;6 [perdus]
rename P.CMD;8 [perdus]
rename CONV.CMD;8 [perdus]
rename PATREAD.CMD;9 [perdus]
rename KERMIT.CMD;7 [perdus]
rename PLANNING.CMD;7 [perdus]
rename DIR.CMD;7 [perdus]
rename JJS.CMD;7 [perdus]
rename EDTINI.EDT;8 [perdus]
rename FILDMP.DMP;3 [perdus]
rename FILDMP.DMP;4 [perdus]
rename FILDMP.DMP;5 [perdus]
rename FILDMP.DMP;6 [perdus]
rename FILDMP.DMP;7 [perdus]
rename FILDMP.DMP;8 [perdus]
rename FILDMP.DMP;9 [perdus]
rename FILDMP.DMP;10 [perdus]
rename FILDMP.DMP;11 [perdus]
rename EDTINI.EDT;9 [perdus]
rename .;4 [perdus]
rename FILDMP.DMP;12 [perdus]
rename FILDMP.DMP;13 [perdus]
rename FILDMP.DMP;14 [perdus]
rename FILDMP.DMP;15 [perdus]
rename STEPH402A.TMP;2 [perdus]

    ...
    dir /full du0:[*]*.*;* 
}


set f [open /home/fab/A/fidev/Tcl/pdp/bin/2004-09-16-dir.log]

set ll [split [read -nonewline $f] \n] ; close $f

if {[lindex $ll 0] != {Directory DU0:[1,3]} || [lindex $ll 2] != {} || [lindex $ll end-1] != {} || ![string match {Total of *} [lindex $ll end]]} {
    return -code error "fichier mal encadré "
}

set f13 [list]
foreach l [lrange $ll 3 end-2] {
    if {![regexp {^([^.]*)\.([^;]*);([^ ]*) } $l tout nom extension version]} {
	return -code error "cannot regexp \"$l\""
    }
    lappend f13 [list $nom $extension $version]
}

catch {unset EXTS13}
foreach fi $f13 {
    if {[info exists EXTS13([lindex $fi 1])]} {
	incr EXTS13([lindex $fi 1])
    } else {
	set EXTS13([lindex $fi 1]) 1
    }
}

parray EXTS13


set f [open /home/fab/A/fidev/Tcl/pdp/bin/2004-09-16-vfy2.log]

set ll [split [read -nonewline $f] \n] ; close $f

catch {unset OLD_NAME}

catch {foreach {l1 l2} $ll {
    if {![regexp {^File ID ([0-7]+),([0-7]+) ([^ ]+)  Owner \[([^\]]+)\]$} $l1 tout i1 i2 name owner]} {
	return -code error "cannot regexp \"$l1\" as l1"
    } 
    
    if {![regexp {^        File successfully entered as (.*)$} $l2 tout newname]} {
	return -code error "cannot regexp \"$l2\" as l2"
    } 
    
    if {$name != $newname} {
	puts stderr "$name -> $newname"
    }
    
    set OLD_NAME($newname) $name
} } blabla

puts $blabla

proc byext {a b} {
    set r [string compare [lindex $a 1] [lindex $b 1]]
    if {$r != 0} {return $r}
    set r [string compare [lindex $a 0] [lindex $b 0]]
    if {$r != 0} {return $r}
    return [expr {[lindex $a 2] - [lindex $b 2]}]
}

set fichiers [list]
foreach fi [array names OLD_NAME] {
    if {![regexp {^([^.]*)\.([^;]*);(.*)$} $fi tout nom extension version]} {
	return -code error "cannot regexp $fi"
    }
    lappend fichiers [list $nom $extension $version]
}


catch {unset EXTS}
foreach fi [lsort -command byext $fichiers] {
    if {[info exists EXTS([lindex $fi 1])]} {
	incr EXTS([lindex $fi 1])
    } else {
	set EXTS([lindex $fi 1]) 1
    }
    puts [lindex $fi 0].[lindex $fi 1]\;[lindex $fi 2]
}

parray EXTS