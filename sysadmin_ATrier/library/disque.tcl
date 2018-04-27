#!/prog/Tcl/bin/tclsh

set repertoire /usr
set supprime {local}

proc getPhysique {repert} {
    set physique [exec /bin/df -k $repert]
    set physique [split $physique "\n"]
    if {[llength $physique] != 2} {
        error "Attendu 2 lignes, reçu $physique"
    }
    set physique [lindex $physique 1 ]
    set physique [lindex $physique 0]
    return $physique
}


proc contenuDuRepertoireNonMonteAilleurs {repertoire {supprime {}}} {

    set physiqueDuRepertoire [getPhysique $repertoire]

    set ici [pwd]
    
    cd $repertoire
    set fichiers [glob .* *]

    set supprime [concat $supprime . .. lost+found]

    set explore {}

    foreach f $fichiers {
        if {[lsearch -exact $supprime $f] != -1} {
            continue
        }
    
        set physique [getPhysique $repertoire/$f]
    
        if {$physique != $physiqueDuRepertoire} {
            continue
        }
            
        lappend explore $f
    }
    
    cd $ici
    return $explore
}

proc tailleUtilisee {fichiers} {
    set taille 0
    foreach f $fichiers {
       set dudu [exec /bin/du -ksd $f] ;# d indispensable
       incr taille [lindex $dudu 0]
       puts "$taille $dudu"
    }
    return $taille
}

set fifi [contenuDuRepertoireNonMonteAilleurs /]
cd /
set tata [tailleUtilisee $fifi]

;# explore contient tous les fichiers et répertoires a traiter


/ {export lost+found}
/export {root}
/export/root/*
/usr {opt local lost+found}
/usr/opt/*
/usr/local {tmp src}
/usr/local/src/*
/export/p6/local {src}
/export/p6/local/src
/export/p6/old/*
