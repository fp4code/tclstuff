package require tdom 0.7.7

set data {<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
    "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="fr" lang="us">
<head>
<meta content="HTML Tidy for Linux/x86 (vers 1st December 2002), see www.w3.org"
      name="generator" />
<title>e-é-&egrave;-Physique des Dispositifs/Devices Physics</title>
</head>
<body>
<hq1>Pr&eacute;sentation</hq1>
<p>L'apostrophe, l&#700;apostrophe,  l&#8217;apostrophe,   l&rsquo;apostrophe
</p>
</body>
</html>
}

proc readLocalDTD {base_uri system public} {
    set f [file tail $system]
    if {![file exists $f]} {return -code error "Missing file $f in [pwd]]"}
    set ff [open $f r] ; set data [read $ff] ; close $ff
    return [list string $base_uri $data] ;# Pour $base_uri, c'est pas clair
}

# set document [dom parse -html $data]
# set document [dom parse -externalentitycommand readLocalDTD $data]
set parser [expat -paramentityparsing always -externalentitycommand tDOM::extRefHandler]
tdom $parser enable
# tnc $parser enable
$parser parse $data
$parser free

set root [$document documentElement]
$root nodeType
$root nodeName
$root nodeValue
$root childNodes

proc domNodeNum {val} {
    if {![regexp {^domNode0x(.*)$} $val tout reste]} {
	return -code error "bad domNode0x... \"$val\""
    }
    return $reste
}

proc explore {parent} {
    set type [$parent nodeType]
    set name [$parent nodeName]
    set childs [$parent childNodes]

    puts -nonewline "\n[domNodeNum $parent] is a $type node named \"$name\" with"
    if {$childs == {}} {
	puts " no child"
    } else {
	puts -nonewline " child"
	if {[llength $childs] > 1} {
	    puts -nonewline s
	}
	foreach child $childs {puts -nonewline " [domNodeNum $child]"}
	puts {}
    }

    switch $type {
	"ELEMENT_NODE" {

	    set attributes [$parent attributes]
	    
	    if {[llength $attributes]} {
		puts "attributes:"
		foreach attribute $attributes {
		    set aa [lindex $attribute 0] ;# pourquoi le faire ?
		    puts $attribute=\"[$parent getAttribute $aa]\"
		}
	    }
	    
	    foreach child $childs {
		explore $child
	    }
	}
	TEXT_NODE {
	    puts "value=\"[$parent nodeValue]\""
	}
	default return
    }
}

explore $root
puts [$root asHTML -escapeNonASCII]

