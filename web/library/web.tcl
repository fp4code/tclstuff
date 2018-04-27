# 4 avril 2003 (FP)

package require struct 1
package require cmdline 1.1
package require htmlparse 0.3

foreach b {hmstart} {
    set OPEN($b) 0; set PCDATA($b) 0; set CLOSE($b) 0; set BR($b) 0
}
foreach b {PCDATA} {
    set OPEN($b) 0; set PCDATA($b) 1; set CLOSE($b) 0; set BR($b) 0
}
foreach b {img} {
    set OPEN($b) 1; set PCDATA($b) 0; set CLOSE($b) 0; set BR($b) 0
}
foreach b {br input link meta} {
    set OPEN($b) 1; set PCDATA($b) 0; set CLOSE($b) 0; set BR($b) 1
}
foreach b {a b i span} {
    set OPEN($b) 1; set PCDATA($b) 0; set CLOSE($b) 1; set BR($b) 0
}
foreach b {body form head h1 h2 h3 h4 html p table td title tr} {
    set OPEN($b) 1; set PCDATA($b) 0; set CLOSE($b) 1; set BR($b) 1
}

proc wawa {&prevBR &html indent node} {
    upvar ${&html} html
    upvar ${&prevBR} prevBR
    global TYPES OPEN PCDATA CLOSE BR
    if {[t keys $node] != "type data"} {
	return -code error "Special node : $node, keys = [t keys $node]"
    }
    set type [t get $node -key type]
    set data [t get $node -key data]
    set TYPES($type) {}
    puts "$indent[list $type $data]"
    if {$OPEN($type)} {
	if {$prevBR || $BR($type)} {
	    append html \n
	}
	set prevBR $BR($type)
	append html "<$type"
	if {$data != {}} {
	    append html " $data"
	}
	if {!$CLOSE($type)} {
	    append html " /"
	}
	append html ">"
    }
    if {$PCDATA($type)} {
	append html "$data"
	set prevBR $BR($type)
    }
    append indent " "
    foreach n [t children $node] {
	wawa prevBR html $indent $n
    }
    if {$CLOSE($type)} {
	append html "</$type>"
	set prevBR $BR($type)
    }
    return $html
}

catch {t destroy}
struct::tree t

proc +bal {tree where type args} {
    global INDEX
    puts [llength $args]
    if {[llength $args] > 2} {
	return -code error "too many arguments"
    }
    if {[llength $args] == 0} {
	set node [$tree insert $where end]
	$tree set $node -key type $type
    }
    set name [lindex $args 0]
    if {$name == {}} {
	set node [$tree insert $where end $type]
    } else {
	set node [$tree insert $where end $name]
    }
    $tree set $node -key type $type
    if {[llength $args] == 2} {
	appbal $tree $node [lindex $args 1]
    }
    return $node
}

proc appbal {tree node list} {
    set string ""
    set first 1
    foreach {k v} $list {
	if {$first} {
	    set first 0
	} else {
	    append string " "
	}
	append string $k=\"$v\"}
    $tree append $node $string
}

proc +txt {tree node string} {
    set pcdata [+bal $tree $node PCDATA {}]
    $tree append $pcdata $string
}

+bal t root      htmlstart htmlstart

+bal t htmlstart html html
appbal t html {xmlns "http://www.w3.org/1999/xhtml" xml:lang "fr" lang "fr"}

+bal t html      head head
+bal t head meta {} {http-equiv "Content-Type" content "text/html; charset=iso-8859-1"}
+bal t head meta {} {http-equiv "imagetoolbar" content "no"}
+bal t head meta {} {name "author" content "Javanti.org - Christian Kohls, Tobias Windbrake"}
+bal t head meta {} {name "publisher" content "Internet-Service Wernecke - http://www.iswernecke.de"}
+bal t head meta {} {name "copyright" content "Javanti.org - Christian Kohls, Tobias Windbrake"}
+bal t head meta {} {name "Content-Language" content "en"}
+bal t head meta {} {name "language" content "en,english"}
+bal t head meta {} {name "keywords" content "elearning,e-learning,Javanti,jtap,elearning development environment,authoring tool,SCORM,CBT,Computer Based Traning,WBT,Web Based Training,authoringtools,selfauthoring tool,content creation,education,educational software,course,course authoring,course authoring tool,course builder,course creation,course development,computer managed instruction,distance learning,online distance learning,collaborative,tool,download,IDE,Traning,University,School,Open Source,Java,XML,Windows,Linux,Mac"}
+bal t head meta {} {name "description" content "Javanti is an Integrated Development Environment (IDE) for eLearning applications. Several assessment types and a collaborative working mode are available. The java-based software is open source and runs on Windows, Linux and Mac."}
+bal t head meta {} {name "Robots" content "index,follow"}
+bal t head meta {} {name "revisit-after" content "3 weeks"}

+bal t head      title title
+bal t title     PCDATA titleContent
+txt t titleContent "Javanti - eLearning Authoring Tool"
+bal t head link {} {rel stylesheet type "text/css" href "../style.css"}

+bal t html body body {leftmargin 0 marginwidth 0 topmargin 0 marginheight 0 rightmargin 0}
+bal t body table t0
+bal t t0 tr t00 {height 150}
+bal t t00 td t000 {colspan 5 valign bottom}
+bal t t000 table t000/0 {border 0 cellpadding 0 cellspacing 0 width 100%}
+bal t t000/0 tr t000/00
+bal t t000/00 td t000/000 {class mittel}
+bal t t000/000 table t000/000/000 {border 0 cellpadding 0 cellspacing 0 width 780}

+bal t body      PCDATA bodyBlabla
+txt t bodyBlabla "blabla..."
+txt t bodyBlabla "blibli..."
+bal t body      h1 h1_1
+txt t h1_1 "Titre niveau 1"
+bal t body      p  p_1
+txt t p_1 "blabla1"
+txt t [+bal t [+bal t p_1 b] i] { Gras Italique }
+txt t p_1 "blabla2"
+bal t body      p  p_2
+txt t p_2 "blabla3"
+bal t body br
+bal t body br
+bal t body      p  p_3
+txt t p_3 "blabla3"

# t walk root -order both -command {puts [list %n %a [t getall %n]] }

# htmlparse::2tree $original t

set prevBR 0
set html ""
append html {<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">}
append html {}
wawa prevBR html "" html

set ff [open ~/Z/t.html w]
puts $ff $html
close $ff
puts stderr "tidy err = [catch {exec tidy /home/fab/Z/t.html > /home/fab/Z/www.javanti.org/en/index2.html} m]"
puts stderr $m

