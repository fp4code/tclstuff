#!/bin/sh
# \
exec tclsh "$0" ${1+"$@"}

set HELP(gds2dump.0.1.tcl) {
    9 avril 2002 (FP)
    2004-11-03 (FP) ajout de DEBUG
}

package require fidev
package require gds2 0.1

proc verifLength {listName length} {
    upvar $listName list
    if {[llength $list] != $length} {
        puts stderr "bad $listName length : [llength $list] != $length"
        exit 1
    }
}

proc traiteLib {lib} {
    verifLength lib 11
    set version     [lindex $lib 0]
    set modif_time  [lindex $lib 1]
    set access_time [lindex $lib 2]
    set name        [lindex $lib 3]
    set reflibs     [lindex $lib 4]
    set fonts       [lindex $lib 5]
    set attrtable   [lindex $lib 6]
    set generations [lindex $lib 7]
    set formattype  [lindex $lib 8]
    set units       [lindex $lib 9]
    set structures  [lindex $lib 10]
    
    puts "\nLIB"
    puts "modif_time  = $modif_time"
    puts "access_time = $access_time"
    puts "name        = \"$name\""
    puts "reflibs     = $reflibs"
    puts "fonts       = $fonts"
    puts "attrtable   = $attrtable"
    puts "generations = $generations"
    puts "formattype  = $formattype"
    puts "units       = $units"

    foreach structure $structures {
        traiteStructure $structure
    }
}

proc traiteStructure {structure} {
    verifLength structure 10
    set modif_time  [lindex $structure 0]
    set access_time [lindex $structure 1]
    set name        [lindex $structure 2]
    set boundaries  [lindex $structure 3]
    set paths       [lindex $structure 4]
    set srefs       [lindex $structure 5]
    set arefs       [lindex $structure 6]
    set texts       [lindex $structure 7]
    set nodes       [lindex $structure 8]
    set boxes       [lindex $structure 9]

    puts "\nSTR"
    puts "modif_time  = $modif_time"
    puts "access_time = $access_time"
    puts "name        = \"$name\""

    foreach boundary $boundaries {
        traiteBoundary $boundary
    }
    foreach path $paths {
        traitePath $path
    }
    foreach sref $srefs {
        traiteSref $sref
    }
    foreach aref $arefs {
        traiteAref $aref
    }
    foreach text $texts {
        traiteText $text
    }
    foreach node $nodes {
        traiteNode $node
    }
    foreach box $boxes {
        traiteBox $box
    }
}

proc traiteBoundary {boundary} {
    verifLength boundary 6
    set elflags    [lindex $boundary 0]
    set plex       [lindex $boundary 1]
    set layer      [lindex $boundary 2]
    set datatype   [lindex $boundary 3]
    set xy         [lindex $boundary 4]
    set properties [lindex $boundary 5]

    puts "\nBOUNDARY"
    puts "elflags    = $elflags"
    puts "plex       = $plex"
    puts "layer      = $layer"
    puts "datatype   = $datatype"
    puts "xy         = [lrange $xy 0 1]"
    foreach {x y} [lrange $xy 2 end] {
        puts "             $x $y"
    }
    puts "properties = [lrange $properties 0 1]"
    foreach {attr value} [lrange $properties 2 end] {
        puts "             $attr $value"
    }
}

proc traitePath {path} {
    verifLength path 10
    set elflags    [lindex $path 0]
    set plex       [lindex $path 1]
    set layer      [lindex $path 2]
    set datatype   [lindex $path 3]
    set pathtype   [lindex $path 4]
    set width      [lindex $path 5]
    set bgnextn    [lindex $path 6]
    set endextn    [lindex $path 7]
    set xy         [lindex $path 8]
    set properties [lindex $path 9]

    puts "\nPATH"
    puts "elflags    = $elflags"
    puts "plex       = $plex"
    puts "layer      = $layer"
    puts "datatype   = $datatype"
    puts "pathtype   = $pathtype"
    puts "width      = $width"
    puts "bgnextn    = $bgnextn"
    puts "endextn    = $endextn"
    puts "xy         = [lrange $xy 0 1]"
    foreach {x y} [lrange $xy 2 end] {
        puts "             $x $y"
    }
    puts "properties = [lrange $properties 0 1]"
    foreach {attr value} [lrange $properties 2 end] {
        puts "           $attr $value"
    }
}

proc traiteSref {sref} {
    verifLength sref 6
    set elflags    [lindex $sref 0]
    set plex       [lindex $sref 1]
    set sname      [lindex $sref 2]
    set strans     [lindex $sref 3]
    set xy         [lindex $sref 4]
    set properties [lindex $sref 5]

    puts "\nSREF"
    puts "elflags    = $elflags"
    puts "plex       = $plex"
    puts "sname      = $sname"
    puts "strans     = $strans"
    puts "xy         = [lrange $xy 0 1]"
    foreach {x y} [lrange $xy 2 end] {
        puts "           $x $y"
    }
    puts "properties = [lrange $properties 0 1]"
    foreach {attr value} [lrange $properties 2 end] {
        puts "           $attr $value"
    }
}

proc traiteAref {aref} {
    verifLength aref 7
    set elflags    [lindex $aref 0]
    set plex       [lindex $aref 1]
    set sname      [lindex $aref 2]
    set strans     [lindex $aref 3]
    set colrow     [lindex $aref 4]
    set xy         [lindex $aref 5]
    set properties [lindex $aref 6]

    puts "\nAREF"
    puts "elflags  = $elflags"
    puts "plex     = $plex"
    puts "sname    = $sname"
    puts "strans   = $strans"
    puts "colrow   = $colrow"
    puts "xy       = [lrange $xy 0 1]"
    foreach {x y} [lrange $xy 2 end] {
        puts "           $x $y"
    }
    puts "properties = [lrange $properties 0 1]"
    foreach {attr value} [lrange $properties 2 end] {
        puts "           $attr $value"
    }
}

proc traiteText {text} {
    verifLength text 11
    set elflags      [lindex $text 0]
    set plex         [lindex $text 1]
    set layer        [lindex $text 2]
    set texttype     [lindex $text 3]
    set presentation [lindex $text 4]
    set pathtype     [lindex $text 5]
    set width        [lindex $text 6]
    set strans       [lindex $text 7]
    set xy           [lindex $text 8]
    set string       [lindex $text 9]
    set properties   [lindex $text 10]

    puts "\nTEXT"
    puts "elflags    = $elflags"
    puts "plex       = $plex"
    puts "layer      = $layer"
    puts "texttype   = $texttype"
    puts "present.   = $present."
    puts "pathtype   = $pathtype"
    puts "width      = $width"
    puts "strans     = $strans"
    puts "xy         = [lrange $xy 0 1]"
    foreach {x y} [lrange $xy 2 end] {
        puts "             $x $y"
    }
    puts "string     = \"$string\""
    puts "properties = [lrange $properties 0 1]"
    foreach {attr value} [lrange $properties 2 end] {
        puts "           $attr $value"
    }
}
  
proc traiteNode {node} {
    verifLength node 6
    set elflags    [lindex $node 0]
    set plex       [lindex $node 1]
    set layer      [lindex $node 2]
    set nodetype   [lindex $node 3]
    set xy         [lindex $node 4]
    set properties [lindex $node 5]

    puts "\nNODE"
    puts "elflags    = $elflags"
    puts "plex       = $plex"
    puts "layer      = $layer"
    puts "nodetype   = $nodetype"
    puts "xy         = [lrange $xy 0 1]"
    foreach {x y} [lrange $xy 2 end] {
        puts "             $x $y"
    }
    puts "properties = [lrange $properties 0 1]"
    foreach {attr value} [lrange $properties 2 end] {
        puts "           $attr $value"
    }
}

proc traiteBox {box} {
    verifLength box 6
    set elflags    [lindex $box 0]
    set plex       [lindex $box 1]
    set layer      [lindex $box 2]
    set boxtype    [lindex $box 3]
    set xy         [lindex $box 4]
    set properties [lindex $box 9]

    puts "\nBOX"
    puts "elflags    = $elflags"
    puts "plex       = $plex"
    puts "layer      = $layer"
    puts "boxtype    = $boxtype"
    puts "xy         = [lrange $xy 0 1]"
    foreach {x y} [lrange $xy 2 end] {
        puts "             $x $y"
    }
    puts "properties = [lrange $properties 0 1]"
    foreach {attr value} [lrange $properties 2 end] {
        puts "           $attr $value"
    }
}

puts stderr "tcl_interactive = $tcl_interactive"

if {!$tcl_interactive} {
    set good_args 1
    if {$argc == 1} {
	set fifi [lindex $argv 0]
	set DEBUG 0
    } elseif {$argc == 2} {
	if {[lindex $argv 0] != "-D"} {
	    set good_args 0
	}
	set DEBUG 1
	set fifi [lindex $argv 1]
    } else {
	set good_args 0
    }
    if {!$good_args} {
	puts stderr "syntaxe : \"$argv0 fichier\" ou \"$argv0 -D fichier\" "
	exit 1
    }
    set lib [gds2::scanFile $fifi]
    puts stderr "LU"
    set err [catch {gds2::writeToFile $lib ~/Z/t.gds} blabla]
    if {!$err} {
	puts stderr "ECRIT ~/Z/t.gds"
    } else {
	puts stderr $blabla
    }
    traiteLib $lib
    exit 0
} else {
    # set lib [gds2::scanFile /home/fab/A/eggs/tbs2/tbs2.gds2]
    set lib [gds2::scanFile /home/p10admin/prog/dolphin/SparcSolaris/GDSDISPLAY/EXAMPLES/GDS2_Bin/BeforeAwk.gds]
    puts stderr DONE
    # traiteLib $lib
    gds2::writeToFile $lib ~/Z/t.gds
}
