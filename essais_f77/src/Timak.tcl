## Process this file with automake to produce Makefile.in -*-Makefile-*-

lib_LTLIBRARIES = libessais_f77.la

libessais_f77_la_LDFLAGS = -version-info 1:1:1
libessais_f77_la_SOURCES = interface-c.c fonction-f77.f

bin_PROGRAMS = essai_f77sh
essai_f77sh_SOURCES = essais_f77_main.c
