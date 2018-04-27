
proc mes.temperature {} {
    global temperature
    if {$temperature == 0} {
        toplevel .temperature -class Dialog
        label .temperature.l -text "température (K)"
        entry .temperature.e -textvariable temperature
        button .temperature.b -text OK -command "destroy .temperature"
        pack .temperature.l .temperature.e .temperature.b
        bind .temperature <Unmap> {
            if {"%W" == ".temperature"} { ;# bind on toplevel
                wm deiconify %W
            }
        }
        bind .temperature <Visibility> {
            if {"%W" == ".temperature"} {
                raise %W
            }
        }
        aide::nondocumente .temperature
        tkwait window .temperature
    }
}

