package require sysadmin
package require sysadmin_tableUtils 1.0

namespace eval sysadmin::usersAdmin {
    
    proc emailList {arrayName} {
        
        set LABO L2M.CNRS.fr
        set SERVEUR l2m
        
        upvar $arrayName EMAIL
        if {[info exists EMAIL]} {
            unset EMAIL
        }
    
        set aliaslist [split [exec niscat -h mail_aliases.org_dir] \n"]

        sysadmin::tableUtils::new  aliases \
                [string range [lindex $aliaslist 0] 2 end] \
                [lrange $aliaslist 1 end]

        foreach a $aliases(LIGNES) {
            set alias $aliases($a,alias)
            set expansion $aliases($a,expansion)
            if {[regexp [subst -nocommand {([a-z]+)(@$SERVEUR)}] $expansion tout login reste]} {
                if {[string match *.* $alias]} {
                    if {[info exists EMAIL($login)]} {
                        puts stderr "Conflit $login : $EMAIL($login) et $alias@$LABO"
                    }
                    set EMAIL($login) $alias@$LABO   
                }
            }
        }
    }
}
