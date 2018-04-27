# RCS: @(#) $Id: parport.0.1.tcl,v 1.3 2002/06/25 08:42:57 fab Exp $

namespace eval parport {}

fidev_load ../src/libfidevtclparport.0.1 Parport

package provide parport 0.1
