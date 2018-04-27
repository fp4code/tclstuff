package provide l2mGraph 1.3 ;# new

source [file join [file dirname [info script]] l2mGraph.1.3.tcl]

namespace eval l2mGraph {
    namespace export graphEtBoutons
}

proc l2mGraph::graphEtBoutons {w} {
    
    if {$w == "."} {
        set r {}
    } else {
        set r $w
    }
    l2mGraph::boutons $r.btns

    set g1 [createGraph $r.g1]
    pack $g1 -expand 1 -fill both -side top
    pack  $r.btns
    
     
    bind $g1.c <Button-2>  {puts "%x %y"}
    
    return $g1
}

    
proc l2mGraph::boutons {r} {
    
    
    frame $r -borderwidth .5c
    frame $r.frame
    frame $r.radio1 -relief sunken -borderwidth 3
    frame $r.radioll -relief sunken -borderwidth 3

    grid $r.radio1 $r.frame
    grid $r.radioll ^

    radiobutton $r.radio1.f1 \
            -text full1 \
            -variable graphPriv.radio1 \
            -value 10 \
            -anchor w \
            -command [namespace code {
                foreach f $graphPriv_graphs {
                    bind_fullview1 $f
                }
            }]
    radiobutton $r.radio1.f2 \
            -text full2 \
            -variable graphPriv.radio1 \
            -value 20 \
            -anchor w \
            -command [namespace code {
                foreach f $graphPriv_graphs {
                    bind_fullview2 $f
                }
            }]
    radiobutton $r.radio1.z \
            -text zoom \
            -variable graphPriv.radio1 \
            -value 30 \
            -anchor w \
            -command  [namespace code {
                foreach f $graphPriv_graphs {
                bind_zoom $f
                }
            }]
    radiobutton $r.radio1.zX \
            -text zoomX \
            -variable graphPriv.radio1 \
            -value 31 \
            -anchor w \
            -command [namespace code {
                foreach f $graphPriv_graphs {
                    bind_zoomX $f
                }
            }]
    radiobutton $r.radio1.zY \
            -text zoomY \
            -variable graphPriv.radio1 \
            -value 32 \
            -anchor w \
            -command [namespace code {
                foreach f $graphPriv_graphs {
                    bind_zoomY $f
                }
            }]
    
    radiobutton $r.radio1.p \
            -text pan \
            -variable graphPriv.radio1 \
            -value 40 \
            -anchor w \
            -command [namespace code {
                foreach f $graphPriv_graphs {
                    bind_pan $f
                }
            }]
    
    radiobutton $r.radio1.zm2 \
            -text zoom/2 \
            -variable graphPriv.radio1 \
            -value 50 \
            -anchor w \
            -command [namespace code {
puts bind_zm2
puts $graphPriv_graphs
puts ::$graphPriv_graphs
                foreach f $graphPriv_graphs {
                    bind_zm2 $f
                }
            }]
    
    radiobutton $r.radio1.zm2X \
            -text zoom/2X \
            -variable graphPriv.radio1 \
            -value 51 \
            -anchor w \
            -command [namespace code {
                foreach f $graphPriv_graphs {
                    bind_zm2X $f
                }
            }]
    
    radiobutton $r.radio1.zm2Y \
            -text zoom/2Y \
            -variable graphPriv.radio1 \
            -value 52\
            -anchor w \
             -command [namespace code {
                foreach f $graphPriv_graphs {
                    bind_zm2Y $f
                }
            }]

    radiobutton $r.radioll.linx \
            -text linx \
            -variable graphPriv.radio1X \
            -value 1 -command [namespace code {
                foreach f $graphPriv_graphs {
                    toLin $f x
                }
            }]

    radiobutton $r.radioll.logx \
            -text logx \
            -variable graphPriv.radio1X \
            -value 2 -command [namespace code {
                foreach f $graphPriv_graphs {
                    toLog $f x
                    toLin $f x
                }
            }]

    radiobutton $r.radioll.liny \
            -text liny \
            -variable graphPriv.radio1Y \
            -value 1 -command [namespace code {
                foreach f $graphPriv_graphs {
                    toLin $f y
                    toLin $f x
                }
            }]
    radiobutton $r.radioll.logy \
            -text logy \
            -variable graphPriv.radio1Y \
            -value 2 -command [namespace code {
                foreach f $graphPriv_graphs {
                    toLog $f y
                    toLin $f x
                }
            }]
    
    grid $r.radio1.f1 $r.radio1.f2 $r.radio1.p -sticky ewns
    grid $r.radio1.zm2 $r.radio1.zm2X $r.radio1.zm2Y -sticky ewns
    grid $r.radio1.z $r.radio1.zX $r.radio1.zY -sticky ewns
    pack $r.radioll.linx $r.radioll.logx -side left
    pack $r.radioll.liny $r.radioll.logy -side left
    
    
    
    scrollbar $r.frame.scroll -command "$r.frame.list yview"
    listbox $r.frame.list -yscroll "$r.frame.scroll set" -setgrid 1 -height 6
    pack $r.frame.scroll -side right -fill y
    pack $r.frame.list -side left -expand 1 -fill both
    
    #    $r.frame.list insert 0 toto titi
    
    set rien {    bind $r.frame.list <1> {
        puts [selection get]
        puts [%W get [%W curselection]]
        $g1.c itemconfigure [%W get [%W curselection]] -fill blue
    }
    }
    bind $r.frame.list <Double-1> {
        puts [selection get]
        puts [%W get [%W curselection]]
        $g1.c delete [%W get [%W curselection]]
        %W delete [%W curselection]
        
    }
}
    

proc l2mGraph::insertInList {win tags} {
        set win [winfo parent $win]
        if {$win == "."} {
            set root {}
        } else {
            set root $win
        }
        $root.ctrl.frame.list insert end $tags
}
