#!/prog/Tcl/bin/tclsh

set homes [exec niscat auto_home.org_dir]
set homes [split $homes '\n']

set homeNames {}
foreach h $homes {
    lappend homeNames [lindex $h 0]
}
set homeNames [lsort $homeNames]

proc sortCol0 {a1 a2} {
    set i1 [lindex $a1 0]
    set i2 [lindex $a2 0]
    if {$i2>$i1} {
        return 1
    }
    if {$i2<$i1} {
        return -1
    }
    return 0
}

proc pourtous {homeNames files oper tri} {
    set liste {}
    foreach h $homeNames {
        set HOME /home/$h
        set err [catch $files resul]
        if {$err} {
            puts stderr $resul
            continue
        }
        set err [catch $oper resul]
        if {$err} {
            puts stderr $resul
            continue
        }
        lappend liste "$resul $h"
    }
    set liste [lsort -command $tri $liste]
    return $liste
}

proc affListe {liste} {
    foreach l $liste {
        puts $l
    }
}

set poubelleIleaf [pourtous $homeNames \
                    {glob $HOME/desktop/*clp} \
                    {exec du -ks $resul} \
                    sortCol0]
affListe $poubelleIleaf

set poubelleCDE [pourtous $homeNames \
                    {glob $HOME/.dt/Trash*} \
                    {exec du -ks $resul} \
                    sortCol0]
affListe $poubelleCDE

set mail [pourtous $homeNames \
                    {glob /var/mail/$h} \
                    {exec du -ks $resul} \
                    sortCol0]
affListe $mail



set entete {Return-Path: <fab>
Subject: Videz votre poubelle CDE
}

set qq {
foreach l $liste {
    set qui [lindex $l 2]
    set quoi [lindex $l 1]
    set combien [lindex $l 0]
    if {$combien > 10000} {
        set texte "To: $qui\n\nLe répertoire $quoi\ncorrespondant à la poubelle du gestionnaire de fichiers de l'environnement CDE\noccupe $combien kO"
        exec /usr/lib/sendmail $qui << $entete$texte
        puts "Maile à $qui pour $combien"
    }
}

}
