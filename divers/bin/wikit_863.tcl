#!/usr/local/bin/tclsh

proc ins { list args } {
    upvar #0 $list which
    
    eval lappend which $args
}

proc rem { list args } {
    upvar #0 $list which
    
    foreach item $args {
        switch -regexp -- $item {
            \[-0-9\]\[0-9\]* { set which [ lreplace $which $item $item ] }
            default {
                set this [ lsearch $which $item ]
                if { $this != -1 } {
                    set which [ lreplace $which $this $this ]
                }
            }
        }
    }
}


proc accessable { obj1 obj2 } {
    if { [object $obj1 where] == [object $obj2 where] } {return 1}
    if { [object $obj1 hasobjs $obj2] } {return 1}
    return 0
}

proc object { name func args } {
    global ObjDesc ObjAttrs ObjContents ObjFuncs ObjExits ObjWears ObjLoc ObjArticle ObjState
    
    if { "$name" == "" } { return }
    switch -exact -- $func {
        new      {
            set ObjDesc($name) ""
            set ObjAttrs($name) ""
            set ObjContents($name) ""
            set ObjFuncs($name) ""
            set ObjExits($name) ""
            set ObjLoc($name) ""
            set ObjState($name) "in"
            set ObjArticle($name) "a"
            foreach { i j } $args {
                switch -exact -- $i {
                    -desc     { eval object $name setdesc $j }
                    -attrs    { eval object $name addattrs $j }
                    -contents { eval object $name insobjs $j }
                    -where    { eval object $j insobjs $name ; set ObjLoc($name) $j }
                    -exits    { eval object $name addexits $j }
                    -don      { eval set ObjWears($name) $j }
                    -define   { eval object $name define $j }
                    -article  { set ObjArticle($name) $j }
                    -state    { set ObjState($name) $j }
                }
            }
            set body "eval object $name \$args"
            proc $name: "args" "$body"
        }
        setstate  { eval set ObjState($name) $args    }
        state     { puts -nonewline $ObjState($name)  }
        article   { puts -nonewline " $ObjArticle($name) "}
        setdesc   { set ObjDesc($name) "$args"        }
        describe  { puts -nonewline " $ObjArticle($name) $ObjDesc($name)" }
        addexits  { eval ins ObjExits($name) $args    }
        remexits  { eval rem ObjExits($name) $args    }
        getexits  { return $ObjExits($name)           }
        hasexits  {
            foreach i $args {
                if { [ lsearch $ObjExits($name) $i ] == -1 } {
                    return 0
                }
            }
            return 1
        }
            
        addattrs  {
            eval ins ObjAttrs($name) $args
            foreach i $args {
                if {"[ info procs $i ]" != ""} {
                    $i $name $ObjLoc($name)
                }
            }
        }
        remattrs  {
            eval rem ObjAttrs($name) $args
            foreach i $args {
                if { "[ info procs $i ]" != "" } {
                    $i $name $ObjLoc($name)
                }
            }
        }
        getattrs  { return ObjAttrs($name)            }
        hasattrs  {
            foreach i $args {
                if { [ lsearch $ObjAttrs($name) $i ] == -1 } { return 0 }
            }
            return 1
        }
        insobjs   { eval ins ObjContents($name) $args }
        remobjs   { eval rem ObjContents($name) $args }
        getobjs   { return $ObjContents($name)        }
        hasobjs   {
            foreach i $args {
                if { [ lsearch $ObjContents($name) $i]  == -1 } { return 0 }
            }
            return 1
        }
        where     { return $ObjLoc($name)             }
        take      {
            if { [ object $name do take $args ] } { return 0 }
            foreach i $args {
                if { [ object $ObjLoc($name) hasobjs $i ] } {
                    if { [ object $i hasattrs !move ] } {
                        puts "You can't take the $i."
                    } else {
                        object $ObjLoc($name) remobjs $i
                        object $name insobjs $i
                        puts "$i taken"
                    }
                } else {
                    if { [ object $i hasattrs place ] } {
                        object $name moveto $i
                    } else {
                        puts "I see no $i here."
                    }
                }
            }
        }
        drop      {
            if { [ object $name do drop $args ] } { return }
            foreach i $args {
                if { [ object $name hasobjs $i ] } {
                    if { [ object $i hasattrs !move ] } {
                        puts "You can't drop the $i."
                    } else {
                        object $name remobjs $i
                        object $ObjLoc($name) insobjs $i
                        puts "$i dropped."
                    }
                } else {
                    puts "I see no $i here."
                }
            }
        }
        don       {
            if { [ object $name do don $args ] } { return }
            foreach i $args {
                if { [ object $ObjLoc($name) hasobjs $i ] } { object $name take $i }
                if { [ object $name hasobjs $i ] } {
                    if { [ object $i hasattrs wear ] } {
                        ins ObjWears($name) $i
                        rem ObjContents($name) $i
                        puts "You are now wearing a $i."
                    } else {
                        puts "Okay, how, exactly, do I wear a $i?"
                    }
                } else {
                    puts "I don't see a $i here."
                }
            }
        }
        doff      {
            if { [ object $name do doff $args ] } { return }
            foreach i $args {
                if { [ object $name has_on $i ] } {
                    rem ObjWears($name) $i
                    ins ObjContents($name) $i
                    puts "$i removed."
                } else {
                    puts "You aren't wearing a $i."
                }
            }
        }
        wearing   { return $ObjWears($name) }
        has_on    {
            foreach i $args {
                if { [ lsearch $ObjWears($name) $i ] != -1 } { return 1 }
            }
            return 0
        }
        moveto    {
            if { [ object $name do moveto $args ] } { return }
            set exit [ lindex $args 0 ]
            if { [ object $ObjLoc($name) hasexits $exit ] } {
                object $ObjLoc($name) remobjs $name
                set ObjLoc($name) $exit
                object $ObjLoc($name) insobjs $name
            } elseif { [ object $ObjLoc($name) hasobjs $exit ] } {
                object $name enter $exit
            } else {
                return
            }
            foreach i [ object [ object $name where ] getattrs ] {
                if { "[ info procs $i ]" != "" } {
                    $i $name $ObjLoc($name)
                }
            }
        }
        enter     {
            if { [ object $name do enter $args ] } { return }
            set what [ lindex $args 0 ]
            if { [ object $name hasobjs $what ] } {
                puts "How can you enter that?"
                return
            }
            if { [ object $ObjLoc($name) hasobjs $what ] } {
                if { [ object $what hasattrs place ] } {
                    object $ObjLoc($name) remobjs $name
                    set ObjLoc($name) $what
                    object $ObjLoc($name) insobjs $name
                } else {
                    puts -nonewline "How, exactly, do you climb into "
                    object $what describe
                    puts "?"
                }
            } else {
                return "I see no $what here."
            }
        }
        exit      {
            if { [ object $name do exit $args ] } { return }
            set what $ObjLoc($name)
            if { [ object $what hasattrs place ] } {
                object $ObjLoc($name) remobjs $name
                set ObjLoc($name) $ObjLoc($what)
                object $ObjLoc($name) insobjs $name
            } else {
                puts "Exit to where?"
            }
        }
        define    {
            foreach { fname body } $args {
                set fname [ string trim $fname ]
                eval ins ObjFuncs($name) $fname
                uplevel #0 proc $name-$fname "args" \{$body\}
            }
        }
        do        {
            set fname [lindex $args 0]
            set args [ lrange $args 1 end ]
            if { "[ info procs $name-$fname ]" != "" } {
                return [ eval uplevel #0 $name-$fname $args ]
            } else {
                return 0
            }
        }
        default   { puts "message $func $args not understood by $name" ; exit }
    }
}

 #################################################################
 # tiny little space adventure to test out above
 #################################################################

proc vacuum { args } {
    if { [ me: has_on spacesuit ] } { return }
    puts "There is vacuum here - and you are not wearing a spacesuit.  You die."
    exit
}

object bridge new -desc {bridge of the ship} -attrs {place} -exits {passageway} -article the

object passageway new -desc {small room aft of the bridge} -attrs {place} -exits {bridge airlock}

object outside new -desc {outside the ship} -attrs {place} -article ""
object airlock new -desc {airlock} -exits {passageway} -has {switch} -attrs {place} -article an

object sphere new -desc {silvery sphere} -where {bridge} -attrs {place !move}

object laser new -desc {laser} -where {bridge} -define {
    use {
        if { ! [ accessable me laser ] } {
            puts "You can't use it if you aren't holding it."
            return 0
        }
        set location [ me: where ]
        foreach item $args {
            if { "$item" == "" } { return 0 }
            if { "$item" == "laser"} {
                puts "The laser cannot shoot itself."
                return 0
            }
            if { ("$item" != "on") && ("$item" != "at") } {
                if { [ me: hasobjs $item ] } {
                    me: drop $item
                }
                if { [ [ me: where ]: hasobjs $item ] } {
                    puts "$item destroyed"
                    $location: remobjs $item
                    return 1
                } else {
                    puts "I see no $item here."
                    return 0
                }
            }
        }
        return 0
    }
}

set airlock_switch 0
object switch new -desc {switch} -attrs {!move} -where {airlock} -define {    
    use {
        global airlock_switch
        if { ! [ accessable me switch ] } {
            puts "You can't use the switch if you aren't near it."
            return 0
        }
        puts "The airlock cycles."
        if { $airlock_switch } {
            puts "The air rushes in."
            set airlock_switch 0
            passageway: addexits airlock
            outside: remexits airlock
            airlock: addexits passageway
            airlock: remexits outside
            airlock: remattrs vacuum
        } else {
            puts "The air rushes out."
            set airlock_switch 1
            passageway: remexits airlock
            outside: addexits airlock
            airlock: remexits passageway
            airlock: addexits outside
            airlock: addattrs vacuum
        }
        look
        return 1
    }
}

object jumper new -desc {ship's jumper} -attrs {wear}

object spacesuit new -desc {standard-issue spacesuit} -attrs wear -where airlock

object me new -where bridge -don jumper -define {
    moveto {
        if { "$args" == "outside" } {
            me: setstate ""
        } elseif { ("[ me: where ]" == "outside") && ("$args" == "airlock") } {
            me: setstate " in"
        }
        return 0
    }
}

####################################################################

proc look { } {
    puts ""
    puts -nonewline "You are"
    me: state
    [ me: where ]: describe
    puts -nonewline "."
    set inv [ [ me: where ]: getobjs ]
    set me [ lsearch $inv me ]
    set inv [ lreplace $inv $me $me ]
    set len [ llength $inv ]
    if { $len > 0 } {
        puts -nonewline "  There is"
        set first 1
        incr len -1
        for { set i 0 } { $i <= $len } { incr i } {
            set curitem [ lindex $inv $i ]
            if { !$first } {
                if { "$i" == "$len" } {
                    puts -nonewline " and"
                } else {
                    puts -nonewline ", "
                }
            }
            set first 0
            $curitem: describe
        }
        puts -nonewline " here."
    }
    set exits [ [ me: where ]: getexits ]
    set numexits [ llength $exits ]
    puts -nonewline "  "
    if { $numexits == 0 } {
        puts -nonewline "There are no exits." ; return
    } elseif { $numexits == 1 } {
        puts -nonewline "There is an exit to the "
    } else {
        puts -nonewline "There are exits to the "
    }
    set first 1
    foreach i $exits {
        if { !$first } { puts -nonewline ", " }
        set first 0
        puts -nonewline "$i"
    }
    puts "."
}

proc go { where } {
    me: moveto $where
    look
}

proc enter { where } {
    me: enter $where
    look
}

proc exit { } {
    me: exit
    look
}

proc take { args } {
    me: take $args
}

proc drop { args } {
    me: drop $args
}

proc inventory { } {
    set inv [ me: getobjs ]
    if { "$inv" != "" } {
        puts -nonewline "You are carrying: "
        set first 1
        foreach i $inv {
            if { !$first } { puts -nonewline ", " }
            set first 0
            $i: describe
        }
        puts "."
    } else {
        puts "You are carrying nothing."
    }
    set inv [ me: wearing ]
    if { "$inv" != "" } {
        puts -nonewline "You are wearing "
        set first 1
        foreach i $inv {
            if { !$first } { puts -nonewline ", " }
            set first 0
            $i: describe
        }
        puts "."
    } else {
        puts "You are wearing nothing."
    }
}

proc examine { what } {
    $what: describe
}

proc use { what args } {
    if { ![ $what: do use $args ] } {
        puts "I see no point to that."
    }
}

proc don { what args } {
    me: don $what
}

proc doff { what args } {
    me: doff $what
}

proc bye { args } {
    exit
}

look
while 1 {
    puts -nonewline ">>> " ; flush stdout
    if { [catch {eval [gets stdin]} message] } {
        puts $message
        puts $errorInfo
    } else {
        puts $message
    }
}



