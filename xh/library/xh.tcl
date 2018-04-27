package require tdom 0.7.7

namespace eval xh {}

proc xh::new {} {
    set doc [dom createDocument html]
#    $doc publicId "-//W3C//DTD XHTML 1.0 Transitional//EN"
#    $doc systemId "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"
    $doc publicId "-//W3C//DTD XHTML 1.0 Strict//EN"
    $doc systemId "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict"
    set html [$doc documentElement]
    $html setAttribute xmlns "http://www.w3.org/1999/xhtml"
    return $html
}

proc xh::E {node childType args} {
    set doc [$node ownerDocument]
    set element [$doc createElement $childType]
    $node appendChild $element
    if {$args != {}} {
	if {[llength $args] != 1} {
	    return -code error "xh::E doc node childType <attribute_list>"
	}
	set attl [lindex $args 0]
	if {[llength $attl] % 2 != 0} {
	    return -code error "Nombre impair d'éléments : \"$args\""
	}
	foreach {k v} $attl {
	    $element setAttribute $k $v
	}
    }
    return $element
}

# Pour créer rapidement un emboitement simple
proc xh::Es {node childList} {
    set l [llength $childList]
    if {$l % 2 != 0 || $l == 0} {
	return -code error "Le dernier argument de xh::Es doit être une liste non vide paire"
    }
    foreach {type attributes} $childList {
	set node [xh::E $node $type $attributes]
    }
    return $node
}

proc xh::ET {node childType attributes text} {
    set element [xh::E $node $childType $attributes]
    xh::T $element $text
    return $element
}

proc xh::T {node text} {
    set doc [$node ownerDocument]
    $node appendChild [$doc createText $text]]
}

proc xh::C {node comment} {
    set doc [$node ownerDocument]
    $node appendChild [$doc createComment $comment]]
}

proc xh::output {htmlNode} {
    set doc [$htmlNode ownerDocument]
    return [$doc asXML -indent none -escapeNonASCII -doctypeDeclaration 1]
}

proc xh::toFile {html fileName} {
    if {![string match *.html $fileName]} {
	return -code error "Par sécurité, on impose que le nom fichier set termine par \".html\" ; \"$fileName\" ne convient donc pas."
    }

    set f [open $fileName w]
    fconfigure $f -encoding iso8859-1
    puts -nonewline $f [xh::output $html]
    close $f
}

proc xh::tidy {file} {
    global errorCode
    puts stderr "exec tidy -asxhtml $file > $file.tidy"
    set err [catch {exec tidy -asxhtml $file > $file.tidy} message]
    if {$errorCode != "NONE"} {
	file delete $file.tidy
	return -code error $message
    }
    file rename -force $file $file.original
    file rename -force $file.tidy $file
    return $message
}

namespace eval xh::internal {
    variable J _
    variable DIR [file dirname [info script]]
}

proc xh::internal::readLocalDTD {base_uri system public} {
    variable DIR
    set f [file tail $system]
    set ff [file join $DIR $f]
    if {![file exists $ff]} {return -code error "Missing file \"$f\" in $DIR"}
    set fh [open $ff r] ; set data [read $fh] ; close $fh
    return [list string $base_uri $data] ;# Pour $base_uri, c'est pas clair
}


proc xh::internal::dumpNode {sp node maxlevel} {
    set type [$node nodeType]
    set name [$node nodeName]
    set value [$node nodeValue]
    set childs [$node childNodes]
    set attributes [$node attributes]
    
    puts "$sp[list $type $name $value $node]"
    foreach k $attributes {
	set v [$node getAttribute $k]
	puts "$sp    [list $k $v]"
    }

    if {$maxlevel != -1} {
	incr maxlevel -1
    }
    if {$maxlevel == 0} return
    foreach c $childs {
	dumpNode "$sp  " $c $maxlevel
     }
}

proc xh::internal::headOfName {name father} {
    variable J
    # puts stderr [list headOfName $name $father]
    set i [string first $J $name]
    incr i -1
    set ret [string range $name 0 $i]
    incr i 1
    if {[string range $name $i end] != "$J$father"} {
	return -code error "Problème avec le nom du père (\"[string range $name $i end]\" != \"$J$father\")"
    }
    return $ret
}

proc xh::internal::dumpNodesFirstPass {GNname IDsName fatherName node} {
    variable J
    upvar $GNname GN
    upvar $IDsName IDs

    set type [$node nodeType]

    if {$type == "ELEMENT_NODE"} {
	set name [$node nodeName]
	if {[string first : $name] != -1} {
	    return -code error "Je ne m'attendais pas à un \":\" dans un nom de ELEMENT_NODE (ici \"$name\")"
	}
	if {[string first . $name] != -1} {
	    return -code error "Je ne m'attendais pas à un \".\" dans un nom de ELEMENT_NODE (ici \"$name\")"
	}
	if {[string match \#* $name]} {
	    return -code error "Je ne m'attendais pas à un \"\#\" en début de nom de ELEMENT_NODE (ici \"$name\")"
	}
	set value [$node nodeValue]
	if {$value != {}} {
	    return -code error "Je ne savais pas qu'un ELEMENT_NODE (ici \"$name\") pouvait avoir une value non vide : \"$value\""
	}
	
	if {![info exists IDs($name)]} {
	    set IDs($name) 0
	}
	if {$fatherName == {}} {
	    set nodeName ${name}.$IDs($name)
	} else {
	    set nodeName ${name}.$IDs($name)$J$fatherName
	}
	incr IDs($name)
	set GN($nodeName) $node
	
	set childs [$node childNodes]
	foreach c $childs {
	    dumpNodesFirstPass GN newIDs $nodeName $c
	}
    } else {
	# TEXT_NODE DATA_SECTION_NODE COMMENT_NODE PROCESSING_INSTRUCTION_NODE
	if {[$node childNodes] != {}} {
	    return -code error "Je ne m'attendais pas à ce que le type \"$type\" ait une descendance."
	}
	switch $type {
	    TEXT_NODE {
		set name [$node nodeName]
		if {$name != "\#text"} {
		    return -code error "Je m'attendais à \"\#text\" au lieu de \"$name\" pour un TEXT_NODE"
		}
	    }
	    COMMENT_NODE {
		set name \#comment
	    }
	    DATA_SECTION_NODE  {
		return -code error "type \"$type\" non encore programmé"
	    }
	    PROCESSING_INSTRUCTION_NODE {
		return -code error "type \"$type\" non encore programmé"
	    }
	    default {
		return -code error "type \"$type\" inconnu"
	    }
	}
	if {![info exists IDs($name)]} {
	    set IDs($name) 0
	}
	set nodeName ${name}$IDs($name)$J$fatherName
	incr IDs($name)
	set GN($nodeName) $node
    }
}

proc xh::internal::referencesInversesUniques {Aname Bname} {
    upvar $Aname A
    upvar $Bname B

    if {[info exists B]} {unset B}

    foreach a [array names A] {
	set b $A($a)
	if {[info exists B($b)]} {
	    return -code error "Deux références pour \"$b\" : \"$B($b)\" et \"$a\""
	}
	set B($b) $a
    }
}

proc xh::internal::dumpANode {GNname GNiname nodeName} {
    variable J
    # puts stderr $nodeName

    upvar $GNname GN
    upvar $GNiname GNi

    set node $GN($nodeName)

    set type [$node nodeType]

    set rep "$nodeName \{\n"

    if {$type != "ELEMENT_NODE"} {
	return -code error "dumpNodeV2 is only for ELEMENT_NODE, not for  \"$type\""
    }
    set childs [$node childNodes]
    foreach c $childs {
	append rep "    [headOfName $GNi($c) $nodeName]"
	set ctype [$c nodeType]
	switch $ctype {
	    ELEMENT_NODE {
		if {[$c hasChildNodes]} {
		    append rep " *"
		}
		set attributes [$c attributes]
		if {$attributes == {}} {
		    append rep "\n"
		} elseif {[llength $attributes] == 1} {
		    set k [lindex $attributes 0]
		    set v [$c getAttribute $k]
		    append rep " \{$k $v\}\n" 
		} else {
		    append rep " \{"
		    foreach k $attributes {
			set v [$c getAttribute $k]
			append rep "\n        [list $k $v]"
		    }
		    append rep "\n    \}\n"
		}
	    }
	    TEXT_NODE {
		append rep " \{[$c nodeValue]\}\n"
	    }
	    COMMENT_NODE {
		append rep " \{[$c nodeValue]\}\n"
	    }
	    default {
		# TEXT_NODE DATA_SECTION_NODE COMMENT_NODE PROCESSING_INSTRUCTION_NODE
		puts stderr "NON fait $type"
	    }
	}
    }
    append rep "\}"
    puts $rep
}

proc xh::internal::dumpNodeV2 {GNname GNiname nodeName maxlevel} {
    upvar $GNname GN
    upvar $GNiname GNi

    set node $GN($nodeName)

    set type [$node nodeType]

    if {$type != "ELEMENT_NODE"} {
	return
    }

    if {![$node hasChildNodes]} {
	return
    }

    puts {}
    dumpANode GN GNi $nodeName

    set childs [$node childNodes]
    
    if {$maxlevel != -1} {
	incr maxlevel -1
    }
    if {$maxlevel == 0} return
    foreach c $childs {
	dumpNodeV2 GN GNi $GNi($c) $maxlevel
    }
}

proc xh::dump {node} {
    xh::internal::dumpNodesFirstPass GN DUMMY {} $node
    xh::internal::referencesInversesUniques GN GNi
    xh::internal::dumpNodeV2 GN GNi $GNi($node) -1
}

# pour créer le xhtml à partir de html sous emacs : C-U M-| h2xh
proc xh::uxH {node xhtml} {
    set err [catch {[dom parse <bidon>$xhtml</bidon>] documentElement} branche]
    if {$err} {
	puts stderr $branche
	set fichier /tmp/uxH.[pid]
	set f [open $fichier w]
	fconfigure $f -encoding utf-8
	puts $f <bidon>$xhtml</bidon>
	close $f
	exec emacs $fichier &
	return -code error "Cf. emacs"
    } else {
	foreach child [$branche childNodes] {
	    $node appendChild $child
	}
    }
}

package provide fidev_xh 0.1
