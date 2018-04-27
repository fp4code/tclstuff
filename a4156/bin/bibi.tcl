#!/bin/sh

# RCS: @(#) $Id: iv.0.3.tcl,v 1.8 2003/05/05 08:02:13 fab Exp $

# the next line restarts using wish \
LD_LIBRARY_PATH=$LD_LIBRARY_PATH":"/opt/NICgpib/lib ; export LD_LIBRARY_PATH ; exec wish "$0" "$@"

#
# package require hyperhelp 1.2.999
# set jstools_library /prog/Tcl/lib/jstools-4.5
# lappend auto_path $jstools_library

# puts stderr $env(LD_LIBRARY_PATH)

set tcl_traceExec 0
set tcl_traceCompile 0

proc sourceCode {dir file} {
    puts "sourceCode EST OBSOLETE, utiliser \"package\""
    puts "### $file"
    source $dir/library/$file
}

puts "conflit voir superTable (opt) et aide"
package require fidev
package require superTable
package require aide
package require minihelp
package require l2mGraph 1.1

set AsdexTclDir $FIDEV_TCL_ROOT
cd $AsdexTclDir

package require gpibLowLevel
package require gpib
