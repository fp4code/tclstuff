#
# $Id: pkgIndex.tcl,v 1.1.1.1 2002/02/18 16:12:24 fab Exp $
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

package ifneeded narray 0.81 [list tclPkgSetup $dir narray 0.81 {
    {libNArray.so load narray} {narray.tcl source {pnarray narray_destroy}}}]
