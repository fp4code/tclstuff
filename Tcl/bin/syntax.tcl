package require XOTcl
if {[info command Object] == {}} {
    namespace import xotcl::@ xotcl::Class xotcl::Object xotcl::self xotcl::my
}

Class Tcl_Interpreter


Class Stack
Stack instproc init {} {
    my set stack_list [list]
}

# _clear --
#
#	Clear a stack.
#
# Arguments:
#	name	name of the stack object.
#
# Results:
#	None.

Stack instproc clear {} {
    my set stack_list [list]
    return
}

# peek --
#
#	Retrieve the value of an item on the stack without popping it.
#
# Arguments:
#	name	name of the stack object.
#	count	number of items to pop; defaults to 1
#
# Results:
#	items	top count items from the stack; if there are not enough items
#		to fulfill the request, throws an error.

Stack instproc peek {{count 1}} {
    my instvar stack_list
    if {$count < 1} {
	return -code error "invalid item count $count"
    }

    if {$count > [llength $stack_list]} {
	return -code error "insufficient items on stack to fill request"
    }

    if {$count == 1} {
	# Handle this as a special case, so single item pops aren't listified
	set item [lindex $stack_list end]
	return $item
    }

    # Otherwise, return a list of items
    set result [list]
    for {set i 0} {$i < $count} {incr i} {
	lappend result [lindex $stack_list "end-${i}"]
    }
    return $result
}

# pop --
#
#	Pop an item off a stack.
#
# Arguments:
#	name	name of the stack object.
#	count	number of items to pop; defaults to 1
#
# Results:
#	item	top count items from the stack; if the stack is empty, 
#		returns a list of count nulls.

Stack instproc pop {{count 1}} {
    my instvar stack_list
    if {$count > [llength $stack_list] } {
	return -code error "insufficient items on stack to fill request"
    } elseif {$count < 1} {
	return -code error "invalid item count $count"
    }

    if {$count == 1} {
	# Handle this as a special case, so single item pops aren't listified
	set item [lindex $stack_list end]
	set stack_list [lreplace $stack_list end end]
	return $item
    }

    # Otherwise, return a list of items
    set result [list]
    for {set i 0} {$i < $count} {incr i} {
	lappend result [lindex $stack_list "end-${i}"]
    }

    # Remove these items from the stack
    incr i -1
    set stack_list [lreplace $stack_list "end-${i}" end]
    return $result
}

# push --
#
#	Push an item onto a stack.
#
# Arguments:
#	name	name of the stack object
#	args	items to push.
#
# Results:
#	None.

Stack instproc push {args} {
    my instvar stack_list
    if {[llength $args] == 0} {
	return -code error "wrong # args: should be \"$name push item ?item ...?\""
    }
    foreach item $args {
	lappend stack_list $item
    }
}

# rotate --
#
#	Rotate the top count number of items by step number of steps.
#
# Arguments:
#	name	name of the stack object.
#	count	number of items to rotate.
#	steps	number of steps to rotate.
#
# Results:
#	None.

Stack instproc rotate {count steps} {
    my instvar stack_list
    set len [llength $stack_list]
    if {$count > $len} {
	return -code error "insufficient items on stack to fill request"
    }

    # Rotation algorithm:
    # do
    #   Find the insertion point in the stack
    #   Move the end item to the insertion point
    # repeat $steps times

    set start [expr {$len - $count}]
    set steps [expr {$steps % $count}]
    for {set i 0} {$i < $steps} {incr i} {
	set item [lindex $stack_list end]
	set stack_list [lreplace $stack_list end end]
	set stack_list [linsert $stack_list $start $item]
    }
    return
}

# size --
#
#	Return the number of objects on a stack.
#
# Arguments:
#	name	name of the stack object.
#
# Results:
#	count	number of items on the stack.

Stack instproc size {} {
    my instvar stack_list
    return [llength $stack_list]
}

Stack instproc peek_all {} {
    return [my peek [my size]]
}

Class Tcl_Word_String
Tcl_Word_String instproc init {} {
    my instvar string
    set string ""
}
Tcl_Word_String instproc append {c} {
    my instvar string
    append string $c
}
Tcl_Word_String instproc get_string {} {
    my instvar string
    return $string
}

Class Tcl_Word
Tcl_Word instproc init {} {
    my instvar list
    set list [list]
}
Tcl_Word instproc append c {
    my instvar list
    set last [lindex $list end]
    if {$list == {} || [$last info class] != "::Tcl_Word_String"} {
	set last [Tcl_Word_String new]
	lappend list $last
	
    }
    $last append $c
} 

Class Tcl_Command
Tcl_Command instproc init {} {my set word_list [list]}
Tcl_Command instproc append word {
    my instvar word_list
    lappend word_list $word
}
Tcl_Command instproc type {} {return Tcl_Command}

Class Tcl_Comment
Tcl_Comment instproc init {} {my set comment ""}
Tcl_Comment instproc append c {
    my instvar comment
    append comment $c
}
Tcl_Comment instproc type {} {return Tcl_Comment}
   


Tcl_Interpreter instproc init {} {
    my instvar state_stack
    my instvar command_list
    set state_stack [Stack new]
    set command_list [list]
}


Tcl_Interpreter instproc + {quoi} {
    my instvar state_stack
    $state_stack push $quoi
}

Tcl_Interpreter instproc - {quoi} {
    my instvar state_stack
    set dernier [$state_stack pop]
    if {$dernier != $quoi} {
	$state_stack push $dernier
	return -code error "\"$quoi\" attendu\npile = \"[$state_stack peek_all]\""
    }
}

Tcl_Interpreter create toto
toto + q
toto + w
toto + e
toto - e

Object create Inter_commands
Inter_commands proc type {} {return Inter_commands}
Object create Var_subst_begin
Var_subst_begin proc type {} {return Var_subst_begin}
Class create Var_Subst
Var_Subst instproc type {} {return Var_Subst}
Object create Command_subst
Command_subst proc type {} {return Command_subst}

Tcl_Word instproc type {} {return Tcl_Word}

Tcl_Interpreter instproc interprete {chaine} {
    my instvar state_stack
    my instvar is
    my instvar la_chaine
    set la_chaine $chaine
    $state_stack push Inter_commands
    set N [string length $la_chaine]
    for {set is 0} {$is < $N} {incr is} {
	set c [string index $chaine $is]
	set os [$state_stack peek]
	#puts stderr "os = $os"
	set status [$os type]
	#puts stderr "*** $status \"$c\" ***"
	switch $status {
	    Var_subst_begin {my var_subst_begin $c}
	    Tcl_Command     {my command $c}
	    Tcl_Comment     {my comment $c}
	    Inter_commands  {my inter_commands $c}
	    Var_Subst       {my var_subst $c}
	    Tcl_Word        {my word $c}
	    default {return -code error "status inconnu : \"$status\""}
	}
    }
    my instvar command_list
    # puts $command_list
    foreach c $command_list {
	puts "[$c info class] $c [string range $la_chaine [$c set from] [$c set to]]"
	switch [$c type] {
	    Tcl_Command {
		foreach w [$c set word_list] {
		    # puts -nonewline "  [$w set list]"
		    puts -nonewline "  "
		    foreach s [$w set list] {
			puts -nonewline "\{[$s set string]\}"
		    }
		    puts {}
		}
	    }
	    Tcl_Comment {
		puts "   \{[$c set comment]\}"
	    }
	}
    }
    $state_stack peek_all
}

Tcl_Interpreter instproc var_subst_begin {c} {
    if {[regexp {[0-9a-zA-Z_]} $c]} {
	my - Var_subst_begin
	my var_subst $c
    } else {
	my - Begin_var_subs
	my word $c
    }
}

Tcl_Interpreter instproc var_subst {c} {
    if {[regexp {[0-9a-zA-Z_]} $c]} {
    } elseif {$c == "("} {
	my array_index_begin
    } else {
	my - Var_Subst
	my word $c
    }
}

Tcl_Interpreter instproc 1array_index {c} {
    switch $c {
	\  {my - array_index ; my - var_subst ; my word $c}
	\; {my - array_index ; my - var_subst ; my word $c}
	\n {my - array_index ; my - var_subst ; my word $c}
	\\ {my + escape}
	\$ {my + var_subst_begin}
	\[ {my + inter_command}
	default {}
    }
}

Tcl_Interpreter instproc append_to_comment c {
    my instvar state_stack
    set last [$state_stack peek]
    if {[$last info class] != "::Tcl_Comment"} {
	return -code error "attendu \"::Tcl_Comment\", vu \"[$last info class]\""
    }
    $last append $c
}

Tcl_Interpreter instproc append_to_word c {
    my instvar state_stack
    set last [$state_stack peek]
    if {[$last info class] != "::Tcl_Word"} {
	return -code error "attendu \"::Tcl_Word\", vu \"[$last info class]\""
    }
    $last append $c
}

Tcl_Interpreter instproc command {c} {
    switch $c {
	\  {}
	\t {}
        \n {my command_end}
	\; {my command_end}
	\" {my word_begin ; my + Double_quote}
	\{ {my word_begin ; my + Begin_brace}
	\\ {my word_begin ; my + Begin_escape}
	\$ {my word_begin ; my + var_subst_begin}
	\[ {my word_begin ; my + Command_subst ; my + Inter_commands}
	default {my word_begin ; my append_to_word $c}
    }
}

Tcl_Interpreter instproc inter_commands {c} {
    switch $c {
	\  {}
	\t {}
        \n {}
	\# {my comment_begin}
	\" {my - Inter_commands ; my begin_command_and_word ; my + Double_quote}
	\{ {my - Inter_commands ; my begin_command_and_word ; my + Begin_brace}
	\\ {my - Inter_commands ; my begin_command_and_word ; my + Begin_escape}
	\$ {my - Inter_commands ; my begin_command_and_word ; my + var_subst_begin}
	\[ {my - Inter_commands ; my + Command_subt ; my begin_command_and_word ; my + Inter_commands}
	default {my - Inter_commands ; my begin_command_and_word ; my append_to_word $c}
    }
}

Tcl_Interpreter instproc begin_command_and_word {} {
    set command [Tcl_Command new]
    $command set from [my set is]
    set word [Tcl_Word new]
    my + $command
    my + $word
}

Tcl_Interpreter instproc command_end {} {
    my instvar state_stack
    my instvar command_list
    set command [$state_stack pop]
    if {[$command info class] != "::Tcl_Command"} {
	return -code error "attendu \"::Tcl_Command\", vu \"[$command info class]\""
    }
    $command set to [expr {[my set is] - 1}]
    lappend command_list $command
    if {[$state_stack size] > 0} {
	set quoi [$state_stack peek]
	if {[$quoi info class] == "::Tcl_Word"} {
	    $quoi append $command
	} else {
	    my + Inter_commands
	}
    } else {
	my + Inter_commands
    } 
}

Tcl_Interpreter instproc comment {c} {
    switch $c {
	\\ {my + Escape_in_comment}
	\n {my comment_end}
	default {my append_to_comment $c}
    }
}

Tcl_Interpreter instproc comment_begin {} {
    set comment [Tcl_Comment new]
    $comment set from [my set is]
    my + $comment
}

Tcl_Interpreter instproc comment_end {} {
    my instvar state_stack
    my instvar command_list
    set comment [$state_stack pop]
    if {[$comment info class] != "::Tcl_Comment"} {
	return -code error "attendu \"::Tcl_Comment\", vu \"[$command info class]\""
    }
    $comment set to [expr {[my set is] - 1}]
    lappend command_list $comment
    my + Inter_commands
}

Tcl_Interpreter instproc word {c} {
    switch $c {
	\  {my word_end}
	\; {my word_end ; my command_end}
        \n {my word_end ; my command_end}
	\] {my word_end ; my command_end ; my - Inter_commands ; my - Command_subst}
	\\ {my + Escape}
	\$ {my + var_subst_begin}
	\[ {my + Command_subst ; my + Inter_commands}
	default {my append_to_word $c}
    }
}

Tcl_Interpreter instproc word_begin {} {
    set word [Tcl_Word new]
    my + $word
}

Tcl_Interpreter instproc word_end {} {
    my instvar state_stack
    set word [$state_stack pop]
    if {[$word info class] != "::Tcl_Word"} {
	return -code error "attendu \"::Tcl_Word\", vu \"[$word info class]\""
    }
    set command [$state_stack peek]
    if {[$command info class] != "::Tcl_Command"} {
	return -code error "attendu \"::Tcl_Command\", vu \"[$command info class]\""
    }
    $command append $word
}


Tcl_Interpreter create essai
essai interprete {
puts toto
#blabla
    puts toto ; puts titi ; # coco\
    sur deux lignes
    puts [  llength   [   list q [list [z x] e ]]]
    read aa
}
