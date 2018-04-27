# 4 février 2003 (FP)
# 2005-05-09 (FP) ajout de commentaires

load $env(P10PROG)/db/$env(P10ARCH)/lib/libdb_tcl.so

################# SUR CLIENT

load $env(P10PROG)/db/$env(P10ARCH)/lib/libdb_tcl.so
array set GLOB {date 2005-05-09 hostname mataf.lpn.prive raw hda1}

cd /home/bb/$GLOB(date).$GLOB(raw)
set prefix $GLOB(date).$GLOB(hostname).$GLOB(raw)

set dbLinks       [berkdb open $prefix.links.db]
set dbDirs        [berkdb open $prefix.dirs.db]
set dbFiles       [berkdb open $prefix.files.db]
set dbDirContents [berkdb open $prefix.dircontents.db]
set dbInodes      [berkdb open $prefix.inodes.db]

proc dump {database} {
    # lecture de l'intégralité de la base en {key value key value...}
    set tout [$database get -glob *]
    # remplissage d'un tableau. Comme il peut y avoir plusieurs value pour une même key, "array set ..." ne convient pas
    foreach x $tout {
        lappend TOUT([lindex $x 0]) [lindex $x 1]
    }
    # tri des clés et affichage de toutes les values
    set lastk {}
    foreach k [lsort [array names TOUT]] {
        if {$k != $lastk} {
            puts stderr $k
        }
        foreach v [lsort $TOUT($k)] {
            puts stderr "    $v"
        }
        set lastk $k
    }
}


proc dump_direct {database} {
    set lastk {}
    foreach kv [$database get -glob *] {
	foreach {k v} $kv {
	    if {$k != $lastk} {
		puts stderr $k
	    }
	    puts stderr "    $v"
	    set lastk $k
	}
    }
}


dump $dbLinks       
dump_direct $dbLinks       
dump $dbDirs        
dump $dbFiles       
dump $dbDirContents
dump_direct $dbInodes      

proc scanall {db} {
    set cursor [$db cursor]
    set i 0
    set kv [$cursor get -first]
    while {$kv != {}} {
        set kv [$cursor get -next]
	incr i
	if {$i % 1000 == 0} {puts stderr $i}
    }
    $cursor close
}

scanall $dbLinks
scanall $dbDirs        
scanall $dbFiles       
scanall $dbDirContents
scanall $dbInodes      

################# SUR SERVEUR

cd /export/SAUVEGARDE/essaiBigBrother2
# La base principale 
set dbV1 [berkdb open databaseV1.db]
# La base md5sum -> réponse du programme Unix "file"
set nature [berkdb open nature.db] ;# (-btree)

proc dbSyncAll {} {
    foreach h [lsort [berkdb handles]] {
        if {[regexp {^db[0-9]+$} $h]} {
            puts stderr $h
            $h sync
        }
    }
}

# Pour remplir ou mettre à jour "nature" à partir d'une liste de fichiers md5sum dans le répertoire courant
proc natureFillWithNew {files} {
    set lignes [eval exec file $files]
    set nl [list]
    foreach l [split $lignes \n] {
        if {[string index $l 32] == ":"} {
            lappend nl $l
        } else {
            set nl [lreplace $nl end end "[lindex $nl end] $l"]
        }
    }
    foreach l $nl {
        $nature put [string range $l 0 31] [string range $l 34 end]
    }
    $nature sync
}

# Pour remplir complètement "nature" en traitant tous les fichiers bodies/xx/xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
proc natureFillAll {} {
    set ici [pwd]
    foreach d [lsort [glob bodies/*]] {
        puts stderr $d
        cd $d
        natureFillWithNew [glob *]
        cd $ici
    }
}

# Pour mettre à jour "nature" en traitant tous les fichiers bodies/xx/xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
proc natureUpdate {} {
    set ici [pwd]
    foreach d [lsort [glob bodies/*]] {
        puts stderr $d
        cd $d
        set files [glob *]
        set nl [list]
        foreach f $files {
            if {[$nature get $f] == {}} {
                lappend nl $f
            }
        }
        natureFillWithNew $nl
        cd $ici
    }
}

proc sizeFullBuild {} {
    global size
    cd /export/SAUVEGARDE/essaiBigBrother2
    catch {berkdb dbremove size.db}
    set size [berkdb open -create -btree size.db]
    set ici [pwd]
    foreach d [lsort [glob bodies/*]] {
        cd $d
        puts $d
        foreach f [glob *] {
            $size put $f [file size $f]
        }
        cd $ici
    }
    $size sync
}

# 10000 clés par seconde
proc sizeAndNatureFullBuildFromDb {} {
    global nature size sizeAndNature
    cd /export/SAUVEGARDE/essaiBigBrother2
    catch {berkdb dbremove sizeAndNature.db}
    set sizeAndNature [berkdb open -create -btree sizeAndNature.db]
    set c [$nature cursor]
    set xn [$c get -first]
    set i [expr {wide(0)}]
    while {$xn != {}} {
        set xn [lindex $xn 0]
        set k [lindex $xn 0]
        set vn [lindex $xn 1]
        set xs [$size get $k]
        set xs [lindex $xs 0]
        set vs [lindex $xs 1]
        $sizeAndNature put $k [list $vs $vn]
        set xn [$c get -next]
        incr i
        if {$i % 1000 == 0} {
            puts stderr $i
        }
    }
    $c close
    $sizeAndNature sync
}

proc repertoiresFullBuild {dbV1} {
    # 2000 clés par seconde environ
    global repertoires
    catch {berkdb dbremove repertoires.db}
    set repertoires [berkdb open -create -btree -dup repertoires.db]
    set c [$dbV1 cursor]
    set x [$c get -first]
    set i [expr {wide(0)}]
    while {$x != {}} {
        set x [lindex $x 0]
        set k [lindex $x 0]
        set v [lindex $x 1]
        if {[lindex $v 0] == "+"} {
            $repertoires put [lrange $v 4 5] $k
        } else {
            puts stderr "skip $v"
        }
        set x [$c get -next]
        incr i
        if {$i % 1000 == 0} {
            puts stderr $i
        }
    }
    $repertoires sync
    $c close
}

proc byNatureFullBuild {} {
    global nature
    global byNature
    catch {berkdb dbremove byNature.db}
    set byNature [berkdb open -create  -btree -dup byNature.db]
    set c [$nature cursor]
    set x [$c get -first]
    set i [expr {wide(0)}]
    while {$x != {}} {
        set x [lindex $x 0]
        $testdup put [lindex $x 1] [lindex $x 0]
        set x [$c get -next]
        incr i
        if {$i % 1000 == 0} {
            puts stderr $i
        }
    }
    $byNature sync
    $c close
}

set repertoires [berkdb open repertoires.db]

proc repertoiresDirGlob {dir} {
    global repertoires
    global dbV1
    set reps [$repertoires get -glob $dir]
    foreach kv $reps {
        set k [lindex $kv 0]
        set v [lindex $kv 1]
        set x [$dbV1 get $v]
        if {[llength $x] != 1} {
            puts stderr "doublon $x"
        }
        set x [lindex $x 0]
        puts stderr [lindex $x 1]
    }
}

proc repertoiresDir {dir} {
    global repertoires
    global dbV1
    set reps [$repertoires get $dir]
    foreach kv $reps {
        set k [lindex $kv 0]
        set v [lindex $kv 1]
        set x [$dbV1 get $v]
        if {[llength $x] != 1} {
            puts stderr "doublon $x"
        }
        set x [lindex $x 0]
        puts stderr [lindex $x 1]
    }
}

set testdup [berkdb open testdup.db]

set c [$repertoires cursor]

$c get -first 
