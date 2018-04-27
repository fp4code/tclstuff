#
## dadEx2.tcl
#  by: Michael B. Johnson wave@pixar.com
#
# simple example of using wave's DragAndDrop, inspired by the
# drag-and-drop behavior available in NEXTSTEP.  It's not the
# same, but it's getting there...
#
# This example lets you drag little labels of color by mousing
# down with the first mouse button.  If you drop the label
# over a square, it sets the color of the square to the dragged
# color, and subsequent drags out of that square are that new
# color.  If dropped on anything other than a valid drop target,
# it pops up a new top level window of that color.  Note that
# these new windows are neither drag sources nor drop targets.

source DragAndDrop.tcl
namespace import DragAndDrop::*

##

foreach color {red green blue} {
    set w [frame .${color} -background $color \
            -width 30 -height 60]

    #### make this widget a drag source
    namespace eval $w {
        variable _name $w
        variable _dragTypes {color}
        variable _dropTypes $_dragTypes
        variable _color $color
        variable _children 0
    }
    proc ${w}::color {} {
        variable _color
        return $_color;
    }
    proc ${w}::dragWidgetClass {} {
        return label
    }
    proc ${w}::dragWidgetOptions {} {
        variable _color
        variable _optionsList ""

        # note: we do it this way, so that the color we use for the
        # dragger reflects our *current* color, not just what we
        # started out with
        lappend _optionsList "text $_color"
        lappend _optionsList "border 2"
        lappend _optionsList "relief raised"
        return $_optionsList
    }
    proc ${w}::dragCursorLocation {} {
        # when dragged, we want the cursor below the widget
        return ll
    }
    proc ${w}::dragTypes {} {
        variable _dragTypes
        return $_dragTypes
    }
    proc ${w}::dropTypes {} {
        variable _dropTypes
        return $_dropTypes
    }
    proc ${w}::emptyDrop {{x 0} {y 0}} {
        variable _name
        variable _children
        variable _color

        # if we're dropped on empty space, we can do something...
        incr _children
        set top [toplevel ${_name}#${_children}]
        set w [frame ${top}.${_color} -background $_color \
                -width 30 -height 60]
        pack $w -fill x
        wm geometry $top +${x}+${y}
        return 1
    }

    DragAndDrop::makeDragSource $w \
            Button-1 ButtonRelease-1 \
            [${w}::dragTypes] \
            [${w}::dragCursorLocation] \
            ${w}::emptyDrop

    #### make this widget a drop target

    DragAndDrop::makeDropTarget $w [${w}::dropTypes]
    proc ${w}::dragEnter {} {
        variable _name

        $_name config -borderwidth 6 -relief sunken
        return copy;
    }
    proc ${w}::dragUpdate {} {
        return copy;
    }
    proc ${w}::dragLeave {} {
        variable _name

        $_name config -borderwidth 0 -relief flat
        return copy;
    }
    proc ${w}::performDrop {} {
        variable _name
        variable _color

        $_name config -borderwidth 0 -relief flat
        set dS [DragAndDrop::dragSource]
        if {[catch {$_name config -background [${dS}::color]} uhoh]} {
            # there was a problem - don't accept drag
            puts "$_name got an error performing the drop: <$uhoh>"
            return 0;
        } {
            # set our color to the dragSource color
            set _color [[DragAndDrop::dragSource]::color]
        }
        return 1;
    }

    pack $w -fill x
}

