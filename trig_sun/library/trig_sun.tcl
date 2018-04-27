# RCS: @(#) $Id: trig_sun.tcl,v 1.3 2002/06/25 08:43:05 fab Exp $

fidev_load ../src/libtcl_trig_sun trig_sun

set HELP(trig_sun) {
en degrés :       sind,  cosd,  tand,  asind,  acosd,  atand,  atan2d
en demi-tours :   sinpi, cospi, tanpi, asinpi, acospi, atanpi, atan2pi
trigonométrique : sinp,  cosp,  tanp,  asinp,  acosp,  atanp
}

package provide trig_sun 1.0
