# file: example1.tcl

# This file illustrates the low-level C++ interface
# created by SWIG.  In this case, all of our C++ classes
# get converted into function calls.

catch {load /home/fab/C/fidev-SparcSolarisForte7-optim/Tcl/essais_swig/class/libswigclass.so Example}
catch { load ./example.so example}
catch { load ./example.dll example}    ;# Windows

# ----- Object creation -----

puts "Creating some objects:"
set c [example::new_Circle 10]
puts "    Created circle $c"
set s [example::new_Square 10]
puts "    Created square $s"

# ----- Access a static member -----

puts "\nA total of $example::Shape_nshapes shapes were created"

# ----- Member data access -----

# Set the location of the object
# Note: the base class must be used since that's where x and y
# were declared.

example::Shape_x_set $c 20
example::Shape_y_set $c 30
example::Shape_x_set $s -10
example::Shape_y_set $s 5

puts "\nHere is their current position:"
puts "    Circle = ([example::Shape_x_get $c], [example::Shape_y_get $c])"
puts "    Square = ([example::Shape_x_get $s], [example::Shape_y_get $s])"

# ----- Call some methods -----

puts "\nHere are some properties of the shapes:"
foreach o "$c $s" {
      puts "    $o"
      puts "        area      = [example::Shape_area $o]"
      puts "        perimeter = [example::Shape_perimeter $o]"
}
# Notice how the Shape_area() and Shape_perimeter() functions really
# invoke the appropriate virtual method on each object.

# ----- Try to cause a type error -----

puts "\nI'm going to try and break the type system"

if { [catch {
    # Bad script!
    example::Square_area $c         # Try to invoke Square method on a Circle
    puts "    Bad bad SWIG!"

}]} {
    puts "    Well, it didn't work. Good SWIG."
}

# ----- Delete everything -----

puts "\nGuess I'll clean up now"

# Note: this invokes the virtual destructor
example::delete_Shape $c
example::delete_Shape $s

puts "$example::Shape_nshapes shapes remain"
puts "Goodbye"

