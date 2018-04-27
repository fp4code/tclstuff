## Process this file with automake to produce Makefile.in -*-Makefile-*-

set INCLUDES $TCLINCLUDEDIR

set SOURCES(libtcl_horreur) horreur.c
set    LIBS(libtcl_horreur) $GLOBLIBS(c)
do -create lib libtcl_horreur
