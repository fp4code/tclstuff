#!/bin/sh

# RCS: @(#) $Id: photocourant.tcl,v 1.3 2002/07/01 15:00:22 fab Exp $

# the next line restarts using wish \
exec wish "$0" "$@"

source [file join [file dirname [info script]] iv.0.3.tcl]

package require egg7260
package require pas-a-pas_rs

set _scanne_from 750
set _scanne_to 850
set _scanne_step 1
set _scanne_delay 5.

set fichierScanLog "C:/temp/mesures.spt"

toplevel .scanne

frame .scanne.f1

label .scanne.f1.lfrom -text from
entry .scanne.f1.from -textvariable _scanne_from
label .scanne.f1.lto -text to
entry .scanne.f1.to -textvariable _scanne_to
label .scanne.f1.lstep -text step
entry .scanne.f1.step -textvariable _scanne_step
label .scanne.f1.ldelay -text delay
entry .scanne.f1.delay -textvariable _scanne_delay
button .scanne.f1.scanne -text scanne -command \
    {scanne $_scanne_from $_scanne_to  $_scanne_step $_scanne_delay $fileScanLog} 

frame .scanne.rs
frame .scanne.fichier

label .scanne.fichier.nom -textvariable fichierScanLog
button .scanne.fichier.open -text open -command openScanLog
button .scanne.fichier.close -text close -command closeScanLog
pack .scanne.fichier.open .scanne.fichier.nom .scanne.fichier.close -side left

proc openScanLog {} {
    global fichierScanLog
    global fileScanLog

    catch {close $fileScanLog}

    set fichierScanLog [tk_getSaveFile -initialfile $fichierScanLog]
    set fileScanLog [open $fichierScanLog w]
}

proc closeScanLog {} {
    global fileScanLog
    close $fileScanLog
}
grid configure .scanne.f1.lfrom  .scanne.f1.from
grid configure .scanne.f1.lto    .scanne.f1.to
grid configure .scanne.f1.lstep  .scanne.f1.step
grid configure .scanne.f1.ldelay .scanne.f1.delay
grid configure .scanne.f1.scanne -

pack  .scanne.rs .scanne.fichier .scanne.f1

rs::ui .scanne.rs


