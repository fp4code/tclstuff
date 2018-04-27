#
# $Id: narray.tcl,v 1.1.1.1 2002/02/18 16:12:25 fab Exp $
#
#
#  NArray - a tcl extension for manipulating multidimensional arrays
#
#  Author: N. C. Maliszewskyj, NIST Center for Neutron Research, August 1998
#          P. Klosowski        NIST Center for Neutron Research
#  Original Author:
#          S. L. Shen          Lawrence Berkeley Laboratory,     August 1994
#
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program; if not, write to the Free Software
#  Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
#
#***************************************************************************
#
#
# This software is copyright (C) 1994 by the Lawrence Berkeley Laboratory.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that: (1) source code distributions
# retain the above copyright notice and this paragraph in its entirety, (2)
# distributions including binary code include the above copyright notice and
# this paragraph in its entirety in the documentation or other materials
# provided with the distribution, and (3) all advertising materials mentioning
# features or use of this software display the following acknowledgement:
# ``This product includes software developed by the University of California,
# Lawrence Berkeley Laboratory and its contributors.'' Neither the name of
# the University nor the names of its contributors may be used to endorse
# or promote products derived from this software without specific prior
# written permission.
# 
# THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY EXPRESS OR IMPLIED
# WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.

# Print a narray on stdout 
#     TODO - find a way to generalize this to n dimensions
proc pnarray na {
    puts -nonewline \
	"$na ([string trim [$na status]], dimensions [list [$na dimensions]]):"
    switch [llength [$na dimensions]] {
	1 {
	    puts ""
	    puts ""
	    $na map { 
		tcl_eval("puts -nonewline {",$[],"}")
	    }
	    puts ""
	}
	2 {    
	    puts ""
	    $na map {
		@1 == 0 ? tcl_eval("puts {}") : 0;
		tcl_eval("puts -nonewline {",$[],"}")
	    }
	    puts ""
	}
	3 {
	    $na map {
		@2 == 0 && @1 == 0 ? tcl_eval("puts {}") : 0;
		@2 == 0 ? tcl_eval("puts {}") : 0;
		tcl_eval("puts -nonewline {",$[],"}")
	    }
	    puts ""
	}
	default {
	    puts stderr "Can only print up to three dimensions"
	}
    }
}

# delete an narray
proc narray_destroy args {
    foreach na $args {
	rename $na ""
    }
}
