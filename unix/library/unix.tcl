# RCS: @(#) $Id: unix.tcl,v 1.4 2002/07/01 09:01:48 fab Exp $

fidev_load ../src/libtcl_unix unix

set HELP(unix) {
    gethostbyname hostname
}

package provide unix 1.0
