#!/usr/local/bin/wish

package require fidev
package require -exact l2mGraph 1.2

set g1 [l2mGraph::createGraph .g1]
set g2 [l2mGraph::createGraph .g2]
set b [l2mGraph::boutons .ctrl] ;#  est obligatoire

grid configure  .g1   .g2
grid configure  .ctrl -

l2mGraph::plotSimple $g1 {0 1} {1 10} -tags courbe1
l2mGraph::plotSimple $g1 {0 1} {1 20} -xscale x -yscale y -tags courbe2 -style points
l2mGraph::plotSimple $g1 {0 1} {1 25} -xscale x -yscale y -tags courbe2 -style croix
l2mGraph::plotSimple $g2 {1 2} {1 20} 

l2mGraph::plotWithErrors $g2 {
        {0 1 2}
        {3 4 5}
        {7 8}
        9
        10
        11
        12
        13
    } {
        {1 2}
        {3 4 6}
        {10 11 12}
        {13 14 15}
        20
        {11 12}
        {11 12}
        {15 15}
        {17 18}
    } x1 y1 courbe4

# $g2.c est le canvas Tcl de $g2
$g2.c itemconfigure courbe3 -fill red
$g2 configure -width 500














