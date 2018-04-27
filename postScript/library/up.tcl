#!/usr/local/bin/tclsh
# up:
# PostScript n-up print utility.  This script takes conforming PS
# files, and prints them n-up, where n is controlled by a symbolic
# name (taken from argv[0] or the command line), and the page
# positioning and scaling are looked up in a configuration file.
#
# usage: up [-n name] [-f config] [file ...]
#
# jgreely@cis.ohio-state.edu, 89/10/23
#

#
# codage en Tcl par FP
#

package require opt

# set the name from $0 (argv[0]), after stripping a path
#
set name [file tail $argv0]
set name "up"

set HOME $env(HOME)
set IDENT _[info hostname]_[pid]

set PAGE 0
set SHEET 0

# set a default prolog in case the config file doesn't have one
# make sure that plines is 2 larger than the number of definitions in
# the prolog (used to get dictionary size).
#
set PROLOG [list]
lappend PROLOG "/inch {72 mul} def"
lappend PROLOG "/moveU {0 11 inch translate} def"
lappend PROLOG "/moveR {8.5 inch 0 translate} def"
lappend PROLOG "/moveD {0 -11 inch translate} def"
lappend PROLOG "/moveL {-8.5 inch 0 translate} def"
lappend PROLOG "/rotR {-90 rotate} def"
lappend PROLOG "/rotL {90 rotate} def"

# search for a configuration file.  The *last* one found is used
#
set config "./up.rc"

set sf [info script]
while {[file type $sf] == "link"} {
    set sf [file readlink $sf]
}

set concon [file join [file dirname $sf] $config]


set search_path [list "/usr/lib/up.rc"\
                      "/usr/local/lib/up.rc"\
                      $concon \
                      "$HOME/.uprc"\
                      "./up.rc"]
puts stderr $search_path
foreach file $search_path {
    if {[file exists $file] && [file readable $file]} {
        set config $file
    }
}

# check for options on command line.
#

::tcl::OptProc parseArgs {
    {-f     {}        "config"}
    {-n     {}          "name"}
    {-shift 0          "shift"}
    {?optarg? -list {} "optional argument"}
} {
    global config name fichier SHIFT
    if {$f != {}} {
        set config $f
    }
    if {$n != {}} {
        set name $n
    }
    set fichier $optarg
    set SHIFT $shift
}

if {[catch {eval parseArgs $argv} toto]} {
    error {usage: up [-f config] [-n name] [-shift n] [file ...]}
}

proc readConfig {config name arrayName} {
    upvar $arrayName PARAMS

    if {[catch {open $config r} file]} {
        error $file
    }
    set lignes [split [read -nonewline $file] "\n"]
    close $file

    set in_rec 0
    set PARAMS(modulus) 0
#puts NAME=$name
    while {$lignes != {}} {
        set l [lindex $lignes 0]
        set lignes [lrange $lignes 1 end]
        if {[regexp {^[ 	]*#|^[ 	]*$} $l]} {
            continue ;# skip comment and blank lines
        } elseif {[regexp {^prolog[ 	]*=} $l]} {
            read_prolog lignes
            continue
        } elseif {[regexp {[ 	]*(.*)=[ 	]*(.*)} $l tout field value]} {
            if {($field == "name") && ($value == $name)} {
#puts "TROUVE $name"
                incr in_rec
            } elseif {$in_rec} {
                set PARAMS($field) $value
#puts "FIELD=$field"
#puts "VALUE=$value"
            }
        } elseif {$in_rec && [regexp {^\.$} $l]} {
#puts BREAK
            break        
        } else {
#puts "RIEN $l"
        }
    }
    if {!$in_rec} {
        error "no such record \"$name\" in file \"$config\", stopped"
    }
    if {!$PARAMS(modulus)} {
        error "invalid modulus == $PARAMS(modulus), stopped"
    } 
}


# read the prolog from the configuration file.	All lines up to the
# the first one starting with '.' will be placed in $PROLOG
#
proc read_prolog {lignesName} {
    upvar $lignesName lignes
    global PROLOG
    set PROLOG [list]
    while {$lignes != {}} {
        set l [lindex $lignes 0]
        set lignes [lrange $lignes 1 end]
        if {[regexp {^\.} $l]} {
            break
        } else {
	    lappend PROLOG $l
	}
    }
}

# print the trailer, which for us consists of a showpage (inserted
# before the trailer comment, to make it part of the last page).
#
proc print_trailer {} {
    global IDENT PAGE
    if {$PAGE} {
        puts "UpDict$IDENT begin UpState restore UpShowpage end"
    }
    puts "%%Trailer"
}

# the prolog consists of simple command definitions you want to make
# available to the configuration routines.  None of them do anything
# complicated, but why make life more difficult for the user?
#
proc print_prologue {} {
    global IDENT PROLOG
    puts "%%BeginProcSet: up_prolog 1 $IDENT"
    puts "/UpDict$IDENT [llength $PROLOG] 3 add dict def"
    puts "UpDict$IDENT begin"
    foreach l $PROLOG {
        puts $l
    }
    puts "/UpShowpage {showpage} bind def"
    puts "/UpState {} def"
    puts "end"
    puts "/showpage {} def"
    puts "%%EndProcSet: up_prolog 1 $IDENT"
}

proc putsIfExists {key} {
    global PARAMS
    if {[info exists PARAMS($key)]} {
        puts $PARAMS($key)
    } else {
        puts "" ;# "% ABSENT : $key"
    }
}

# basically, at the beginning of a page, pull the number from the page
# header, take it modulo $modulus, and print things based on that #
# number.  If it's 1, end the previous sheet (if there is one),
# increment the sheet number, and print a sheet header.	 For all
# pages, print the appropriate page motion command.
#
proc verifPage {l} {
    global PAGE SHIFT
    set oldpage [lindex $l 2]
    if {($oldpage + $SHIFT)!= $PAGE} {
        puts stderr "Warning! page number mismatch : $PAGE"
    }
}

proc enter_page {} {
    global PAGE SHEET IDENT PARAMS
    set modulus $PARAMS(modulus)
    set temp [expr {$PAGE % $modulus}]
    if {$temp == 1} {
        if {$SHEET} {
	    puts "UpDict$IDENT begin UpState restore UpShowpage end"
        }
        incr SHEET
        puts "%%Page: ? $SHEET"
        puts "UpDict$IDENT begin"
        puts "save /UpState exch def"
        if {$SHEET % 2} {
            putsIfExists odd
        } else {
            putsIfExists even
        }
        putsIfExists scale
    } else {
        puts "UpDict$IDENT begin"
    }
    if {!$temp} {
        set temp $modulus
    }
    putsIfExists $temp
    puts end
}


# read relevant section of configuration file.	For complete format
# description, see the provided up.rc file or uprc(5).
#  Basically, read the config file until we find a line containing a
# name field equal to the current name.	 Once we do, read all name-
# value pairs up until a line containing just a '.', placing them all
# into an associative array.
#


readConfig $config $name PARAMS

if {$fichier == {}} {
    set file stdin
} elseif {[catch {open $fichier r} file]} {
    error $file
}

fconfigure $file -buffering line
while {![eof $file]} {
    set l [gets $file]
    if {[regexp {^%!PS} $l]} {
        puts {%!PS-Adobe-2.0}
        puts {%%Pages: (atend)}
        break
    } else {
	error {Not conforming PostScript (no %!PS), stopped}
    }
}

while {![eof $file]} {
    set l [gets $file]
    if {![regexp {^%%} $l]} {
        print_prologue
        puts $l
        break
    } elseif {[regexp {^%%EndComments} $l]} {
        puts $l
        print_prologue
        break
    } else {
    	puts $l
    }
}


while {![eof $file]} {
    set l [gets $file]
    if {[regexp {^%%Pages} $l]} {
        continue
    } elseif {[regexp {^%%Page:} $l]} {
while {$PAGE < $SHIFT} {
        incr PAGE
        enter_page
}
        incr PAGE
        verifPage $l
        enter_page
        continue
    } elseif {[regexp {^%%Trailer} $l]} {
        print_trailer
        continue
    } else {
        puts $l
        continue
    }
}

puts "%%Pages: $SHEET"
exit 0
