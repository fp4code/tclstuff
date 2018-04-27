proc dumpOne {OUT varName} {
    upvar #0 $varName var
    puts $OUT [list $varName $var]
}

set TORDER(x) 0
set TORDER(y) 1
set TORDER(m) 2
set TORDER(d) 3
set TORDER(f) 0
set TORDER(mf) 1

proc compare_t {t1 t2} {
    global TORDER
    return [expr {$TORDER($t1) - $TORDER($t2)}]
}

proc dumpVar {OUT _var} {
    global commonCtx$_var
    set T [list]
    foreach a [array names commonCtx$_var fit,*] {
        lappend T [lindex [split $a ,] end]
    }
    set T [lsort -command compare_t $T]
    foreach t $T {
        puts $OUT {}
        dumpOne $OUT commonCtx${_var}(fit,$t)
        dumpOne $OUT commonCtx${_var}(xlinlog,$t)
        dumpOne $OUT commonCtx${_var}(frange,$t)
        dumpOne $OUT commonCtx${_var}(hold,$t)
        if {[set commonCtx${_var}(hold,$t)]} {
            dumpOne $OUT commonCtx${_var}(xmin,$t)
            dumpOne $OUT commonCtx${_var}(xmax,$t)
            dumpOne $OUT commonCtx${_var}(ymin,$t)
            dumpOne $OUT commonCtx${_var}(ymax,$t)
        }
    }    
}

proc dumpAll {OUT} {

    puts $OUT [clock format [clock seconds] -format "%Y/%m/%d %H:%M:%S"]
    puts $OUT {}
    puts $OUT "### VARIABLES GLOBALES ###"
    puts $OUT {}

    dumpOne $OUT fichier
    
    puts $OUT {}

    global FACD
    dumpOne $OUT FACD
    
    global PMODORDER PMODMIN PMODMAX PMOD PMODFIT
    foreach p $PMODORDER {
        puts $OUT {}
        dumpOne $OUT PMODMIN($p)
        dumpOne $OUT PMODMAX($p)
        dumpOne $OUT PMOD0($p)
        dumpOne $OUT PMOD($p)
        dumpOne $OUT PMODFIT($p)
    }

    global CHOICE CHOICE_NEXT
    set ini .b.choix1.f_s11._s11
    set c $ini
    set nc $CHOICE_NEXT($c)
    while 1 {
        set _var [lindex [split $c .] end]
        set var [string range $_var 1 end]
        set win .param$_var
        puts $OUT {}
        dumpOne $OUT CHOICE($var)
        if {$CHOICE($var)} {
            foreach ch [winfo children $win.c] {
                dumpVar $OUT $_var
            }
        }
        set c $nc
        set nc $CHOICE_NEXT($c)
        if {$nc == $ini} break
    }
}

proc findHyperDir {dir} {
    set ici [file tail $dir]
    while {![string match hyper* $ici]} {
        set ndir [file dirname $dir]
        if {$ndir == $dir} {
            return $dir
        } else {
            set dir $ndir
        }
        set ici [file tail $dir]
    }
    return $dir
}

proc dumpAllInDir {} {
    global fichier
    set dumpdir [file join [findHyperDir [file dirname $fichier]] dumpFits]
    file mkdir $dumpdir
    set file [tk_getSaveFile -defaultextension dump -initialdir $dumpdir -initialfile [clock format [clock seconds] -format "%Y.%m.%d.%H.%M.%S"].dump]
    if {$file == {}} {
        return -code error "Aborted !"
    }
    set OUT [open $file w]
    dumpAll $OUT
    close $OUT
    puts stderr "Le fichier \"$file\" est écrit"
}

proc reloadAll {file} {
    set IN [open $file r]
    set lines [split [read -nonewline $IN] \n]
    close $IN
    set index [lsearch $lines "### VARIABLES GLOBALES ###"]
    if {$index < 0} {
        return -code error "Le fichier \"$file\" ne contient pas de ligne \"### VARIABLES GLOBALES ###\""
    }
    incr index
    foreach l [lrange $lines $index end] {
        incr index
        if {[llength $l] == 0} continue
        if {[llength $l] != 2} {
            return -code error "Erreur ligne $index de $file, il n'y a pas deux éléments"
        }
        set commande [list set [lindex $l 0] [lindex $l 1]]
        if {[catch {uplevel #0 $commande} message]} {
            return -code error "Erreur ligne $index de $file: $message"
        }
    }
    global fichier
    readFichier $fichier

    foreach Gname [info globals commonCtx_*] {
        upvar #0 $Gname G
        foreach a [array names G xlinlog,*] {
            set t [lindex [split $a ,] end]
            set G(xlastlinlog,$t) $G(xlinlog,$t)
        }
    }
}

proc reloadAllInDir {} {
    global fichier
    set dumpdir [file join [findHyperDir [file dirname $fichier]] dumpFits]
    set file [tk_getOpenFile -defaultextension dump -initialdir $dumpdir]
    if {$file == {}} {
        return -code error "Aborted !"
    }
    reloadAll $file
}
