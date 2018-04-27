# RCS: @(#) $Id: all.0.1.tcl,v 1.3 2002/06/25 08:42:53 fab Exp $

namespace eval ::fidev::fichUtils {}

fidev_load ../src/libfichUtils fichutils

set didi [file dirname [info script]]
source $didi/fichier.tcl
source $didi/utils.tcl
# des que pret source $didi/findAndExec.tcl
source $didi/files.0.1.tcl

package provide sysadmin_fichUtils 0.1
