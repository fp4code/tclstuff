# RCS: @(#) $Id: all.0.2.tcl,v 1.3 2002/06/25 08:42:53 fab Exp $

namespace eval ::fidev::fichUtils {}

fidev_load ../src/libfichUtils.0.2 fichutils

set didi [file dirname [info script]]
source $didi/fichier.tcl
source $didi/utils.tcl
# dès que prêt source $didi/findAndExec.tcl
source $didi/files.0.1.tcl

package provide fichUtils 0.2
