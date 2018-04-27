#!/bin/sh
# $Id: cleanThis.tcl,v 1.3 2003/01/20 23:26:20 fab Exp $
# the next line restarts using tclsh \
exec wish "$0" ${1+"$@"}

# 7 octobre 2001 (FP) révisé

set HELP($argv0) {
    Élimine dans ce répertoire tous les fichiers que l'on retrouve à la même place
    dans le répertoire donné en argument.
    Fait la même chose récursivement dans les sous-répertoires
    La comparaison est interactive
}

if {[llength $argv] != 1} {
    puts stderr "Usage: $argv0 otherDir"
    exit 1
}

set otherRoot $argv

proc cleanDir {dir otherRoot} {

    # puts stderr "cleanDir $dir"
    
    if {$dir == "."} {
	set files [lsort [glob -nocomplain * .*]]
    } else {
	set files [lsort [glob -nocomplain $dir/* $dir/.*]]
    }
    set flist [list]
    set dlist [list]
    set llist [list]
    set olist [list]
    foreach f $files {
	if {[file tail $f] == "." || [file tail $f] == ".."} {
	    continue
	}
	set type [file type $f]
	switch $type {
	    "file" {lappend flist $f}
	    "directory" {lappend dlist $f}
	    "link" {lappend llist $f}
	    default {lappend olist $f $type}
	}
    }
    # puts stderr [list dlist = $dlist]

    foreach {o type} $olist {
	puts stderr "$type: $o skipped"
    }

    foreach f $flist {
	compareAndDelete $f $otherRoot
    }

    foreach f $llist {
	compareAndDeleteLink $f $otherRoot
    }

    foreach d $dlist {
	cleanDir $d $otherRoot
    }
    
    if {[llength [glob $dir/* $dir/.*]] == 2} {
	set err [catch {file delete $dir} message]
	if {$err} {
	    puts stderr "$message"
	}
    }
}


proc compareAndDelete {f otherRoot} {
    global TODO
    set of [file join $otherRoot $f]

    if {![file exists $of]} {
	# puts stderr "inexistent: $f"
	lappend TODO(inexistent) $f
	return
    }

    set err [catch {file type $of} type]
    if {$err} {
	puts stderr "$f: $type"
	return
    }

    if {$type != "file"} {
	puts stderr "not same type: $f"
	return
    }

    set err [catch {file stat $f stat} message]
    if {$err} {
	puts stderr "$f: $message"
	return
    }

    set err [catch {file stat $of ostat} message]
    if {$err} {
	puts stderr "$of: $message"
	return
    }

    set err [catch {
	if {$stat(dev) == $ostat(dev) && $stat(ino) == $ostat(ino)} {
	    puts stderr "same inode: \"$f\", \"$of\""
	    return
        }
    } message]
	    
    if {$err} {
	puts stderr $message
	parray stat
	parray ostat
	return -code error "Erreur grave"
    }

    set err [catch {open $f r} fh]
    if {$err} {
	puts stderr "$f: $fh"
	return
    }
    
    set err [catch {open $of r} ofh]
    if {$err} {
	puts stderr "$of: $ofh"
	close $fh
	return
    }
     
    fconfigure $fh -translation binary
    set data [read $fh]
    close $fh
    fconfigure $ofh -translation binary
    set odata [read $ofh]
    close $ofh
    if {[string length $data] != $stat(size)} {
	puts stderr "size mismatch ([string length $data] != $stat(size)): $f"
	return
    }
    if {[string length $odata] != $ostat(size)} {
	puts stderr "size mismatch([string length $odata] != $ostat(size)): $of"
	return
    }

    if {$data == $odata} {
	file delete $f
	puts stderr "DELETE $f"
	return
    }
    # puts stderr "differents $f"
    lappend TODO(differents) $f
}

proc compareAndDeleteLink {f otherRoot} {
    set of [file join $otherRoot $f]
   
    set err [catch {file type $of} type]
    if {$err} {
	puts stderr "$f: $type"
	return
    }

    if {$type != "link"} {
	puts stderr "not same type: $f"
	return
    }

    set err [catch {file lstat $f stat} message]
    if {$err} {
	puts stderr "$f: $message"
	return
    }

    set err [catch {file lstat $of ostat} message]
    if {$err} {
	puts stderr "$of: $message"
	return
    }

    if {$stat(dev) == $ostat(dev) && $stat(ino) == $ostat(ino)} {
	puts stderr "same files: \"$f\", \"$of\""
	return
    }
	    
    if {$err} {
	puts stderr $message
	parray stat
	parray ostat
	return -code error "Erreur grave"
    }
    
    set err [catch {file readlink $f} fl]
    if {$err} {
	puts stderr "$f: $fl"
	return
    }
    
    set err [catch {file readlink $of} ofl]
    if {$err} {
	puts stderr "$of: $ofl"
	close $fh
	return
    }
     
    if {$fl == $ofl} {
	file delete $f
	puts stderr "DELETE $f"
	return
    }
    puts stderr "different links $f"
}

cleanDir . $otherRoot

foreach motif [array names TODO] {
    puts "\n   $motif\n"
    foreach f $TODO($motif) {
	puts $f
    }
}

proc remplaceDpG {} {
    global F otherRoot
    set oF [file join $otherRoot $F]
    set nF ~/S/[clock format [clock seconds]  -format %Y.%m.%d]/$F
    file mkdir [file dirname $nF]
    puts [list file rename $oF $nF]
    file rename $oF $nF
    puts [list file rename $F $oF]
    file rename $F $oF
    suivant
}

proc remplaceGpD {} {
    global F otherRoot
    set oF [file join $otherRoot $F]
    set nF ~/S/[clock format [clock seconds]  -format %Y.%m.%d]/$F
    file mkdir [file dirname $nF]
    puts [list file rename $F $nF]
    file rename $F $nF
    puts [list file rename $oF $F]
    file rename $oF $F
    suivant
}

proc suivant {} {
    if {[winfo exists .t]} {
	destroy .t
    }
    global DIFF F otherRoot
    if {$DIFF == {}} {
	fini
    }
    set F [lindex $DIFF 0]
    set DIFF [lrange $DIFF 1 end]
    catch {exec tkdiff $F [file join $otherRoot $F]} message
    puts $message
    toplevel .t
    label .t.l -textvariable F
    button .t.e -text "->" -command remplaceDpG
    button .t.s -text skip -command suivant
    button .t.r -text "<-" -command remplaceGpD
    pack .t.l
    pack .t.e -side left
    pack .t.r -side right
    pack .t.s
    raise .t
    if {[file mtime $F] > [file mtime [file join $otherRoot $F]]} {
	label .t.w -text "DANGER !!!!!!!!!!"
    }
}

proc fini {} {
    global otherRoot TODO
    if {![info exists TODO(inexistent)] || $TODO(inexistent) == {}} {
        exit 0
    }
    set ii ""
    foreach i $TODO(inexistent) {
        append ii $i\n
    }

    puts stderr "\ntaper sous tclsh:\n
foreach f \{
$ii\} \{
    set dir \[file dirname /home/fab/A/\$f\]
    if \{!\[file exists \$dir\]\} \{file mkdir \$dir\} 
    exec /bin/cp -ip \$f $otherRoot/\$f
\}"
    exit 0
}

if {[info exists TODO(differents)]} {
    set DIFF $TODO(differents) 
    suivant
    wm withdraw .
} else {
    puts FINI
    fini
}

