# 19 avril 2002 (FP) gds2.0.1.tcl

# syntaxe du fichier

set DEF(<stream_format>) {1-HEADER 1-BGNLIB 1-LIBNAME o-REFLIBS o-FONTS o-ATTRTABLE o-GENERATIONS o-<FormatType> 1-UNITS *-<structure> 1-ENDLIB}
set DEF(<FormatType>)    {1-FORMAT o-<masks>}
set DEF(<masks>)         {+-MASK 1-ENDMASKS}
set DEF(<structure>)     {1-BGNSTR 1-STRNAME o-STRCLASS *-<element> 1-ENDSTR}
set DEF(<element>)       {1-<elementType> *-property 1-ENDEL}
set CHOICE(<elementType>} {<boundary> <path> <SREF> <AREF> <text> <node> <box>}
set DEF(<boundary>) {1-BOUNDARY o-ELFLAGS o-PLEX 1-LAYER 1-DATATYPE                                                      1-XY}
set DEF(<path>)     {1-PATH     o-ELFLAGS o-PLEX 1-LAYER 1-DATATYPE o-PATHTYPE o-WIDTH o-BGNEXTN o-ENDEXTN               1-XY}
set DEF(<SREF>)     {1-SREF     o-ELFLAGS o-PLEX                                             1-SNAME o-<strans>          1-XY}
set DEF(<AREF>)     {1-AREF     o-ELFLAGS o-PLEX                                             1-SNAME o-<strans> 1-COLROW 1-XY}
set DEF(<text>)     {1-TEXT     o-ELFLAGS o-PLEX 1-LAYER 1-TEXTYPE  o-PRESENTATION o-PATHTYPE o-WIDTH o-<strans>         1-XY 1-STRING}
set DEF(<node>)     {1-NODE     o-ELFLAGS o-PLEX 1-LAYER 1-NODETYPE                                                      1-XY}
set DEF(<box>)      {1-BOX      o-ELFLAGS o-PLEX 1-LAYER 1-BOXTYPE                                                       1-XY}
set DEF(<strans>) {1-STRANS o-MAG o-ANGLE}
set DEF(<property>) {1-PROPATTR 1-PROPVALUE}

# syntaxe le la mise en mémoire

set RESERVES {int-2 int-4 bits double string}
set LDEF(lib) {version modif_time access_time name reflibs fonts attrtable generations formattype units structures}
set LDEF(version) int-2
set LDEF(modif_time) {an mois jour heure minute seconde}
set LDEF(access_time) {an mois jour heure minute seconde}
set LDEF(an) int-2
set LDEF(mois) int-2
set LDEF(jour) int-2
set LDEF(heure) int-2
set LDEF(minute) int-2
set LDEF(seconde) int-2
set LDEF(name) string
set LDEF(reflibs) {reflib1 reflib2}
set LDEF(reflib1) string
set LDEF(reflib2) string
set LDEF(fonts) {font1 font2 font3 font4}
set LDEF(attrtable) string
set LDEF(generations) int-2
set LDEF(formattype) int-2
set LDEF(units) {unit1 unit2}
set LDEF(unit1) {double}
set LDEF(unit2) {double}


catch {unset IN}
foreach x [array names DEF] {
    foreach y $DEF($x) {
        if {![regexp {^([1o+*])-(.+)$} $y tout n reste]} {
            return -code error "ERREUR GRAVE dans \"$y\""
        }
        lappend IN($reste) $x
    }
}

namespace eval gds2 {}

set HELP(gds2) {
    9 avril 2002 (FP)
    conforme à GDS-II 5.2
}

set TYPE(0002) HEADER
set TYPE(0102) BGNLIB
set TYPE(0206) LIBNAME
set TYPE(0305) UNITS
set TYPE(0400) ENDLIB
set TYPE(0502) BGNSTR
set TYPE(0606) STRNAME
set TYPE(0700) ENDSTR
set TYPE(0800) BOUNDARY
set TYPE(0900) PATH
set TYPE(0A00) SREF
set TYPE(0B00) AREF
set TYPE(0C00) TEXT
set TYPE(0D02) LAYER
set TYPE(0E02) DATATYPE
set TYPE(0F03) WIDTH
set TYPE(1003) XY
set TYPE(1100) ENDEL
set TYPE(1206) SNAME
set TYPE(1302) COLROW
set TYPE(1400) TEXTNODE=NotUsed
set TYPE(1500) NODE
set TYPE(1602) TEXTTYPE
set TYPE(1701) PRESENTATION
set TYPE(1906) STRING
set TYPE(1A01) STRANS
set TYPE(1B05) MAG
set TYPE(1C05) ANGLE
set TYPE(1F06) REFLIBS
set TYPE(2006) FONTS
set TYPE(2102) PATHTYPE
set TYPE(2202) GENERATIONS
set TYPE(2306) ATTRTABLE
set TYPE(2406) ATYPTABLE=Unreleased 
set TYPE(2502) STRTYPE=Unreleased 
set TYPE(2601) ELFLAGS 
set TYPE(2703) ELKEY=Unreleased
set TYPE(2802) LINKTYPE=Unreleased 
set TYPE(2903) LINKKEYS=Unreleased
set TYPE(2A02) NODETYPE
set TYPE(2B02) PROPATTR
set TYPE(2C06) PROPVALUE
set TYPE(2D00) BOX
set TYPE(2E02) BOXTYPE
set TYPE(2F03) PLEX
set TYPE(3003) BGNEXTN
set TYPE(3103) ENDEXTN
set TYPE(3202) TAPENUM
set TYPE(3302) TAPECODE
set TYPE(3401) STRCLASS
set TYPE(3503) RESERVED=Reserved
set TYPE(3602) FORMAT
set TYPE(3706) MASK
set TYPE(3800) ENDMASKS

foreach x [array names TYPE] {
    set TYPEVAL($TYPE($x)) $x
}

proc gds2::scanFile {file} {
    set file [open $file r]
    fconfigure $file -encoding binary -translation binary
    set stream [read $file]
    close $file
    return [gds2::scanStream $stream]
}

proc gds2::scanStream {stream} {
    set i 0
    set status preHEADER
    set last [string length $stream]
    while {$i != {} && $i < $last} {
        set i [gds2::scanRecord lib status $stream $i]
    }
    return $lib(LIB)
}

proc gds2::scanRecord {libName statusName stream i} {
    upvar $libName lib
    upvar $statusName status
    global TYPE
    set j [expr {$i + 3}]
    binary scan [string range $stream $i $j] SS length type
    if {$type == 0} {
        return {}
    }
    set next [expr {$i + $length}]
    incr j
    set datatype [expr {$type & 0x3f}]
    set typename $TYPE([format %04X $type])
    # puts stderr "$typename $i"
    set data [string range $stream $j [expr {$next-1}]]
    if {$datatype == 0} {
        set data {}
    } elseif {$datatype == 2} {
        set data [gds2::scan2 $data]
    } elseif {$datatype == 3} {
        set data [gds2::scan3 $data]
    } elseif {$datatype == 5} {
        set data [gds2::scan5 $data]
    } elseif {$datatype == 6} {
        set data [gds2::scan6 $data]
    } else {
        puts stderr "********** $typename ($length)"
    }
    # puts stderr [array names lib]
    while {[gds2::interprete lib status $i $typename $data]} {}
    return $next
}

proc gds2::scan1 {s} {
    set n [string length $s]
    set list [list]
    for {set i 0} {$i < $n} {incr i} {
        binary scan [string index $s $i] B8 x
        lappend list $x
    }
    return $list
}

proc gds2::scan2 {s} {
    set n [expr {[string length $s]/2}]
    binary scan $s S$n list
    return $list
}

proc gds2::scan3 {s} {
    set n [expr {[string length $s]/4}]
    binary scan $s I$n list
    return $list
}

proc gds2::scan5 {s} {
    set len [string length $s]
    set n [expr {$len/8}]
    set list [list]
    for {set i 0} {$i < $len} {incr i 8} {
        binary scan [string range $s $i [expr {$i+7}]] cc7 e m
        # puts stderr "$e ; $m"
        if {$e >> 7} {
            set sign -1
        } else {
            set sign 1
        }
        set e [expr {($e & 0x7f) - 64}]
        if {[lindex $m 0] == 0} {
            return -code error "denormalised 8-byte real"
        }
        set x 0.0
        for {set j 6} {$j >= 0} {incr j -1} {
            set ix [lindex $m $j]
            if {$ix < 0} {
                incr ix 256
            }
            set x [expr {$x/256. + $ix}]
            # puts stderr "$ix $x"
        }
        set x [expr {$sign*$x/256.*pow(16., $e)}]
        lappend list $x
    }
    # puts stderr "list = $list"
    return $list
}

proc gds2::scan6 {s} {
    if {[string index $s end] == "\0"} {
        set s [string range $s 0 end-1]
    }
    return $s
}

proc gds2::interprete {libName statusName i typename data} {
    upvar $libName lib
    upvar $statusName status
    # puts stderr "=== $i $status $typename"
    set status0 [lindex $status 0]
    switch $status0 {
        preHEADER {
            if {$typename != "HEADER"} {
                return -code error [list ERROR $i $status $typename]
            }
            set lib(LIB) [list $data]
            set status preBGNLIB
            return 0
        }
        preBGNLIB {
            if {$typename != "BGNLIB"} {
                return -code error [list ERROR $i $status $typename]
            }
            if {[llength $data] != 12} {
                return -code error "ERROR $i $typename : \[llength \$data\] == [llength $data] != 12"
            }
            lappend lib(LIB) [lrange $data 0 5] [lrange $data 6 11]
            set status preLIBNAME
            return 0
        }
        preLIBNAME {
            if {$typename != "LIBNAME"} {
                return -code error [list ERROR $i $status $typename]
            }
            lappend lib(LIB) $data
            set status postLIBNAME
            return 0
        }
        postLIBNAME {
            set lib(REFLIBS) {}
            set lib(FONTS) {}
            set lib(ATTRTABLE) {}
            set lib(GENERATIONS) {}
            set lib(FormatType) {}
            set lib(structures) [list]
            switch $typename {
                REFLIBS {
                    set status preREFLIBS
                    return 1
                }
                FONTS {
                    set status preFONTS
                    return 1
                }
                ATTRTABLE {
                    set status preATTRTABLE
                    return 1
                }
                GENERATIONS {
                    set status preGENERATIONS
                    return 1
                }
                FORMAT {
                    set status preFormatType
                    return 1
                }
                UNITS {
                    set status preUNITS
                    return 1
                }
                default {
                    return -code error [list ERROR $i $status $typename]
                }
            }
        }
        postREFLIBS {
            lappend lib(LIB) {}
            switch $typename {
                FONTS {
                    set status preFONTS
                    return 1
                }
                ATTRTABLE {
                    set status preATTRTABLE
                    return 1
                }
                GENERATIONS {
                    set status preGENERATIONS
                    return 1
                }
                FORMAT {
                    set status preFormatType
                    return 1
                }
                UNITS {
                    set status preUNITS
                    return 1
                }
                default {
                    return -code error [list ERROR $i $status $typename]
                }
            }
        }
        postFONTS {
            switch $typename {
                ATTRTABLE {
                    set status preATTRTABLE
                    return 1
                }
                GENERATIONS {
                    set status preGENERATIONS
                    return 1
                }
                FORMAT {
                    set status preFormatType
                    return 1
                }
                UNITS {
                    set status preUNITS
                    return 1
                }
                default {
                    return -code error [list ERROR $i $status $typename]
                }
            }
        }
        postATTRTABLE {
            switch $typename {
                GENERATIONS {
                    set status preGENERATIONS
                    return 1
                }
                FORMAT {
                    set status preFormatType
                    return 1
                }
                UNITS {
                    set status preUNITS
                    return 1
                }
                default {
                    return -code error [list ERROR $i $status $typename]
                }
            }
        }
        postGENERATIONS {
            switch $typename {
                FORMAT {
                    set status preFormatType
                    return 1
                }
                UNITS {
                    set status preUNITS
                    return 1
                }
                default {
                    return -code error [list ERROR $i $status $typename]
                }
            }            
        }
        preREFLIBS {
            if {$typename != "REFLIBS"} {
                return -code error [list ERROR $i $status $typename]
            }
            puts stderr "Nothing be done with REFLIBS"
            set lib(REFLIBS) {}
            set status postREFLIBS
            return 0
        }
        preFONTS {
            if {$typename != "FONTS"} {
                return -code error [list ERROR $i $status $typename]
            }
            puts stderr "Nothing be done with FONTS"
            set lib(FONTS) {}
            set status postFONTS
            return 0
        }
        preATTRTABLE {
            if {$typename != "ATTRTABLE"} {
                return -code error [list ERROR $i $status $typename]
            }
            puts stderr "Nothing be done with ATTRTABLE"
            set lib(ATTRTABLE) {}
            set status postATTRTABLE
            return 0
        }
        preGENERATIONS {
            if {$typename != "GENERATIONS"} {
                return -code error [list ERROR $i $status $typename]
            }
            puts stderr "Nothing be done with GENERATIONS"
            set status postGENERATIONS
            return 0
        }
        preFormatType {
            if {$typename != "FORMAT"} {
                return -code error [list ERROR $i $status $typename]
            }
            set status postFORMAT
            return 0            
        }
        postFORMAT {
            if {$typename == "MASK"} {
                set status preMASK
                return 1
            } else {
                set status postFormatType
                return 0
            }
        }
        postMASK {
            if {$typename == "MASK"} {
                set status preMASK
                return 1
            } else {
                set status preENDMASKS
                return 0
            }            
        }
        preMASK {
            if {$typename != "MASK"} {
                return -code error [list ERROR $i $status $typename]
            }
            puts stderr "Nothing done for $typeName"
            set status postMASK
            return 0 
        }
        preENDMASKS {
            if {$typename != "ENDMASKS"} {
                return -code error [list ERROR $i $status $typename]
            }
            puts stderr "Nothing done for $typeName"
            set status postFormatType
            return 0
        }
        postFormatType {
            puts stderr "Nothing done for FORMAT"            
            lappend lib(LIB) {}
            set status preUNITS
            return 1
        }
        preUNITS {
            if {$typename != "UNITS"} {
                return -code error [list ERROR $i $status $typename]
            }
            if {[llength $data] != 2} {
                return -code error "ERROR $i $typename : \[llength \$data\] == [llength $data] != 2"
            }
            set lib(UNITS) $data
            set status postUNITS
            return 0
        }
        postUNITS {
            if {$typename == "ENDLIB"} {
                lappend lib(LIB) $lib(REFLIBS) $lib(FONTS) $lib(ATTRTABLE) $lib(GENERATIONS) $lib(FormatType) $lib(UNITS) $lib(structures)
                unset lib(REFLIBS) lib(FONTS) lib(ATTRTABLE) lib(GENERATIONS) lib(FormatType) lib(structures) lib(UNITS)
                puts stderr "*** [array names lib]"
                set status postENDLIB
                return 0
            } else {
                if {$typename != "BGNSTR"} {
                    return -code error [list ERROR $i $status $typename]
                }
                if {[llength $data] != 12} {
                    return -code error "ERROR $i $typename : \[llength \$data\] == [llength $data] != 12"
                }
                set lib(modif_time) [lrange $data 0 5]
                set lib(access_time) [lrange $data 6 11]
                set status preSTRNAME
                return 0
            }
        }
        preSTRNAME {
            if {$typename != "STRNAME"} {
                return -code error [list ERROR $i $status $typename]
            }
            if {[info exists structures($data)]} {
                return -code error "ERROR $i : répétition de la structure \"$data\""
            }
            set structures($data) {}
            set lib(STRNAME) $data
            set lib(boundary) [list]
            set lib(path) [list]
            set lib(SREF) [list]
            set lib(AREF) [list]
            set lib(text) [list]
            set lib(node) [list]
            set lib(box) [list]

            set lib(structure) [list $lib(modif_time) $lib(access_time)]
            unset lib(modif_time) lib(access_time)

            set status postSTRNAME
            return 0
        }
        postSTRNAME {
            if {$typename == "ENDSTR"} {
                lappend lib(structure) $lib(STRNAME) $lib(boundary) $lib(path) $lib(SREF) $lib(AREF) $lib(text) $lib(node) $lib(box)
                lappend lib(structures) $lib(structure)
                unset lib(STRNAME) lib(boundary) lib(path) lib(SREF) lib(AREF) lib(text) lib(node) lib(box) lib(structure)
                set status postUNITS
                return 0
            } else {
                set status preElement
                return 1
            }
        }
        preElement {
            switch $typename {
                BOUNDARY {
                    set status [list postElementChoice boundary]
                    return 0
                }
                PATH {
                    set status [list postElementChoice path]
                    return 0
                }
                SREF {
                    set status [list postElementChoice SREF]
                    return 0
                }
                AREF {
                    set status [list postElementChoice AREF]
                    return 0
                }
                TEXT {
                    set status [list postElementChoice text]
                    return 0
                }
                NODE {
                    set status [list postElementChoice node]
                    return 0
                }
                BOX {
                    set status [list postElementChoice box]
                    return 0
                }
                default {
                    return -code error [list ERROR $i $status $typename]
                }
            }
        }
        postElementChoice {
            set status1 [lindex $status 1]
            switch $typename {
                ELFLAGS {
                    set status [list preELFLAGS $status1]
                    return 1
                }
                PLEX {
                    set lib(ELFLAGS) {}
                    set status [list prePLEX $status1]
                    return 1   
                }
                default {
                    set lib(ELFLAGS) {}
                    set lib(PLEX) {}
                    set status [list postPLEX $status1]
                    return 1
                }
            }
        }
        postELFLAGS {
            set status1 [lindex $status 1]
            switch $typename {
                PLEX {
                    set status [list prePLEX $status1]
                    return 1
                }
                default {
                    set lib(PLEX) {}
                    set status [list postPLEX $status1]
                    return 0
                }
            }
        }
        postPLEX {
            set status1 [lindex $status 1]
            switch $status1 {
                boundary {
                    set status [list preLAYER $status1]
                    return 1
                }
                path {
                    set status [list preLAYER $status1]
                    return 1
                }
                text {
                    set status [list preLAYER $status1]
                    return 1
                }
                node {
                    set status [list preLAYER $status1]
                    return 1
                }
                box {
                    set status [list preLAYER $status1]
                    return 1
                }
                SREF {
                    set status [list preSNAME $status1]
                    return 1
                }
                AREF {
                    set status [list preSNAME $status1]
                    return 1
                }
                default {
                    return -code error [list ERROR $i $status $typename]
                }
            }
        }
        preELFLAGS {
            set status1 [lindex $status 1]
            if {$typename != "ELFLAGS"} {
                return -code error [list ERROR $i $status $typename]
            }
            set lib(ELFLAGS) $data
            set status [list postELFLAGS $status1]
            return 0
        }
        prePLEX {
            set status1 [lindex $status 1]
            if {$typename != "PLEX"} {
                return -code error [list ERROR $i $status $typename]
            }
            set lib(PLEX) $data
            set status [list postPLEX $status1]
            return 0
        }
        preLAYER {
            set status1 [lindex $status 1]
            if {$typename != "LAYER"} {
                return -code error [list ERROR $i $status $typename]
            }
            set lib(LAYER) $data
            set status [list postLAYER $status1]
            return 0
        }
        postLAYER {
            set status1 [lindex $status 1]
            switch $status1 {
                boundary {
                    set status [list preDATATYPE $status1]
                    return 1
                }
                path {
                    set status [list preDATATYPE $status1]
                    return 1
                }
                text {
                    set status [list preTEXTTYPE $status1]
                    return 1
                }
                node {
                    set status [list preNODETYPE $status1]
                    return 1
                }
                box {
                    set status [list preBOXTYPE $status1]
                    return 1
                }
                default {
                    return -code error [list ERROR $i $status $typename]
                }
            }
        }
        preDATATYPE {
            set status1 [lindex $status 1]
            if {$typename != "DATATYPE"} {
                return -code error [list ERROR $i $status $typename]                
            }
            set lib(DATATYPE) $data
            switch $status1 {
                boundary {
                    set status [list preXY $status1]
                    return 0
                }
                path {
                    set status prePATHTYPElib(WIDTH)
                    return 0
                }
                default "Programming error, unknown status \"$status\""
            }
        }
        preXY {
            set status1 [lindex $status 1]
            if {$typename != "XY"} {
                return -code error [list ERROR $i $status $typename]                
            }
            switch $status1 {
                boundary {
                    set lib(element) [list $status1 $lib(ELFLAGS) $lib(PLEX) $lib(LAYER) $lib(DATATYPE) $data]
                    unset lib(ELFLAGS) lib(PLEX) lib(LAYER) lib(DATATYPE)
                    set lib(property) [list]
                    set status postElementDefinition
                    return 0
                }
                path {
                    set lib(element) [list $status1 $lib(ELFLAGS) $lib(PLEX) $lib(LAYER) $lib(DATATYPE\)
                            $lib(PATHTYPE) $lib(WIDTH) $lib(BGNEXTN) $lib(ENDEXTN) $data]
                    unset lib(ELFLAGS) lib(PLEX) lib(LAYER) lib(DATATYPE) lib(PATHTYPE) lib(WIDTH) lib(BGNEXTN) lib(ENDEXTN)
                    set lib(property) [list]
                    set status postElementDefinition
                    return 0
                }
                SREF {
                    set lib(element) [list $status1 $lib(ELFLAGS) $lib(PLEX) $lib(SNAME) $lib(STRANS) $data]
                    unset lib(ELFLAGS) lib(PLEX) lib(SNAME) lib(STRANS)
                    set lib(property) [list]
                    set status postElementDefinition
                    return 0
                }
                AREF {
                    set lib(element) [list $status1 $lib(ELFLAGS) $lib(PLEX) $lib(SNAME) $lib(STRANS) $lib(COLROW) $data]
                    unset lib(ELFLAGS) lib(PLEX) lib(SNAME) lib(STRANS) lib(COLROW)
                    set lib(property) [list]
                    set status postElementDefinition
                    return 0
                }
            }
        }
        postElementDefinition {
            switch $typename {
                PROPATTR {
                    lappend lib(property) data
                    set status prePROPVALUE
                    return 0
                }
                ENDEL {
                    lappend lib(element) $lib(property)
                    unset lib(property)
                    lappend lib([lindex $lib(element) 0]) [lrange $lib(element) 1 end]
                    unset lib(element)
                    set status postSTRNAME
                    return 0
                }
            }
        }
        prePROPVALUE {
            if {$typename != "PROPVALUE"} {
                return -code error [list ERROR $i $status $typename]
            }
            lappend lib(property) $data
            set status postElementDefinition
            return 0
        }
        preSNAME {
            if {$typename != "SNAME"} {
                return -code error [list ERROR $i $status $typename]
            }
            set lib(SNAME) $data
            set status [list postSNAME [lindex $status 1]]
            return 0
        }
        postSNAME {
            if {$typename != "STRANS"} {
                set lib(STRANS) {}
                set status [list postStrans [lindex $status 1]]
                return 1
            } else {
                set lib(STRANS) [list $data]
                set status [list postSTRANS [lindex $status 1]]
                return 0
            }
        }
        preSTRANS {
            
        }
        postSTRANS {
            if {$typename != "MAG"} {
                lappend lib(STRANS) {}
                set status [list postMAG [lindex $status 1]]
                return 1
            } else {
                lappend lib(STRANS) $data
                set status [list postMAG [lindex $status 1]]
                return 0
            }
        }
        postMAG {
            if {$typename != "ANGLE"} {
                lappend lib(STRANS) {}
                set status [list postStrans [lindex $status 1]]
                return 1
            } else {
                lappend lib(STRANS) $data
                set status [list postStrans [lindex $status 1]]
                return 0
            }
        }
        postStrans {
            set status1 [lindex $status 1]
            switch $status1 {
                SREF {
                    set status [list preXY $status1]
                    return 1
                }
                AREF {
                    set status [list preCOLROW $status1]
                    return 1
                }
                default {
                    return -code error "Programming error, unknown status \"$status\""
                }
            }
        }
        preTEXTTYPE {
            if {$typename != "TEXTTYPE"} {
                return -code error [list ERROR $i $status $typename]
            }
            set LIB(TEXTTYPE) $data
            set status [list postTEXTTYPE]
            return 0
        }
        postTEXTTYPE {
            switch $typename {
                PRESENTATION {
                    set status prePRESENTATION
                    return 1
                }
                PATHTYPE {
                    set status prePATHTYPE
                    return 1   
                }
                WIDTH {
                    set status preWIDTH
                    return 1
                }
                STRANS {
                    set lib(PRESENTATION) {}
                    set lib(PATHTYPE) {}
                    set lib(WIDTH) {}
                    if {$typename != "STRANS"} {
                        set lib(STRANS) {}
                        set status [list XY text]
                        return 1
                    } else {
                        set lib(STRANS) [list $data]
                        set status [list XY text]
                        return 0
                    }
                }
                set status [list preXY text]
            }
        }
        default {
            puts stderr "Programming error, unknown status \"$status\""
            exit 2
        }
    }
    return -code error "Programming error, no return before [list $i $status $typename]"
}

proc gds2::formatLib {lib} {
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
    set gds2 ""
    append gds2 [gds2::formatHEADER $version]
    append gds2 [gds2::formatBGNLIB $modif_time $access_time]
    append gds2 [gds2::formatLIBNAME $name]
    if {$reflibs != {}} {
        append gds2 [gds2::formatREFLIBS $reflibs]
    }
    if {$fonts != {}} {
        append gds2 [gds2::formatFONTS $fonts]
    }
    if {$attrtable != {}} {
        append gds2 [gds2::formatATTRTABLE $attrtable]
    }
    if {$generations != {}} {
        append gds2 [gds2::formatGENERATIONS $generations]
    }
    if {$formattype != {}} {
        append gds2 [gds2::formatFormattype $formattype]
    }
    append gds2 [gds2::formatUNITS $units]
    foreach structure $structures {
        append gds2 [gds2::formatStructure $structure]
    }
    append gds2 [gds2::formatENDLIB]
    set len [string length $gds2]
    set padlen [expr {$len%2048}]
    if {$padlen != 0} {
        set padlen [expr {2048-$padlen}]
    }
    while {$padlen > 0} {
        append gds2 \0
        incr padlen -1
    }
    return $gds2
}

proc gds2::formatHEADER {version} {
    global TYPEVAL
    return [gds2::formatRecord $TYPEVAL(HEADER) $version]
}

proc gds2::formatBGNLIB {modif_time access_time} {
    global TYPEVAL
    set data [concat $modif_time $access_time]
    return [gds2::formatRecord $TYPEVAL(BGNLIB) $data]
}

proc gds2::formatLIBNAME {name} {
    global TYPEVAL
    return [gds2::formatRecord $TYPEVAL(LIBNAME) $name]
}

proc gds2::formatUNITS {units} {
    global TYPEVAL
    return [gds2::formatRecord $TYPEVAL(UNITS) $units]
}

proc gds2::formatStructure {structure} {
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

    set gds2 ""
    append gds2 [gds2::formatBGNSTR $modif_time $access_time]
    append gds2 [gds2::formatSTRNAME $name]
    foreach boundary $boundaries {
        append gds2 [gds2::formatBoundary $boundary]
    }
    foreach path $paths {
        append gds2 [gds2::formatPath $path]
    }
    foreach sref $srefs {
        append gds2 [gds2::formatSref $sref]
    }
    foreach aref $arefs {
        append gds2 [gds2::formatAref $aref]
    }
    foreach text $texts {
        append gds2 [gds2::formatText $text]
    }
    foreach node $nodes {
        append gds2 [gds2::formatNode $node]
    }
    foreach box $boxes {
        append gds2 [gds2::formatBox $box]
    }
    append gds2 [gds2::formatENDSTR]
    return $gds2
}

proc gds2::formatBGNSTR {modif_time access_time} {
    global TYPEVAL
    set data [concat $modif_time $access_time]
    return [gds2::formatRecord $TYPEVAL(BGNSTR) $data]
}

proc gds2::formatSTRNAME {name} {
    global TYPEVAL
    return [gds2::formatRecord $TYPEVAL(STRNAME) $name]
}

proc gds2::formatBoundary {boundary} {
    verifLength boundary 6
    set elflags    [lindex $boundary 0]
    set plex       [lindex $boundary 1]
    set layer      [lindex $boundary 2]
    set datatype   [lindex $boundary 3]
    set xy         [lindex $boundary 4]
    set properties [lindex $boundary 5]
    set gds2 ""
    append gds2 [gds2::formatBOUNDARY]
    if {$elflags != {}} {
        append gds2 [gds2::formatELFLAGS $elflags]
    }
    if {$plex != {}} {
        append gds2 [gds2::formatPLEX $plex]
    }
    append gds2 [gds2::formatLAYER $layer]
    append gds2 [gds2::formatDATATYPE $datatype]
    append gds2 [gds2::formatXY $xy]
    foreach property $properties {
        append gds2 [gds2::formatProperty $property]
    }
    append gds2 [gds2::formatENDEL]
    return $gds2
}

proc gds2::formatBOUNDARY {} {
    global TYPEVAL
    return [gds2::formatRecord $TYPEVAL(BOUNDARY) {}]
}

proc gds2::formatLAYER {layer} {
    global TYPEVAL
    return [gds2::formatRecord $TYPEVAL(LAYER) $layer]
}

proc gds2::formatDATATYPE {datatype} {
    global TYPEVAL
    return [gds2::formatRecord $TYPEVAL(DATATYPE) $datatype]
}

proc gds2::formatXY {xy} {
    global TYPEVAL
    return [gds2::formatRecord $TYPEVAL(XY) $xy]
}

proc gds2::formatENDEL {} {
    global TYPEVAL
    return [gds2::formatRecord $TYPEVAL(ENDEL) {}]
}

proc gds2::formatENDSTR {} {
    global TYPEVAL
    return [gds2::formatRecord $TYPEVAL(ENDSTR) {}]
}

proc gds2::formatENDLIB {} {
    global TYPEVAL
    return [gds2::formatRecord $TYPEVAL(ENDLIB) {}]
}

proc gds2::verifLength {listName length} {
    upvar $listName list
    if {[llength $list] != $length} {
        puts stderr "bad \"$listName\" length : [llength $list] != $length"
        exit 1
    }
}

proc gds2::formatRecord {type data} {
    set dataType [string range $type 2 3]
    switch $dataType {
        "00" {
            set length 4
            set record [binary format SH4 $length $type]
        }
        "01" {
            return -code error "PROGRAMMING ERROR : dataType = 01"
        }
        "02" {
            set length [expr {4+2*[llength $data]}]
            set record [binary format SH4 $length $type]
            # puts stderr [list data = $data]
            foreach x $data {
                append record [binary format S $x]
            }
        }
        "03" {
            set length [expr {4+4*[llength $data]}]
            set record [binary format SH4 $length $type]
            foreach x $data {
                append record [binary format I $x]
            }
        }
        "05" {
            set length [expr {4+8*[llength $data]}]
            set record [binary format SH4 $length $type]
            foreach x $data {
                append record [gds2::format5 $x]
            }            
        }
        "06" {
            set length [expr {4+[string length $data]}]
            if {$length % 2} {
                incr length
                append data \0
            }
            set record [binary format SH4 $length $type]
            append record $data
        }
        default {
            return -code error "ERROR, formatRecord unknown datatype for type \"$type\""
        }
    }
    return $record
}

proc gds2::format5 {x} {
    if {$x < 0} {
        set sign 1
        set x [expr {-$x}]
    } else {
        set sign 0
    }
    # x est à présent positif
    set e [expr {int(ceil(log($x)/log(16)))}]
    set xn [expr {$x/pow(16,$e)}]
    if {$xn >= 1.0} {
        set xn [expr {$xn/16.}]
        incr e
    } elseif {16.*$xn < 1.0} {
        set xn [expr {$xn*16.}]
        incr e -1
    }
    set e [expr {$e+64}]
    if {$e < 0 || $e > 127} {
        return -code error "ERROR exponent under/overflow for \"$x\""
    }
    if {$sign} {
        set e [expr {0x80 | $e}]
    }
    # puts -nonewline stderr $e
    set s [binary format c $e]
    for {set i 1} {$i < 8} {incr i} {
        set xn [expr {256.*$xn}]
        set xi [expr {floor($xn)}]
        set ixi [expr {int($xi)}]
        # puts -nonewline stderr " $ixi"
        append s [binary format c $ixi]
        set xn [expr {$xn-$xi}]
    }
    # puts stderr {}
    return $s
}

proc gds2::appendStructure {} {}

proc gds2::writeToFile {lib filename} {
    set f [open $filename w]
    fconfigure $f -encoding binary -translation binary
    set s [gds2::formatLib $lib]
    puts -nonewline $f $s
    close $f
}

package provide gds2 0.1
