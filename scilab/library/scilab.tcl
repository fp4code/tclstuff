# RCS: @(#) $Id: scilab.tcl,v 1.3 2002/06/25 08:42:59 fab Exp $

package require pvm 0.1

namespace eval scilab {}

fidev_load ../src/libtclscilab tclScilab

source [file join [file dirname [info script]] pvm.tcl]

package provide scilab 0.1
