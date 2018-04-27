package require sysadmin
package require sysadmin_tableUtils 1.0

namespace eval sysadmin::usersAdmin {
    proc usersValides {arrayName} {
        upvar $arrayName pass
        if {[info exists pass]} {
            unset pass
        }
    
        set passlist [split [exec niscat -h passwd.org_dir] \n"]

        sysadmin::tableUtils::new pass \
            [string range [lindex $passlist 0] 2 end] \
            [lrange $passlist 1 end] \
            :
    
        set newLignes {}
        foreach nom $pass(LIGNES) {
            set p $pass($nom,passwd)
            if {$p == ""} {
                puts stderr "ALERTE : pas de mot de passe pour $nom"
            }
            if {$p == "*LK*" || $p == "*" || $p == "NP"} {
                set supprimeLe 1
            } elseif {$pass($nom,home) != "/home/$nom"} {
                set supprimeLe 1
            } else {
                set supprimeLe 0
            }
            
            if {$supprimeLe} {
                foreach c $pass(COLONNES) {
                    unset pass($nom,$c)
                }
            } else {
                if {[file isdirectory /home/$nom]} {
                    lappend newLignes $nom
                } else {
                    puts stderr "/home/$nom non isdirectory"
                }
            }
        }
        set pass(LIGNES) $newLignes
        return [lsort $newLignes]
    }
}
