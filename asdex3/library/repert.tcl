
# -----------------------------------------------------------------------------
# Gestion des répertoires
# -----------------------------------------------------------------------------

# loadDirData --
#
# chargement d'un répertoire racine Asdex après sélection
#
proc loadDirData hl {
    global ASDEX
    
    $hl delete 1.0 end
       
    cd $ASDEX(dirData)
    if {[catch {glob \[0-9A-Za-z\]*} fichiers]} {
        return
    }
    set dirs {}
    foreach i [lsort $fichiers] {
        if {[file isdirectory $i]} then {
            set nom $i
        } else {
            continue
        }
        set name [file tail $nom]
        lappend dirs $name
    }
    foreach papa $dirs {
        widgets::insertReturnIfNotVierge $hl
        $hl insert end $papa level1
        if {[catch {cd $ASDEX(dirData)/$papa} reponse]} {
            puts stderr "$ASDEX(dirData)/$papa : $reponse"
            continue
        }
        if {[catch {glob ${papa}*} dispos]} {
            continue
        }
        foreach i [lsort $dispos] {
            if {[file isdirectory $i]} then {
                set dispo $i
            } elseif {[string match *.tar.gz $i]} {
                set dispo [string range $i 0 [expr [string length $i] - 8]]
                if {[file isdirectory $dispo]} {
                    continue
                }
            } else {
                continue
            }
            $hl insert end \n
            $hl insert end "    "
            $hl insert end $dispo level2
        }
    }
    cd $ASDEX(dirData)
}

proc loadDirDispo {hl} {
    global ASDEX
    upvar #0 private_$hl privarray

    $hl delete 1.0 end

    set Repertoire $ASDEX(dirData)/$ASDEX(Plaque)/$ASDEX(Dispo)
    
    if {![file isdir $Repertoire]} {
        return 1
    }
   
    if {![file executable $Repertoire] || ![file readable $Repertoire]} {
        kd_message_box error "$Repertoire :\n    Accès interdit !"
        return 1
    }

    cd $Repertoire
    
    if {$ASDEX(dataVersion) == 3} {
        global ASDEX_REPERTOIRES_SPT
        widgets::listboxSetType2 $hl choixDirMesure
        
        if {[info exists ASDEX_REPERTOIRES_SPT]} {
            unset ASDEX_REPERTOIRES_SPT
        }
        if {[file exists repertoires.spt]} {
            set indexes [superTable::fileToTable ASDEX_REPERTOIRES_SPT \
                          repertoires.spt "repertoires $ASDEX(Dispo)" \
                          repertoire]
            set dirs [lindex $indexes 0]
            set natures [list]
            foreach d $dirs {
                lappend didi($ASDEX_REPERTOIRES_SPT([list $d nature])) $d
            }
            foreach i [lsort [array names didi]] {
                widgets::insertReturnIfNotVierge $hl
                $hl insert end $i level1
                foreach d [lsort $didi($i)] {
                    $hl insert end \n
                    $hl insert end "    "
                    $hl insert end $d level2
                }
            }
        } else {
            kd_message_box error "fichier repertoires.spt pas à jour"
        }    
    } elseif {$ASDEX(dataVersion) == 2} {
        widgets::listboxSetType1 $hl choixDirMesure
        
        set pasDeFichiers [catch  {glob \[0-9A-Za-z\]*} fichiers]
        if {!$pasDeFichiers} {
            foreach i [lsort $fichiers] {
                if {[file isdirectory $i]} then {
                    set nom $i
                } elseif { [regexp {.*\.tar\.gz} $i] } {
                    set nom [string range $i 0 [expr [string length $i] - 8]]
                    if {[file isdirectory $nom]} {
                        continue
                    }
                } else {
                    continue
                }
                set name [file tail $nom]
                widgets::insertReturnIfNotVierge $hl
                $hl insert end $name leaf
            }
        } else {
            puts "RIEN pour loadDirDispo : $fichiers"
        }
    }
}

proc loadDirMesure {hl quoi} {
    global ASDEX
    $hl delete 1.0 end

    if {$ASDEX(dataVersion) == 3} {
        loadDirMesureV3 $hl [lindex $quoi 1]
    } elseif {$ASDEX(dataVersion) == 2} {
        loadDirMesureV2 $hl $quoi
    }
}

proc loadDirMesureV3 {hl Repertoire} {
    global ASDEX
    global ASDEX_REPERTOIRES_SPT
    
    foreach t [lsort $ASDEX_REPERTOIRES_SPT([list $Repertoire tables])] {
        widgets::insertReturnIfNotVierge $hl
        $hl insert end $t leaf
    }
}

proc loadDirMesureV2 {hl Repertoire} {
    global ASDEX
    global ASDEXDATAFILES
    set Repertoire $ASDEX(dirData)/$ASDEX(Plaque)/$ASDEX(Dispo)/$Repertoire

    $ASDEX(pl).c delete all
    
    foreach n [array names ASDEX Brut:*] {
        unset ASDEX($n)
    }
    foreach n [array names ASDEX BrutC:*] {
        unset ASDEX($n)
    }
    
    if {![file isdir $Repertoire]} {
        puts "$Repertoire : Non répertoire"
        return 1
    }
    
    if {![file executable $Repertoire] || ![file readable $Repertoire]} {
        kd_message_box error "$Repertoire :\n    Accès interdit"
        return 1
    }

    cd $Repertoire

    set d "\[0-9\]"
    set l "\[a-zA-Z\]"
    set c "\[a-zA-Z0-9\]"

    set tables [superTable::tablesOfDir *.spt ASDEXDATAFILES]
    if {$tables == 0} {
        set ASDEX(dataVersion) 3
        foreach t $tables {
            widgets::insertReturnIfNotVierge $hl
            $hl insert end $t leaf
        }
    } else {
        set descript ${d}${d}${d}${d}_${d}${d}${d}.${c}${c}${c}
        if {[catch {glob $descript} fichiers]} then {
            puts RIEN
        } else {
            set ASDEX(dataVersion) 2
            foreach nom $fichiers {
                set nm [string range $nom 9 11] ;# nature de la mesure. ex : "sch"
                set li [stringutils::stripzeros [string range $nom 0 1]]
                set co [stringutils::stripzeros [string range $nom 2 3]]
                set temp [string range $nom 5 7]
                if {[info exists ASDEX(Brut:$nm)]} {
                    incr ASDEX(Brut:$nm)
                    if {$li<$ASDEX(BrutC:limin,$nm)} {
                        set ASDEX(BrutC:limin,$nm) $li
                    } elseif {$li>$ASDEX(BrutC:limax,$nm)} {
                        set ASDEX(BrutC:limax,$nm) $li
                    }
                    if {$co<$ASDEX(BrutC:comin,$nm)} {
                        set ASDEX(BrutC:comin,$nm) $co
                    } elseif {$co>$ASDEX(BrutC:comax,$nm)} {
                        set ASDEX(BrutC:comax,$nm) $co
                    }
                } else {
                    widgets::insertReturnIfNotVierge $hl
                    $hl insert end $nm leaf
                    set ASDEX(Brut:$nm) 1
                    set ASDEX(BrutC:limin,$nm) $li
                    set ASDEX(BrutC:limax,$nm) $li
                    set ASDEX(BrutC:comin,$nm) $co
                    set ASDEX(BrutC:comax,$nm) $co
                }
            }
        }
    }
}

proc dispo_format {dispo} {
    global ASDEX
    if {[file isdirectory $ASDEX(dirData)/$ASDEX(Plaque)/$dispo]} {
        return "repertoire"
    }
    if {[file isfile $ASDEX(dirData)/$ASDEX(Plaque)/$dispo.tar]} {
        return "tar"
    }
    if {[file isfile $ASDEX(dirData)/$ASDEX(Plaque)/$dispo.tar.gz]} {
        return "tar.gz"
    }
    return {}
}

proc isAdispoDir {dispo} {
    if {[dispo_format $dispo] != {}} {
        return 1
    } else {
        return 0
    }
}

proc decomprime {file} {
    global KdResult

    set cwd [pwd]
    cd $dirData
    blt_bgexec -errorvar KdErrors KdResult \
	/usr/local/bin/zcat $file | /usr/bin/tar xvf -
    cd $cwd
    set KdErrors {}
    tkwait variable KdResult
    puts "KdResult=$KdResult, KdErrors=$KdErrors"
}

