#
## DragAndDrop.tcl
#  by: Michael B. Johnson wave@pixar.com
#
################################ start of DragAndDrop ##################
##set up the global dragger window and state...
namespace eval DragAndDrop {
    namespace export makeDragSource
    namespace export dragSource
    namespace export makeDropTarget

    #
    variable _sessionID 0

    # the name of the top level widget used for dragging sessions
    variable _name .dragProxy
    # initial width and height of the widget in dragProxy
    variable _width 0
    variable _height 0

    # the name of the widget that is initiator of the current
    # drag session
    variable _dragSource ""
    # the types, in order of preference, that are available
    #from _dragSource
    variable _dragTypes
    # the x and y position where the drag operation started from
    variable _startX 0
    variable _startY 0
    # the x and y position where the drag operation stopped at
    variable _endX 0
    variable _endY 0
    # what to do when dropped in "open space"
    variable _emptyDropProc ""

    # the name of the widget that is the current potential drop target
    variable _dropTarget ""
    # associative array mapping registered widgets to types they accept
    variable _dropTypes ;

    # when animating back a failed drop, how many steps to use
    variable _animateSteps 10
    # when animating back a failed drop, how long to delay each step
    variable _animateDelay 1
    # the change in x and y since the last animate back
    variable _xDif 0
    variable _yDif 0
    variable _scheduleId ""

    variable _printError 1

    variable _dragOperation all

    variable _cursorLocation m; # valid values: ul, ll, m
    variable _cursor
    # why don't these cursors work on Mac and PC?
    #set _cursor(none) {left_ptr black white}
    #set _cursor(move) {left_ptr green black}
    #set _cursor(copy) {exchange green black}
    #set _cursor(link) {sb_v_double_arrow green black}
    #set _cursor(all) {left_ptr green black}
    #set _cursor(private) {draped_box green black}
    set _cursor(none) left_ptr
    set _cursor(move) boat
    set _cursor(copy) exchange
    set _cursor(link) diamond_cross
    set _cursor(all) dot
    set _cursor(private) draped_box

    # In NeXTSTEP, ctrl meant link, alt was copy, and cmd was move
    # need to figure out if we can use keyboard modifiers during
    # a drag in Tk.

    toplevel $_name
    $_name config -cursor [set _cursor(${_dragOperation})]
    wm overrideredirect $_name 1
    wm withdraw $_name
}

# this proc returns the current widget that is the source of the drag
# operation.  If it's an empty string, there is currently no drag
# session underway.
proc DragAndDrop::dragSource {} {
    variable _dragSource;
    return $_dragSource;
}

# we want to record the fact that the widget $w is interested in
# having any of the following types dropped on it.  To track this,
# we want to have an associative array which uses the name of
# this widget as the index, with its value set to all the types
# that widget will accept.  When something is dragged over this
# window, we can quickly walk through the list of types that
# that registered window is willing to accept, to see if it
# should be bothered by the event.
proc DragAndDrop::registerForDropTypes {w types} {
    variable _dropTypes

    set _dropTypes(${w}) $types
    # need to create the namespace for this widget:
    namespace eval $w "variable _dropTypes; set _dropTypes $types"
}

proc DragAndDrop::finishDragSession {} {
    variable _name
    variable _startX
    variable _startY
    variable _dragger

    wm geometry $_name +${_startX}+${_startY}
    wm withdraw $_name
    catch {destroy $_dragger}
    # zero out all the temporary instance variables
    set _dragger ""
    variable _dragSource ""
    variable _dragTypes ""
    variable _dropTarget ""
    variable _scheduleId ""
    variable _width 0
    variable _height 0
    variable _sessionID 0
    variable _emptyDropProc ""
}

proc DragAndDrop::animateBack {cnt} {
    variable _name
    variable _startX
    variable _startY
    variable _xDif
    variable _yDif
    variable _animateSteps
    variable _animateDelay

    if {$cnt} {
        # move dragger back a bit...
        set u [expr (double($cnt)/$_animateSteps)]
        set newX [expr int($_startX + ($u * $_xDif))]
        set newY [expr int($_startY + ($u * $_yDif))]
        wm geometry $_name +$newX+$newY
        set cnt [expr ($cnt - 1)]
        after $_animateDelay "DragAndDrop::animateBack $cnt"
    } else {
        DragAndDrop::finishDragSession
    }
}

proc DragAndDrop::stopSession {endX endY} {
    variable _startX
    variable _startY
    variable _xDif
    variable _yDif
    variable _animateSteps
    variable _animateDelay
    variable _scheduleId
    variable _dropTarget
    variable _printError
    variable _emptyDropProc
    set dropResult 0

    if {$_scheduleId != ""} {
        after cancel $_scheduleId
        set _scheduleId ""
    }

    if {[string compare $_dropTarget ""]} {
        # there is some drop target
        # check and see if the performDrop proc exists:
        set perf [namespace eval ::${_dropTarget} {info proc performDrop}]
        set drop ::${_dropTarget}::performDrop
        if {![string compare performDrop $perf]} {
            if {[catch {set dropResult [$drop]} uhoh]} {
                if {$_printError} {
                    puts "evaluting ${drop} returned error:"
                    puts "\t<$uhoh>"
                }
            }
        } else {
            if {$_printError} {
                puts "$_dropTarget did not implement the proc $drop"
            }
        }

    } else {
        # there is no explicit drop target - the drag source was
        # dropped over "open space".  This is something that can
        # either signal the fact the user has decided not to drop
        # the drag source over any specific target, and therefore
        # the drag source should animate back to its start, or it
        # might be the only successful way to drop the dragger.
        # For example, think of PhotoShop's palettes.  mousing
        # down and dragging to another palette allows the dragged
        # palette to be "clicked in" with that palette.  Dropping
        # it in "open space", though, causes it to put up a new
        # top level palette and place the dragged palette in it.
        # we should allow drag sources to specify an action to take
        # if they are dropped over open space.  If there is
        # an _emptyDropProc, we'll eval it, passing in the
        # the x and y coordinates of the pointer.
        set dropResult 0
        if {[string compare $_emptyDropProc ""]} {
            if {[catch \
                    {set dropResult [$_emptyDropProc $endX $endY]} \
                    uhoh]} {
                if {$_printError} {
                    puts "$_emptyDropProc returned an error:"
                    puts "\t<$uhoh>"
                }
            }
        }
    }

    if {$dropResult} {
        # the drop was accepted! finish up the session
        DragAndDrop::finishDragSession
    } else {
        # the drop wasn't accepted - animate back to starting point
        set _xDif [expr ($endX - $_startX)]
        set _yDif [expr ($endY - $_startY)]
        after $_animateDelay "DragAndDrop::animateBack $_animateSteps"
    }
}

proc DragAndDrop::startSession {source dragTypes \
        startX startY cursorLocation emptyDropProc} {
    variable _sessionID
    if {$_sessionID} {
        # if we've already got a drag session underway, return
        return ;
    }
    set _sessionID 1

    # need to confirm that the procs ::${source}::dragWidgetClass
    # and ::${source}::dragWidgetOptions both exist
    set d [namespace eval ::${source} {info proc dragWidgetClass}]
    if {[string compare dragWidgetClass $d]} {
        set msg1 "you must implement the proc "
        set msg2 "::${source}::dragWidgetClass"
        set msg3 "(which should return the name of a Tk widget class)"
        set msg "$msg1 $msg2 $msg3"
        tk_dialog .errorMsg "error" $msg {} 0 "back to work, sluggo"
        finishDragSession
        return ;
    }
    set d [namespace eval ::${source} {info proc dragWidgetOptions}]
    if {[string compare dragWidgetOptions $d]} {
        set msg1 "you must implement the proc "
        set msg2 "::${source}::dragWidgetOptions"
        set msg3 "(which should return the options and values "
        set msg4 "to apply to the dragged widget)"
        set msg "$msg1 $msg2 $msg3 $msg4"
        tk_dialog .errorMsg "error" $msg {} 0 "back to work, sluggo"
        finishDragSession
        return ;
    }
    variable _name
    variable _height
    variable _width
    variable _startX
    variable _startY
    variable _dragSource $source
    variable _dragTypes $dragTypes
    set n ${_name}.dragger
    variable _dragger [[::${_dragSource}::dragWidgetClass] $n]
    variable _dragOperation
    variable _cursor
    variable _cursorLocation $cursorLocation
    variable _emptyDropProc $emptyDropProc

    # okay, apply each configuration option
    set opts [::${_dragSource}::dragWidgetOptions]
    foreach nameValue $opts {
        set opt [lindex $nameValue 0]
        set val [lindex $nameValue 1]
        $_dragger configure -$opt $val
    }
    pack ${_name}.dragger
    wm deiconify $_name
    update idletasks

    # we now want to move
    set _width [winfo width $_name]
    set _height [winfo height $_name]
    set _startX [expr ($startX - (int($_width/2.0)))]
    set _startY [expr ($startY - (int($_height/2.0)))]
    wm geometry $_name +$_startX+$_startY
    update idletasks

    raise $_name
    set _scheduleId [after 10 DragAndDrop::updateDrag]
}

proc DragAndDrop::updateDrag {} {
    variable _scheduleId
    variable _name
    variable _height
    variable _width
    variable _dropTarget
    variable _dropTypes
    variable _dragTypes
    variable _cursor
    variable _printError;
    variable _dragger;
    variable _cursorLocation;

    set pX [winfo pointerx $_name]
    set pY [winfo pointery $_name]
    # (0,0) is the upper left corner of the screen
    # make ul the default...
    set newX $pX
    set newY $pY
    switch $_cursorLocation {
        ul {
            # cursor in upper left of dragger; one pixel in
            set newX [expr ($pX - 1)]
            set newY [expr ($pY - 1)]
        }
        ll {
            # cursor in lower left of dragger
            set newX [expr ($pX - 1)]
            set newY [expr ($pY - ($_height-1))]
        }
        m  {
            # cursor in middle of dragger
            set newX [expr int($pX - ($_width/2.0))]
            set newY [expr int($pY - ($_height/2.0))]
        }
    }
    wm geometry $_name +$newX+$newY
    update idletasks

    #check one pixel past upper left edge..
    set checkX [expr ($newX - 1)]
    set checkY [expr ($newY - 1)]
    set newWin [winfo containing $checkX $checkY]
    if {[string compare $newWin $_dropTarget] != 0} {
        # we're clearly not over the same window as last time:
        # if we've just entered a new window:
        if {$newWin != ""} {
            # now we need to see if window is a target for any of
            # the drag types available in the current drag session.
            set matchedType 0
            if {![catch {set _dropTypes($newWin)} uhoh]} {
                # compare the types of the dragSource and the
                # potential dropTarget to try and find a match.
                # If there is, send a message to the dropTarget
                foreach dropT [set _dropTypes($newWin)] {
                    foreach dragT $_dragTypes {
                        if {![string compare $dropT $dragT]} {
                            set matchedType 1
                            break ;
                        }
                    }
                    if {$matchedType} {
                        break;
                    }
                }
                if {$matchedType} {
                    set dE ::${newWin}::dragEnter
                    if {[catch {set dragType [$dE]} uhoh]} {
                        if {$_printError} {
                            puts "$dE returned error:"
                            puts "\t<$uhoh>"
                        }
                        set dragType none
                    }
                    set cT [set _cursor($dragType)]
                    if {[catch {$_name config -cursor $cT} uhoh]} {
                        if {$_printError} {
                            set msg1 "attempting to set the cursor to"
                            set msg2 "$cT returned error:"
                            puts "$msg1 $msg2"
                            puts "\t<$uhoh>"
                        }
                    } else {
                        set msg1 "supposedly set cursor of draggable"
                        set msg2 ": $_name config -cursor $cT"
                        puts "$msg1 $msg2"
                    }
                }
            } else {
                if {$_printError} {
                    puts "$newWin isn't a registered drop target"
                }
            }

        }

        # if we've just left the current window:
        if {$_dropTarget != ""} {
            # now we need to see if window is a target for any of the
            # drag types available in the current drag session.
            set matchedType 0
            if {![catch {set _dropTypes($_dropTarget)} uhoh]} {
                # compare the types of the dragSource and the
                # potential dropTarget to try and find a match.
                # If there is, send a message to the dropTarget
                foreach dropT [set _dropTypes($_dropTarget)] {
                    foreach dragT $_dragTypes {
                        if {![string compare $dropT $dragT]} {
                            set matchedType 1
                            break ;
                        }
                    }
                    if {$matchedType} {
                        break;
                    }
                }
                if {$matchedType} {
                    # note: we tell the dropTarget we're leaving,
                    # but we reset the cursor back to "none"
                    # regardless of what it returns
                    set dL ::${_dropTarget}::dragLeave
                    if {[catch {set dragType [$dL]} uhoh]} {
                        if {$_printError} {
                            puts "::$dL returned error:"
                            puts "\t<$uhoh>"
                        }
                        set dragType none
                    }
                    set cT [set _cursor(none)]
                    if {[catch {$_name config -cursor $cT} uhoh]} {
                        if {$_printError} {
                            set msg1 "attempting to set the cursor to"
                            set msg2 "$cT returned error:"
                            puts "$msg1 $msg2"
                            puts "\t<$uhoh>"
                        }
                    } else {
                        set msg1 "supposedly set cursor of draggable"
                        set msg2 ": $_name config -cursor $cT"
                        puts "$msg1 $msg2"
                    }
                }
            } else {
                #if {$_printError} {
                #    puts "$_dropTarget isn't a registered drop target"
                #}
            }
        }

        set _dropTarget $newWin

    } else {
        if {$_dropTarget != ""} {
            # now we need to see if window is a target for any of the
            # drag types available in the current drag session.
            set matchedType 0
            if {![catch {set _dropTypes($_dropTarget)} uhoh]} {
                # compare the types of the dragSource and the
                # potential dropTarget to try and find a match.
                # If there is, send a message to the dropTarget
                foreach dropT [set _dropTypes($_dropTarget)] {
                    foreach dragT $_dragTypes {
                        if {![string compare $dropT $dragT]} {
                            set matchedType 1
                            break ;
                        }
                    }
                    if {$matchedType} {
                        break;
                    }
                }
                if {$matchedType} {
                    set dU ::${newWin}::dragUpdate
                    if {[catch {set dragType [$dU]} uhoh]} {
                        if {$_printError} {
                            puts "::$dU returned error:"
                            puts "\t<$uhoh>"
                        }
                        set dragType none
                    }
                    #set cT [set _cursor($dragType)]
                    #if {[catch {$_name config -cursor $cT} uhoh]} {
                    #   if {$_printError} {
                    #       set msg1 "attempting to set the cursor to"
                    #       set msg2 "$cT returned error:"
                    #       puts "$msg1 $msg2"
                    #       puts "\t<$uhoh>"
                    #   }
                    #} else {
                    #   set msg1 "supposedly set cursor of draggable"
                    #   set msg2 ": $_name config -cursor $cT"
                    #   puts "$msg1 $msg2"
                    #}
                }
            } else {
                #if {$_printError} {
                #    puts "$_dropTarget isn't a registered drop target"
                #}
            }
        }
    }

    set _scheduleId [after 10 DragAndDrop::updateDrag]
}

proc DragAndDrop::makeDragSource {w startEvent endEvent \
        dragTypes cursorLocation emptyDropProc} {

    bind $w <$startEvent> \
            "DragAndDrop::startSession $w $dragTypes \
                          %X %Y $cursorLocation $emptyDropProc"
    bind $w <$endEvent> \
            "DragAndDrop::stopSession %X %Y"
}

proc DragAndDrop::makeDropTarget {w dropTypes} {

    DragAndDrop::registerForDropTypes $w $dropTypes
    # we now need to create implementations to respond to the three
    # messages - I'm not sure this works to check their existence...
    set dE [info proc ${w}::dragEnter]
    if {[string compare ${w}::dragEnter $dE] != 0} {
        proc ::${w}::dragEnter {} {
            puts "default dragEnter"; return none;
        }
    }
    set dU [info proc ${w}::dragUpdate]
    if {[string compare ${w}::dragUpdate $dU] != 0} {
        proc ::${w}::dragUpdate {} {
            puts "default dragUpdate"; return none;
        }
    }
    set dL [info proc ${w}::dragLeave]
    if {[string compare ${w}::dragLeave $dL] != 0} {
        proc ::${w}::dragLeave {} {
            puts "default dragLeave"; return none;
        }
    }
    set pD [info proc ${w}::performDrop]
    if {[string compare ${w}::performDrop $pD] != 0} {
        proc ::${w}::performDrop {} {
            puts "default performDrop"; return 0;
        }
    }
}
################################ end of DragAndDrop ##################
#
# end of DragAndDrop.tcl
