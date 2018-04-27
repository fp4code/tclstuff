# package provide fichUtils 1.0 

namespace eval utils {
    variable FICHIERS_OUVERTS
    variable NAMES
    
    proc nn {} {
        variable NAMES
        set i 0
        while {[info exists NAMES($i)]} {
            incr i
        }
        set NAMES($i) {}
        return $i
    }
    
    proc openAndReadWritableFile {name linesArg} {
        upvar $linesArg lignes
        variable FICHIERS_OUVERTS
        set pwd [pwd]
        set dada [file mtime $name]
        set fichier [open $name r+]
        set lignes [split [read -nonewline $fichier] "\n"]
        set nana [nn]
        set FICHIERS_OUVERTS($nana,pwd) $pwd
        set FICHIERS_OUVERTS($nana,name) $name
        set FICHIERS_OUVERTS($nana,date) $dada
        close $fichier
        return $nana
    }

    proc wacf {nana lignes} {
        variable FICHIERS_OUVERTS
        if {![info exists FICHIERS_OUVERTS($nana,pwd)]} {
            error "Le fichier numéro \"$nana\" n'est plus ouvert"
        }
        cd $FICHIERS_OUVERTS($nana,pwd)
        set name $FICHIERS_OUVERTS($nana,name)
        set dada [file mtime $name]
        if {$dada != $FICHIERS_OUVERTS($nana,date)} {
            error "Le fichier $FICHIERS_OUVERTS($nana,name) a été modifié"
        }
        set bak $name.BAK
        if {[file exists $bak]} {
            set i 1
            while {[file exists $bak#$i]} {
                incr i
            }
            set bak $bak#$i
        }
        file rename $name $bak
        set fichier [open $name w]
        foreach l $lignes {
            puts $fichier $l
        }
        close $fichier
        unset FICHIERS_OUVERTS($nana,pwd)
        unset FICHIERS_OUVERTS($nana,name)
        unset FICHIERS_OUVERTS($nana,date)
    }

    proc writeAndCloseFile {nana lignes} {
        set pwd [pwd]
        set err [catch {wacf $nana $lignes} message]
        cd $pwd
        if {$err} {
            error $message
        }
    }
}
