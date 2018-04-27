# $Id: Timak.tcl,v 1.3 2003/01/31 19:35:05 fab Exp $

# 5 avril 2002 (FP)
# swig -stat -tcl8 -namespace alladin_md5.swig

set INCLUDES [list ../../../c/alladin_md5/src $TCLINCLUDEDIR]

set SOURCES(libtcl_alladin_md5) {alladin_md5.c}
set LIBS(libtcl_alladin_md5) [concat $TCLLIB ../../../c/alladin_md5/src/liballadin_md5 $GLOBLIBS(dynload) $GLOBLIBS(math) $GLOBLIBS(c)]

set SOURCES(md5) {mainTcl.c}
set LIBS(md5) [concat ./libtcl_alladin_md5 $LIBS(libtcl_alladin_md5)]

do -create lib libtcl_alladin_md5
do -create program md5
