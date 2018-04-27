
package require tdom 0.7.7

namespace eval ::xmlpp {}
namespace eval ::xmlpp::xmlpp_private {}
namespace eval ::xmlpp::material {}

proc ::xmlpp::parse {data} {
    dom parse $data db
    set node [$db documentElement $data]

    if {[$node nodeName] != "physiparams_database"} {
	return -code error "\"[$node nodeName]\" is not a physiparams_database"
    }
    foreach m [$node childNodes] {
	switch [$m nodeName] {
	    "material" {::xmlpp::xmlpp_private::analyse_material $m}
	    "alloy" {::xmlpp::xmlpp_private::analyse_alloy $m}
	    default {
		return -code error "Unknown type \"[$m nodename]\", shold be \"material\" or \"alloy\""
	    }
	}
    }
    $db delete
}

proc ::xmlpp::parse_file {file} {
    set f [open $file r]
    set data [read -nonewline $f]
    close $f
    ::xmlpp::parse $data
}

proc ::xmlpp::xmlpp_private::analyse_simple_param {matname node} {
    set name [getAttribute $node name]
    set value [getAttribute $node value]
    set unit [getAttribute $node unit]
    set explanation [getAttribute $node explanation]
    set ::xmlpp::material::${matname}::EXPLANATION($name) $explanation
    set ::xmlpp::material::${matname}::UNIT($name) $unit
    proc ::xmlpp::material::${matname}::$name {args} [list return [list $value $unit]]
}


proc ::xmlpp::unitFactor {num denom} {
    if {$num != $denom} {
	return -code error "Code not yet written, both units \"$num\" and \"$denom\" should be identical"
    }
    return [expr {1.0}]
}

proc ::xmlpp::xmlpp_private::getAttribute {node attr} {
    set err [catch {$node getAttribute $attr} res]
    if {$err == 0} {
	return $res
    } else {
	set hier "/[$node nodeName]"
	set parent [$node parentNode]
	while {$parent != {}} {
	    set name [$parent nodeName]
	    set hier "/${name}$hier"
	    set parent [$parent parentNode]
	}
	global errorInfo
	return -code error "Error in hierarchy $hier : $res" 
    }
}

proc ::xmlpp::value_in {newUnit valueWithUnit} {
    if {[llength $valueWithUnit] != 2} {
	return -code error "\"$valueWithUnit\" should be \"value unit\""
    }
    set value [lindex $valueWithUnit 0]
    set unit [lindex $valueWithUnit 1]
    set factor [unitFactor $unit $newUnit]
    return [expr {$factor*$value}]
}

proc ::xmlpp::abx_with_units {v1 x v2} {
    if {[llength $v1] != 2} {
	return -code error "Invalid \"value unit\" string \"$v1\""
    }
    if {[llength $v2] != 2} {
	return -code error "Invalid \"value unit\" string \"$v2\""
    }
    if {[lindex $v1 1] != [lindex $v2 1]} {
	return -code error "Unit mismatch between \"$v1\" and \"$v2\""
    }
    return [list [expr {[lindex $v1 0]+$x*[lindex $v2 0]}] [lindex $v1 1]]
}

proc ::xmlpp::xmlpp_private::verif_type {type} {
    switch $type {
	real {return double}
	int {return $type}
	default {return -code error "Type \"$type\" non admis"}
    }
}

proc ::xmlpp::xmlpp_private::replace_var {var type expr} {
    # accrochez-vous... le but est de transformer T en double($T)
    set nol1 {(\A|[^a-zA-Z_])(}
    set nol2 {)($|[^a-zA-Z_0-9])}
    return [regsub -all "$nol1$var$nol2" $expr "\\1${type}(\$\\2)\\3"]
}

proc ::xmlpp::xmlpp_private::analyse_func_param {matname node} {
    set name [getAttribute $node name]
    set unit [getAttribute $node unit]
    set explanation [getAttribute $node explanation]
    set proc ::xmlpp::material::${matname}::$name
    set body [subst -nocommands {
	if {[llength \$args] == 1} {
	    array set priv_array [lindex \$args 0]
	} elseif {[llength \$args] != 0} {
	    return -code error "Argument of \\"$proc\\" should be an even key value list or nothing"
	}
    }]
    set ::xmlpp::material::${matname}::VARIABLES($name) [list]
    set functionseen 0
    foreach var [$node childNodes] {
	if {$functionseen} {
	    return -code error "Error, there is a node \"[$var nodeName]\" after a func_param/function"
	}
	switch [$var nodeName] {
	    variable {
		set varname [getAttribute $var name]
                if {[regexp {[^0-9a-zA-Z_]} $varname tout]} {
                    return -code error "not acceptable char(s) \"$tout\" in variable \"$varname\""
                }
		set varunit [getAttribute $var unit]
		lappend ::xmlpp::material::${matname}::VARIABLES($name) $varname $varunit
		set ::xmlpp::material::${matname}::TYPE(${varname}) [verif_type [getAttribute $var type]]
		append body [subst -nocommands {
		    if {![info exists priv_array(${varname})]} {
			return -code error "missing parameter \\"${varname}\\""
		    }
		    set $varname [xmlpp::value_in $varunit \$priv_array(${varname})]
		}]
	    }
	    function {
		set expr [getAttribute $var expr]
                if {[regexp {[^0-9a-zA-Z_()+\-*/.= ]} $expr tout]} {
                    return -code error "not acceptable char(s) \"$tout\" in function \"$expr\""
                }
		set tclexpr $expr
                foreach {varname varunit} [set ::xmlpp::material::${matname}::VARIABLES($name)] {
		    set tclexpr [replace_var $varname [set ::xmlpp::material::${matname}::TYPE($varname)] $tclexpr]
                }
		
		append body [subst -nocommands {
		    return [list [expr {$tclexpr}] $unit]
		}]
		set functionseen 1
	    }
	    default {
		return -code error "\"[$var nodeName]\" should be \"variable\" or \"function\""
	    }
	}
    }
    set ::xmlpp::material::${matname}::EXPLANATION($name) $explanation
    set ::xmlpp::material::${matname}::UNIT($name) $unit
    proc $proc {args} $body
}

proc ::xmlpp::xmlpp_private::analyse_constraint {matname node} {
    set index [set ::xmlpp::material::${matname}::constraint::NEXT]
    set expr [getAttribute $node expr]
    set tailproc c$index
    set proc ::xmlpp::material::${matname}::constraint::c$index
    set body [subst -nocommands {
	if {[llength \$args] == 1} {
	    array set priv_array [lindex \$args 0]
	} else {
	    return -code error "Argument of \\"$proc\\" should be an even key value list"
	}
    }]
    if {[regexp {[^0-9a-zA-Z_()+\-*/.= ]} $expr tout]} {
	return -code error "not acceptable char(s) \"$tout\" in function \"$expr\""
    }
    # accrochez-vous : on fait prÅÈcÅÈder toutes les variables d'un $
    set tclexpr $expr
    foreach varname [set ::xmlpp::material::${matname}::ELEMENTS] {
	append body [subst -nocommands {
	    if {![info exists priv_array(${varname})]} {
		return -code error "missing parameter \\"${varname}\\""
	    }
	    set $varname \$priv_array(${varname})
	}]
	set tclexpr [replace_var $varname double $tclexpr]
    }
    append body [subst -nocommands {
	return [expr {$tclexpr}]
    }]

    proc $proc args $body
    set ::xmlpp::material::${matname}::CONSTRAINT($tailproc) $expr
    incr ::xmlpp::material::${matname}::constraint::NEXT
}


set AREECRIRE {
    <imaterials imaterials="Al AlAs Ga GaAs"/>

en

    <iparameter name="Eg_Gamma" TeX="E^\Gamma" unit="eV" explanation="gap energy at gamma point">
    <function expr="Al*f_AlAs+Ga*f_GaAs-Al*Ga*(-0.127+1.310*Al)"/>
}

proc ::xmlpp::xmlpp_private::analyse_linear_interpol {matname node} {
    set names [getAttribute $node names]
    foreach name_of_parameter $names {
	set proc ::xmlpp::material::${matname}::$name_of_parameter
	set body [subst -nocommands {
	    # contrÅÙle de la liste d'arguments qui ressemble Å‡ "T {300 K} Al 0.3 Ga 0.7"
	    # et transfert dans le tableau priv_array(T)=300K, priv_array(Al)=0.3 priv_array(Ga)=0.7 
	    if {[llength \$args] == 1} {
		array set priv_array [lindex \$args 0]
	    } else {
		return -code error "Argument of \\"$proc\\" should be an even key value list"
	    }

	    # contrÅÙle des contraintes de stoechiometrie
	    # eval sans risque puisque \$args est une liste et non une chaine interpretable
	    eval ::xmlpp::material::${matname}::constraint::assume_fulfill_all \$args

	    # crÅÈation de la liste restreinte aux ÅÈlÅÈments : "Al 0.3 Ga 0.7"
	    # nettoyage de priv_array de ces ÅÈlÅÈments
	    set dblist [list]
	    foreach {element material} ::xmlpp::material::${matname}::IMATERIAL {
		lappend dblist \$element \$priv_array(\$element)
		unset priv_array(\$element)
	    }
	    set newargs [array get priv_array]

	    # un peu lourd pour rÅÈcupÅÈrer l'unitÅÈ
	    set element [lindex \$dblist 0]
	    set elemat [set ::xmlpp::material::${matname}::IMATERIAL(\$element)]
	    # elemat vaut qqchose du genre "AlAs"
	    set unit [set ::xmlpp::material::\${elemat}::UNIT($name_of_parameter)]
	    # l'unitÅÈ est rÅÈcupÅÈrÅÈe, on peut dÅÈmarrer les calculs
	    set y [list [expr {0.0}] \$unit]
	    set xtot 0.0
	    # on boucle sur "Al 0.3 Ga 0.7"
	    foreach {element x} \$dblist {
		set elemat [set ::xmlpp::material::${matname}::IMATERIAL(\$element)]
		# elemat vaut qqchose du genre "AlAs", on rÅÈcupÅËre la valeur du paramÅËtre de ce matÅÈriau
		set yy [::xmlpp::material::\${elemat}::$name_of_parameter \$newargs]
		set y [::xmlpp::abx_with_units \$y \$x \$yy]
		set xtot [expr {\$xtot+\$x}]
	    }
	    if {abs(\$xtot-1.0)>1e-9} {
		return -code error "Stoechiometry sum = \$xtot != 1.0. Please use func_interpol"
	    }
	    return \$y
	}]
	proc $proc args $body
    }
}

proc ::xmlpp::xmlpp_private::analyse_parabolic_interpol {matname node} {
    set name [getAttribute $node name]
    set bowing [getAttribute $node bowing]
    set unit [getAttribute $node unit]
    set explanation [getAttribute $node explanation]
    set ::xmlpp::material::${matname}::EXPLANATION($name) $explanation
    set ::xmlpp::material::${matname}::UNIT($name) $unit
    set proc ::xmlpp::material::${matname}::$name
    set body [subst -nocommands {
	if {[llength \$args] == 1} {
	    array set priv_array [lindex \$args 0]
	} else {
	    return -code error "Argument of \\"$proc\\" should be an even key value list"
	}
	# eval sans risque puisque \$args est une liste et non une chaine interpretable
	eval ::xmlpp::material::${matname}::constraint::assume_fulfill_all \$args
	set dblist [list]
	foreach element \$::xmlpp::material::${matname}::ELEMENTS {
	    if {[info exists ::xmlpp::material::${matname}::IMATERIAL(\$element)]} {
		lappend dblist \$element \$priv_array(\$element)
	    }
	}
	set newargs [array get priv_array]
	if {[llength \$dblist] != 4} {
	    return -code error "parabolic_interpol is reserved to 2 materials alloy"
	}
	set y [list [expr {-$bowing*[lindex \$dblist 1]*[lindex \$dblist 3]}] $unit]
	set xtot 0.0
	foreach {element x} \$dblist {
	    set elemat [set ::xmlpp::material::${matname}::IMATERIAL(\$element)]
	    set yy [::xmlpp::material::\${elemat}::$name \$newargs]
	    set y [::xmlpp::abx_with_units \$y \$x \$yy]
	    set xtot [expr {\$xtot+\$x}]
	    set xx [expr {\$x*\$xx}]
	}
	set y [::xmlpp::abx_with_units \$y $bowing \$xx]
	
	if {abs(\$xtot-1.0)>1e-9} {
	    return -code error "Stoechiometry sum = \$xtot != 1.0. Please use func_interpol"
	}
	return \$y
    }]
    proc $proc args $body
}

proc ::xmlpp::xmlpp_private::analyse_func_interpol {matname node} {

    # pas_finalise !!

    set name [getAttribute $node name]
    set unit [getAttribute $node unit]
    set explanation [getAttribute $node explanation]
    set proc ::xmlpp::material::${matname}::$name
    set body [subst -nocommands {
	if {[llength \$args] == 1} {
	    array set priv_array [lindex \$args 0]
	} elseif {[llength \$args] != 0} {
	    return -code error "Argument of \\"$proc\\" should be an even key value list or nothing"
	}
    }]
    
    set ::xmlpp::material::${matname}::VARIABLES($name) [list]    
    
    foreach {element material} [array get ::xmlpp::material::${matname}::IMATERIAL] {
	array set v [::xmlpp::get_arguments $material $name]
    }

    foreach argument [array names v] {
	lappend ::xmlpp::material::${matname}::VARIABLES($name) $argument
    }

    set functionseen 0
    foreach var [$node childNodes] {
	if {$functionseen} {
	    return -code error "Error, there is a node \"[$var nodeName]\" after a func_interpol/function"
	}
	switch [$var nodeName] {
	    variable {
		set varname [getAttribute $var name]
                if {[regexp {[^0-9a-zA-Z_]} $varname tout]} {
                    return -code error "not acceptable char(s) \"$tout\" in variable \"$varname\""
                }
		set varunit [getAttribute $var unit]
		lappend ::xmlpp::material::${matname}::VARIABLES($name) $varname $varunit
		set ::xmlpp::material::${matname}::TYPE(${varname}) [verif_type [getAttribute $var type]]
		append body [subst -nocommands {
		    if {![info exists priv_array(${varname})]} {
			return -code error "missing parameter \\"${varname}\\""
		    }
		    set $varname [xmlpp::value_in $varunit \$priv_array(${varname})]
		}]
	    }
	    function {
		# rÅÈcupÅÈration de l'expression
		set expr [getAttribute $var expr]
                if {[regexp {[^0-9a-zA-Z_()+\-*/.= ]} $expr tout]} {
                    return -code error "not acceptable char(s) \"$tout\" in function \"$expr\""
                }

		# remplacement des variables locales
		set tclexpr $expr
                foreach {varname varunit} [set ::xmlpp::material::${matname}::VARIABLES($name)] {
		    set tclexpr [replace_var $varname [set ::xmlpp::material::${matname}::TYPE($varname)] $tclexpr]
                }

		# remplacement des stoechiometries s_Element et des matÅÈriaux m_Material
		# et calcul des paramÅËtres pour chaque matÅÈriau
		foreach {element material} [array get ::xmlpp::material::${matname}::IMATERIAL] {
		    set tclexpr [replace_var s_$element double $tclexpr]
		    set tclexpr [replace_var m_$material double $tclexpr]
		    append body [subst -nocommands {
			set m_$material [::xmlpp::material::\${elemat}::$name \$newargs]
		    }]
		}
	    # eval sans risque puisque \$args est une liste et non une chaine interpretable
	    eval ::xmlpp::material::${matname}::constraint::assume_fulfill_all \$args
		set dblist [list]
		foreach element \$::xmlpp::material::${matname}::ELEMENTS {
		    if {[info exists ::xmlpp::material::${matname}::IMATERIAL(\$element)]} {
			lappend dblist \$element \$priv_array(\$element)
		    }
		}

		set newargs [array get priv_array]
		if {[llength \$dblist] != 4} {
		    return -code error "Code only written for alloy of 2 materials"
		}
		set y [list [expr {-[lindex \$dblist 1]*[lindex \$dblist 3]*($bowing)}] $unit]
		foreach {element x} \$dblist {
		    set yy [::xmlpp::material::[set ::xmlpp::material::${matname}::IMATERIAL(\$element)]::$name \$newargs]
		    set y [::xmlpp::abx_with_units \$y \$x \$yy]
		}
		return \$y
		

		append body [subst -nocommands {
		    return [list [expr {$tclexpr}] $unit]
		}]
		set functionseen 1
	    }
	    default {
		return -code error "\"[$var nodeName]\" should be \"variable\" or \"function\""
	    }
	}
	proc $proc args $body
    }
}

proc ::xmlpp::xmlpp_private::analyse_parameter {matname node} {
    set nodeName [$node nodeName]
    switch $nodeName {
	simple_param {analyse_simple_param $matname $node}
	func_param {analyse_func_param $matname $node}
	default {return -code error "\"[$node nodeName]\" is not simple_param nor func_param"}
    }
}

proc ::xmlpp::xmlpp_private::analyse_interpolated_material {matname node} {
    set nodeName [$node nodeName]
    set element [$node getAttribute element]
    set material [$node getAttribute material]
    set ::xmlpp::material::${matname}::IMATERIAL($element) $material
}


proc ::xmlpp::xmlpp_private::analyse_alloy_parameter {matname node} {
    set nodeName [$node nodeName]
    switch $nodeName {
	simple_param {analyse_simple_param $matname $node}
	func_param {analyse_func_param $matname $node}
	constraint {analyse_constraint $matname $node}
	interpolated_material {analyse_interpolated_material $matname $node}
	linear_interpol {analyse_linear_interpol $matname $node}
	parabolic_interpol {analyse_parabolic_interpol $matname $node}
	func_interpol {analyse_func_interpol $matname $node}
	default {return -code error "\"[$node nodeName] is not a correct inside an alloy"}
    }
}

proc ::xmlpp::xmlpp_private::analyse_alloy {node} {
    set matname [getAttribute $node name]
    namespace eval ::xmlpp::material::$matname {
	variable ELEMENTS
	variable CONSTRAINT
	variable IMATERIAL
	variable BOWING
    }
    namespace eval ::xmlpp::material::${matname}::constraint {
	variable NEXT 1		
    }
    set ::xmlpp::material::${matname}::ELEMENTS [getAttribute $node elements]
    foreach p [$node childNodes] {
	analyse_alloy_parameter $matname $p
    }
    set body [subst -nocommand {
	foreach c [array names ::xmlpp::material::${matname}::CONSTRAINT] {
	    # eval sans risque puisque \$args est une liste et non une chaine interpretable
	    if {![eval ::xmlpp::material::${matname}::constraint::\$c \$args]} {
		return -code error "Constraint \\"\$::xmlpp::material::${matname}::CONSTRAINT(\$c)\\" not fulfilled for material \\"$matname\\" and arguments \\"\$args\\""
	    }
	}
    }]
    proc ::xmlpp::material::${matname}::constraint::assume_fulfill_all {args} $body   
}

proc ::xmlpp::xmlpp_private::analyse_material {node} {
    if {[$node nodeName] != "material"} {
	return -code error "\"[$node nodeName] is not a material"
    }
    set matname [getAttribute $node name]
    namespace eval ::xmlpp::material::$matname {
	variable EXPLANATION
	variable UNIT
	variable VARIABLES
	variable TYPE
    }
    set TYPE "material"
    foreach p [$node childNodes] {
	analyse_parameter $matname $p
    }
}

proc ::xmlpp::get_registred_materials {} {
    set materials [list]
    foreach m [namespace children ::xmlpp::material] {
	set tail [namespace tail $m]
	lappend materials $tail
    }
    return $materials
}

proc ::xmlpp::get_registred_parameters {matname} {
    set parameters [list]
    foreach p [info commands ::xmlpp::material::${matname}::*] {
	lappend parameters [namespace tail $p]
    }
    return $parameters
}

proc ::xmlpp::get_value {matname parameter args} {
    # eval sans risque puisque ne contient que des listes
    return [eval [list ::xmlpp::material::${matname}::${parameter}] $args] 
}

proc ::xmlpp::get_all {matname args} {
    set ret [list]
    foreach p [::xmlpp::get_registred_parameters $matname] {
	set proc ::xmlpp::material::${matname}::$p
	# eval sans risque puisque ne contient que des listes
	lappend ret $p [eval [list $proc] $args]
    }
    return $ret
}

proc ::xmlpp::get_explanation {matname parameter} {
    return [set ::xmlpp::material::${matname}::EXPLANATION($parameter)]
}

proc ::xmlpp::get_unit {matname parameter} {
    return [set ::xmlpp::material::${matname}::UNIT($parameter)]
}

# retorune une liste double "nom1 unite1 nom2 unite2 ..."
proc ::xmlpp::get_arguments {matname parameter} {
    if {[info exists ::xmlpp::material::${matname}::VARIABLES($parameter)]} {
	return [set ::xmlpp::material::${matname}::VARIABLES($parameter)]
    } else {
	return {}
    }
}

set data {<physiparams_database>
<material name="AlAs">
<func_param name="a1c" unit="nm" TeX="a_{1c}" explanation="Lattice parameter">
  <variable name="T" type="real" unit="K" explanation="temperature"/>
  <function expr="0.5661+2.90e-6*(T-300.)" />
</func_param>
<func_param name="Eg_Gamma" TeX="E^{\Gamma}" unit="eV" explanation="gap energy at gamma point">
  <variable name="T" type="real" unit="K" explanation="temperature"/>
  <function expr="3.099 - 0.885e-3*T*T/(T+530.)" />
</func_param>
<simple_param name="deltaso" TeX="\Delta_{so}" value="0.28" unit="eV" explanation="split-off energy"/>
</material>

<material name="GaAs">
<func_param name="a1c" unit="nm" TeX="a_{1c}" explanation="Lattice parameter">
  <variable name="T" type="real" unit="K" explanation="temperature"/>
  <function expr="0.565325+3.88e-6*(T-300.)"/>
</func_param>
<func_param name="Eg_Gamma" TeX="E^{\Gamma}" unit="eV" explanation="gap energy at gamma point">
  <variable name="T" type="real" unit="K" explanation="temperature"/>
  <function expr="1.519 - 0.5405e-3*T*T/(T+204.)" />
</func_param>
<simple_param name="deltaso" TeX="\Delta_{so}" value="0.341" unit="eV" explanation="split-off energy"/>
</material>

<alloy name="AlGaAs" type="binary alloy" elements="Al Ga As">
<constraint expr="Al+Ga==1"/>
<constraint expr="As==1"/>
<interpolated_material element="Al" material="AlAs"/>
<interpolated_material element="Ga" material="GaAs"/>
<linear_interpol names="deltaso foobar"/>
<parabolic_interpol name="a1c" bowing="0.1" unit="nm" TeX="a_{1c}" explanation="Lattice parameter"/>
</alloy>

</physiparams_database>

}

set rien {
<func_interpol name="Eg_Gamma" TeX="E^\Gamma" unit="eV" explanation="gap energy at gamma point">
    <function expr="s_Al*m_AlAs+f_Ga*m_GaAs-f_Al*f_Ga*(-0.127+1.310*f_Al)" />
</func_interpol>
}
xmlpp::parse $data

set rien {
package require xml_physiparams
xmlpp::parseFile ~fab/Z/data.xml
puts [xmlpp::material::GaAs::deltaso]
puts [xmlpp::value_in nm [xmlpp::material::GaAs::a1c {T {300 K}}]]
}

package provide xml_physiparams 0.2
