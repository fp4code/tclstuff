#!/usr/local/bin/tclsh

namespace eval ::fidev::lslR {
    variable TYPE
    set TYPE(-) "file"
    set TYPE(d) "directory"
    set TYPE(c) "characterSpecial"
    set TYPE(b) "blockSpecial"
    set TYPE(p) "fifo"
    set TYPE(l) "link"
    set TYPE(s) "socket"

    variable MODE
    set MODE(1r)  0400
    set MODE(2w)  0200
    set MODE(3x)  0100
    set MODE(3S) 04000 
    set MODE(3s) 04100 ;# uid on execution
    set MODE(4r)   040
    set MODE(5w)   020
    set MODE(6x)   010
    set MODE(6l) 02000 ;# mandadory locking
    set MODE(6S) 00000 ;# ??? unknown
    set MODE(6s) 02010 ;# group id
    set MODE(7r)    04
    set MODE(8w)    02
    set MODE(9x)    01
    set MODE(9T) 01000 ;# sticky bit
    set MODE(9t) 01001 ;# sticky bit
    
    variable OWNER
    set OWNER(card) fab
    
    variable GROUP
    set GROUP(admin) sysadmin
    
    
}

proc ::fidev::lslR::readDate {year date} {
    set month [lindex $date 0]
    set day [lindex $date 1]
    set yearOrTime [lindex $date 2]
    set lyot [string length $yearOrTime]
    if {$lyot == 4} {
        set dateString "$day $month $yearOrTime"
    } elseif {$lyot == 5} {
        set dateString "$day $month $year $yearOrTime"
    } else {
        error "yearOrTime \"$yearOrTime\" unrecognized"
    }
    if {[catch {clock scan $dateString} _date]} {
        error $_date
    }
    return $_date
}


proc ::fidev::lslR::treatLink {errorArrayName iline dir name link} {
    upvar $errorArrayName errorArray
    
    set fullname [file join $dir $name]

    if {![catch {file type $fullname} type]} {
        if {$type == "link"} {
            set actualLink [file readlink $fullname]
            if {$link != $actualLink} {
                lappend errorArray($iline) "actual link = $actualLink"
                return
            } else {
                return
            }
        } elseif {$type == "file"} {
            if {[catch {exec /usr/bin/cmp $fullname [file join $dir $link]} error]} {
                lappend errorArray($iline) "$name exists but $error"
                return
            }
            if {[catch {file delete $fullname} error]} {
                lappend errorArray($iline) "$error"
                return
            }
        } else {
            lappend errorArray($iline) "cannot reduce to link type \"$type\""
            return
        }
    }
    if {[catch {exec /usr/bin/ln -s $link $fullname} error]} {
        lappend errorArray($iline) "/usr/bin/ln : $error"
        return
    }
puts stderr "link created $fullname -> $link"

}

proc ::fidev::lslR::decortique {year errorArrayName _dir line iline} {
    upvar $errorArrayName errorArray
    variable TYPE
    variable MODE
    variable OWNER
    variable GROUP
        
    set mode      [lindex $line 0]
    set hardLinks [lindex $line 1]
    set owner     [lindex $line 2]
    set group     [lindex $line 3]
    set size      [lindex $line 4]
    set date      [lrange $line 5 7]
    set name      [lrange $line 8 end]

    set type [string index $mode 0]

    if {$type != "-" && $type != "l" && $type != "d"} {
        lappend errorArray($iline) "untreated type \"$type\" : $line"
        return
    }

    if {[info exists TYPE($type)]} {
        set _type $TYPE($type)
    } else {
        lappend errorArray($iline) "type \"$type\" unrecognized"
        unset _type
    }
    
    set _oMode 0
    for {set imode 1} {$imode <= 9} {incr imode} {
        set m [string index $mode $imode]
        if {$m == "-"} {
            continue
        }
        if {[catch {incr _oMode $MODE($imode$m)}]} {
            lappend errorArray($iline) "mode \"$mode\" : bad letter \"$m\" position $imode"
            unset _oMode
            break
        }
    }

    if {[catch {expr {$size}} _size]} {
        lappend errorArray($iline) "size \"$m\" unrecogized"
        unset _size
    }
    
    if {[catch {readDate $year $date} _date]} {
        lappend errorArray($iline) $_date
        unset _date
    }
    
    if {![info exists _type]} {
        return
    }
    
    if {$_type == "directory"} {
        return
    } elseif {$hardLinks != 1} {
#        lappend errorArray($iline) "hardLinks are presents for $_dir $line"
    }
    
    if {$_type == "link"} {
        set isep [string first " -> " $name"]
        if {$isep < 0} {
            lappend errorArray($iline) "link descriptor \" -> \" missing : \"$name\""
            return
        }
        incr isep -1
        set _name [string range $name 0 $isep]
        incr isep 5
        set _link [string range $name $isep end]
        treatLink errorArray $iline $_dir $_name $_link
    } else {
        set _name $name
    }
    
    set _fullname [file join $_dir $_name]

    if {$_type == "link"} {
        return
    }

    if {![file exists $_fullname]} {
        lappend errorArray($iline) "inexistent file \"$_fullname\", $line"
        return
    }

    set actualOwner [file attributes $_fullname -owner]
    if {[info exists _owner] && $actualOwner != $_owner} {
        lappend errorArray($iline) "owner of \"$_fullname\" : \"$actualOwner\" should be \"$_owner\""
        return
    }

    set actualGroup [file attributes $_fullname -group]
    if {[info exists _group] && $actualGroup != $_group} {
        lappend errorArray($iline) "group of \"$_fullname\" : \"$actualGroup\" should be \"$_group\""
        return
    }

    if {$_type == "link"} {
        return
    }

    set actualType [file type $_fullname]
    if {[info exists _type] && $actualType != $_type} {
        lappend errorArray($iline) "type of \"$_fullname\" : \"$actualType\" should be \"$_type\""
        return
    }

    set actualSize [file size $_fullname]
    if {[info exists _size] && $actualSize != $_size} {
        lappend errorArray($iline) "size of \"$_fullname\ \"$actualSize\" should be \"$_size\""
        return
    }

    if {[catch {file attributes $_fullname -permissions $_oMode} error]} {
        lappend errorArray($iline) "$error"
        return
    }

# uncomment to modify date
#    set tformat [clock format $_date -format %Y%m%d%H%M]
    #    if {[catch {exec /usr/bin/touch -t $tformat $_fullname} error]} {
#        lappend errorArray($iline) "$error \"$tformat\""
#        return
#    }

    if {$_type == "file"} {
        file stat $_fullname stat
        set missingLinks [expr {$hardLinks - $stat(nlink)}]
        for {} {$missingLinks > 0} {incr missingLinks -1} {
            set next [file readlink LINKS/NEXT]
            exec ln $_fullname LINKS/$next
            file delete LINKS/NEXT
            incr next
            exec ln -s $next LINKS/NEXT
        }
    } 

}

set YEAR 1998
set f [open /prog/linux/redhat-5.1/distrib/ls-lR]
set lines [read -nonewline $f]
close $f
set lines [split $lines \n]

set ll [llength $lines]

proc tratra {name1 name2 op} {
    upvar $name1 errorArray
    puts stderr "ERROR line $name2 : $errorArray($name2)"
}

trace variable errorArray w tratra


set dir "."
set statut 1
for {set i 0} {$i < $ll} {incr i} {
    set iline [expr {$i+1}]
    set line [lindex $lines $i]
    if {$statut == 2} {
        if {$line == ""} {
            set statut 0
        } elseif {$dir != ""} {
            ::fidev::lslR::decortique $YEAR errorArray $dir $line $iline
        }
    } elseif {$statut == 1} {
        if {[lindex $line 0] != "total"} {
            lappend errorArray($i) "missing \"total\", break!"
            break
        }
        set _total [lindex $line 1]
        set statut 2
    } elseif {$statut == 0} {
        set isep [string length $line]
        incr isep -1
        if {[string index $line $isep] != ":"} {
            lappend errorArray($i) "missing \":\" at the end of line, break!"
            break
        }
        incr isep -1
        set dir [string range $line 0 $isep]
        set statut 1
        if {![file isdirectory $dir]} {
            lappend errorArray($i) "inexistent directory \"$dir\""
            set dir ""
        }
    }
}

set errlines [lsort -integer [array names errorArray]]
foreach l $errlines {
    puts "$l $errorArray($l)"
}

