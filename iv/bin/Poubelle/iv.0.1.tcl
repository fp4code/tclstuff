#!/bin/sh

# the next line restarts using wish \
LD_LIBRARY_PATH=$LD_LIBRARY_PATH":"/opt/NICgpib/lib ; export LD_LIBRARY_PATH ; exec wish "$0" "$@"

# package require hyperhelp 1.2.999
# set jstools_library /prog/Tcl/lib/jstools-4.5
# lappend auto_path $jstools_library

set tcl_traceExec 0
set tcl_traceCompile 0

proc sourceCode {dir file} {
    puts "sourceCode EST OBSOLETE, utiliser \"package\""
    puts "### $file"
    source $dir/library/$file
}

set AsdexTclDir /home/fidev/Tcl


puts "conflit voir superTable (opt) et aide"
package require fidev
package require superTable
package require aide
package require minihelp
package require l2mGraph 1.1

cd $AsdexTclDir


package require gpibLowLevel
package require gpib

sourceCode mesures temperat.iv.tcl
sourceCode mesures ressmu.iv.tcl
sourceCode mesures ecom.1.0.tcl

set JceMaxRaisonnable 2e-3 ;# A*um-2
set JbDirMaxRaisonnable [expr {0.1 * $JceMaxRaisonnable}]
puts "JceMaxRaisonnable = $JceMaxRaisonnable"
# package require mes_bipolaire

sourceCode mesures logsmu.iv.tcl
sourceCode mesures diode.tcl
sourceCode mesures gtlm.iv.tcl
sourceCode mesures tri.tcl
sourceCode mesures ibic.tcl
sourceCode masque xy.tcl
#sourceCode masque symdes.tcl
#sourceCode masque geom2d.tcl
package require masque
package require tbs2
#sourceCode masque tbs2.tcl
sourceCode iv asyst.tcl
sourceCode iv tc.tcl

sourceCode iv sauve.iv.tcl
sourceCode iv iv_ui.tcl
sourceCode iv foreach.tcl
# sourceCode iv DIVERS.tcl

puts "ALL IS SOURCED"

proc iv:quit {w} {
    set answer [tk_messageBox -default ok -message "OK to quit ?" -type okcancel  -icon question]
    case $answer {
        ok exit
        cancel {tk_messageBox -message "Vous avez bien raison !" -type ok}
    }
}

proc iv:read.def {} {
    global ASDEXDATA gloglo
    iniGlobals
    if {[info exists gloglo]} {unset gloglo}
    source iv_valeursParDefaut/library/$ASDEXDATA(typMes).def.tcl
}

proc readTypesMes {} {
    global AsdexTclDir
    set tm {}
    set ext {.def.tcl}
    set extlen [string length $ext]
    cd $AsdexTclDir/iv_valeursParDefaut/library
    set defs [glob *$ext]
    cd $AsdexTclDir
    foreach def $defs {
        lappend tm [string range $def 0 \
            [expr {[string length $def] - $extlen -1}]]
    }
    return [lsort $tm]
}

proc iniGlobals {} {
    global variable_SRQ
    set variable_SRQ {}


set rien {
    global IVGLO
    set IVGLO(typMes) [readTypesMes]

    global MINIHELP
    set MINIHELP(sgt) "GTLM ancienne mode"
    set MINIHELP(sg2) "GTLM nouvelle mode"
    set MINIHELP(log) "diode (mesure rapide)"
}


    global ASDEXDATA
    if {![info exists ASDEXDATA]} {
        set ASDEXDATA(rootData) /home/asdex/data
        set ASDEXDATA(plaque) ""
        set ASDEXDATA(echantillon) ""
        set ASDEXDATA(typCar) ""
        set ASDEXDATA(mparams) ?mparams?
        set ASDEXDATA(eparams) ?eparams?
    }

    global GPIB_board GPIB_boardAddress

    newGPIB 2000 k2000   $GPIB_board 11
    newGPIB 2361 synchro $GPIB_board 15
    newGPIB smu  smu1    $GPIB_board 16
    newGPIB smu  smu2    $GPIB_board 17
    newGPIB smu  smu3    $GPIB_board 18
#    puts "### smuIniGlobals" ; smuIniGlobals
    puts "### 2000:iniGlobals" ; 2000:iniGlobals

# TBT BT 400
#    newBT400 tbt 0 23
    set tbt(classe) tbt
    
    global temperature
    set temperature 0

    global TC
    set TC(go) 0
}

puts "### main" ; main
iniGlobals

iv_ui .

toplevel .graph
set g [::l2mGraph::graphEtBoutons .graph]

pack $g -expand 1 -fill both
# testLabels $g
bind $g.c <Button-2>  {puts "%x %y"}

proc plot {liste col1 col2 xname yname tags} {
    set ptsx {}
    set ptsy {}
    foreach l $liste {
        lappend ptsx [lindex $l $col1]
        lappend ptsy [lindex $l $col2]
    }
    .graph.g1.c delete all
puts "afaire l2mGraph::plotSimple .graph.g1 $ptsx $ptsy -xscale $xname -yscale $yname -tags $tags"

}

# l2mGraph:toLog .graph.g1 y
# l2mGraph:toLin .graph.g1 y


tk_focusFollowsMouse ;# pour l'aide
aide::nondocumente .
