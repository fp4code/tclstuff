#
# This simple example shows how to do basic rendering and pipeline
# creation.
#
# We start off by loading some Tcl modules. One is the basic VTK library;
# the second is a package for rendering, and the last includes a set
# of color definitions.
#
package require vtk
package require vtkinteraction

# This creates a polygonal cylinder model with eight circumferential facets.
#
vtkCylinderSource leCylindre
    leCylindre SetResolution 8

puts "\nCaractéristiques de l'objet \"leCylindre\" de type [leCylindre GetClassName] :"
foreach p {Height Radius Center Resolution Capping} {
    puts "leCylindre Get$p -> [leCylindre Get$p]"
}

# 

set leCylindrePolyData [leCylindre GetOutput]

puts "\nCaractéristiques de l'objet \[leCylindre GetOutput\] de type [$leCylindrePolyData GetClassName] :"
foreach p {DataObjectType NumberOfCells NumberOfVerts NumberOfLines NumberOfStrips} {
    puts "\[leCylindre Get$p\] Get$p -> [$leCylindrePolyData Get$p]"
}

foreach p {MTime NumberOfPoints Points} {
    puts "\[leCylindre GetOutput\] Get$p -> [$leCylindrePolyData Get$p]"
}

# Ne donne rien avant "l_Interacteur Initialize"


set lesPoints [[leCylindre GetOutput] GetPoints]

puts "\nCaractéristiques de l'objet \[\[leCylindre GetOutput\] GetPoints\] de type [$lesPoints GetClassName] :"
foreach p {Bounds NumberOfPieces NumberOfSubPieces GhostLevel} {
    puts "Get$p -> [$lesPoints Get$p]"
}



# The mapper is responsible for pushing the geometry into the graphics
# library. It may also do color mapping, if scalars or other attributes
# are defined.
#
vtkPolyDataMapper leMappeurDuCylindre
    leMappeurDuCylindre SetInput $leCylindrePolyData

puts "\nCaractéristiques de l'objet \"leMappeurDuCylindre\" de type [leMappeurDuCylindre GetClassName] :"
foreach p {Bounds NumberOfPieces NumberOfSubPieces GhostLevel} {
    puts "\[leMappeurDuCylindre Get$p\] Get$p -> [leMappeurDuCylindre Get$p]"
}



# The actor is a grouping mechanism: besides the geometry (mapper), it
# also has a property, transformation matrix, and/or texture map.
# Here we set its color and rotate it -22.5 degrees.
vtkActor l_ActeurDuCylindre
    l_ActeurDuCylindre SetMapper leMappeurDuCylindre
    [l_ActeurDuCylindre GetProperty] SetColor 1.0000 0.3882 0.2784
    l_ActeurDuCylindre RotateX  30.0
    l_ActeurDuCylindre RotateY -45.0

# Create the graphics structure. The renderer renders into the 
# render window. The render window interactor captures mouse events
# and will perform appropriate camera or actor manipulation
# depending on the nature of the events.
#
vtkRenderer leRendeur
vtkRenderWindow leRendeurDeFenetre
    leRendeurDeFenetre AddRenderer leRendeur
vtkRenderWindowInteractor l_Interacteur
     l_Interacteur SetRenderWindow leRendeurDeFenetre

# Add the actors to the renderer, set the background and size
#
leRendeur AddActor l_ActeurDuCylindre
leRendeur SetBackground 0.1 0.2 0.4
leRendeurDeFenetre SetSize 200 200

# This allows the interactor to initalize itself. It has to be
# called before an event loop. In this example, we allow Tk to
# start the event loop (this is done automatically by Tk after
# the user script is executed).
l_Interacteur Initialize

# We'll zoom in a little by accessing the camera and invoking a "Zoom"
# method on it.
[leRendeur GetActiveCamera] Zoom 1.5
leRendeurDeFenetre Render

# prevent the tk window from showing up then start the event loop
wm withdraw .
