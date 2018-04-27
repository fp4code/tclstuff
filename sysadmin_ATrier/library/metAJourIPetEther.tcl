#!/prog/Tcl/bin/tclsh

set aide(execCommande) {
Lance une commande Unix.
En cas d'erreur, imprime le message sur stderr et retourne le numéro d'erreur.
Sinon, retourne 0
}
proc execCommande {args} {
    puts "---> $args"
    set err [catch {eval exec $args} rep]
    if {$err != 0} {
        puts stderr "ERREUR : exec $args -> $rep"
    }
    return $err
}


    
set aide(metAJour) {
traite une ligne
numero_ip nom_du_micro # numero_ethernet commentaires...
le nom_du_micro doit être mac* ou pc*
ex :
130.100.240.10	pcspm		#  2:7:1:f:ff:78	Pc Wang (C04)
et met à jour la table nis+ hosts.org_dir
et, si le numero ethernet est donné, ethers.org_dir et netgroup.org_dir sont mis à jour.
}

proc metAJour {lili} {
    # decoupage en liste
    set ligne {}
    foreach e $lili {
        if {$e != {}} {
        lappend ligne $e
        }
    }
    
    set ip [lindex $ligne 0]
    set name [lindex $ligne 1]
    set diese [lindex $ligne 2]
    set ether [lindex $ligne 3]
    
    # vérification de la syntaxe : présence du #
    if {$diese != "#"} {
        puts stderr "ligne $lili rejetée par manque de #"
        return
    }
    
    # vérification de la syntaxe : nom mac* ou pc*
    if {!([string match pc* $name] || [string match mac* $name])} {
        puts stderr "ligne $lili rejetée parce que le nom n'est no mac* ni pc*"
        return
    }
    
    # vérification de la présence du numéro ethernet
    set etherli [split $ether ":"]
    if {[llength $etherli] != 6} {
        puts stderr "manque le numero ethernet"
        set ether {} 
        set comments [lrange $ligne 3 end]
    } else {
        set comments [lrange $ligne 4 end]
    }
    
    # vérification de la syntaxe : numéro ethernet
    if {$ether != {} } {
        foreach i $etherli {
            if {!([string match \[0-9a-f\] $i] || [string match \[0-9a-f\]\[0-9a-f\] $i])} {
            puts stderr "numero ethernet $ether incorrect"
            return
            }
        }
    }
    
    # vérification de la syntaxe : numéro internet
    set ipli [split $ip "."]
    if {[llength $ipli] != 4} {
        puts stderr "numero internet $ip incorrect"
        return
    }
    foreach i $ipli {
        if {!($i>0 && $i<255)} {
        puts stderr "nombre $i du numéro internet $ip incorrect"
        return
        }
    }
    

    # suppression de l'ancien IP s'il existe
    set err [catch {exec  nismatch addr=$ip hosts.org_dir} rep]
    if {$err==0} {
        puts stderr "va être supprimé : $rep OK (y/n) " nonewline
        set rep [gets stdin]
        if {$rep != "y"} {
            return
        } 
        execCommande nistbladm -r addr=$ip hosts.org_dir
    }
    

    # mise à jour du nouvel IP
    execCommande nistbladm -a cname=$name name=$name addr=$ip comment=[concat $ether $comments] hosts.org_dir
    
    # la suite n'est faite que si le numéro ethernet existe
    if {$ether == {}} {
        return
    }
    
    # suppression de l'ancien ether s'il existe
    set err [catch {exec  nismatch addr=$ether ethers.org_dir} rep]
    if {$err==0} {
        puts stderr "va être supprimé : $rep OK (y/n) " nonewline
        set rep [gets stdin]
        if {$rep != "y"} {
            return
        } 
        execCommande nistbladm -r addr=$ether ethers.org_dir
    }
    
    
    # mise à jour du nouvel ether
    execCommande nistbladm -a name=$name addr=$ether comment=$comments ethers.org_dir
    
    # ajout dans la table des droits d'accès 
    execCommande nistbladm -a name=PCL2M host=$name netgroup.org_dir
}


set aide(metAJourLignes) {
appelle metAJour sur un ensemble de lignes
}

proc metAJourLignes {lignes} {

    set lignes [split $lignes "\n"]

    foreach ligne $lignes {
        metAJour $ligne
    }
}

