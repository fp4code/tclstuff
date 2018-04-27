package provide sysadmin_fichUtils 1.0

set didi [file dirname [info script]]

load $fidev_libDir/libfichUtils.so fichutils

namespace eval ::fidev::fichUtils {}

source $didi/fichier.tcl
source $didi/utils.tcl
# des que pret source $didi/findAndExec.tcl
source $didi/files.0.1.tcl

