#!/bin/sh

# RCS: @(#) $Id: essai.tcl,v 1.1 2003/05/05 13:29:43 fab Exp $

# the next line restarts using wish with ni488 functions \
exec ni488 "$0" "$@"

package require fidev

package require gpibLowLevel
package require gpib
package require aide
package require minihelp

GPIB::main
GPIB::ui

set rien {
    set TC(machine) mm4005
    package require tablexy 1.2
    package require mm4005 1.0
    mm4005::createIfNonExistent
    toplevel .mm4005_ui
    wm geometry .mm4005_ui +0+0
    aligned::tablexy_ui mm4005 mm4005::specialFrame
    aide::nondocumente .mm4005_ui
}
