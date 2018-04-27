package require vtk
package require vtkinteraction

# Create the RenderWindow, Renderer

# création des objets
vtkRenderer                   ren1
vtkRenderWindow               renWin
vtkRenderWindowInteractor     l_Interacteur

# construction du pipeline
renWin        AddRenderer     ren1
l_Interacteur SetRenderWindow renWin

# cosmétique couleur taille
ren1  SetBackground 0 0 0
renWin SetSize 500 500

# démarrage
l_Interacteur Initialize

# Create bottle profile. This is the object to be rendered.

# Crée un vecteur de points
# L'allocation est dynamique
vtkPoints points
points InsertPoint 0 0.01 0.0 0.0
points InsertPoint 1 1.5 0.0 0.0
points InsertPoint 2 1.5 0.0 3.5
points InsertPoint 3 1.25 0.0 3.75
points InsertPoint 4 0.75 0.0 4.00
points InsertPoint 5 0.6 0.0 4.35
points InsertPoint 6 0.7 0.0 4.65
points InsertPoint 7 1.0 0.0 4.75
points InsertPoint 8 1.0 0.0 5.0
# points InsertPoint 9 0.01 0.0 5.0
points InsertPoint 9  0.01 0.0 0.0

# Vecteur de cellules, sous la forme "n id01 id02 ... id0n m id11 id12 ... id1m ..." 
# Vaut ici "10 0 1 2 3 4 5 6 7 8 9"
vtkCellArray lines
lines InsertNextCell 10;#number of points
lines InsertCellPoint 0
lines InsertCellPoint 1
lines InsertCellPoint 2
lines InsertCellPoint 3
lines InsertCellPoint 4
lines InsertCellPoint 5
lines InsertCellPoint 6
lines InsertCellPoint 7
lines InsertCellPoint 8
lines InsertCellPoint 9

# L'enemble qui décrit vertices, lines, polygons, et triangle strips
vtkPolyData profile
# le vtkPolyData est une extension de vtkPointSet
profile SetPoints points
# le vtkPolyData Contient spécifiquement un vecteur (vtkCellArray) de lignes,
# indexées à partir des points
# Ici "lines" contient "10 0 1 2 3 4 5 6 7 8 9"
# Ce qui veut dire qu'il y a 9 segments reposants sur les 10 points d'index 0 1 .. 9 
profile SetLines lines

# La séquence classique vtkPolyDataMapper-vtkActor-vtkRenderer
vtkPolyDataMapper profileMap
profileMap SetInput profile
vtkActor profileActor
profileActor SetMapper profileMap
ren1 AddProp profileActor
# First render, forces the renderer to create a camera with a
# good initial position

renWin Render

dd

# Extrude profile to make bottle
vtkRotationalExtrusionFilter extrude
extrude SetInput profile
extrude SetResolution 60



vtkPolyDataMapper map
map SetInput [extrude GetOutput]

vtkActor bottle
bottle SetMapper map
[bottle GetProperty] SetColor 0.3800 0.7000 0.1600


# Add the actor to the renderer
ren1 AddActor bottle
# First render, forces the renderer to create a camera with a
# good initial position

renWin Render

# prevent the tk window from showing up then start the event loop
wm withdraw .



