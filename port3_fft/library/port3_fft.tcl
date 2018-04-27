# RCS: @(#) $Id: port3_fft.tcl,v 1.3 2002/06/25 08:42:58 fab Exp $

package require blasObj

namespace eval port3 {}
fidev_load ../src/libtclport3fft Port3fft

package provide port3_fft 0.1

