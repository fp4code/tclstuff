# 26 juin 2003 (FP)

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

########## métallisation Ti-Au ##########

# Crée un vecteur de points
# L'allocation est dynamique
vtkPoints masque1Points
masque1Points InsertPoint  0  -80  -40   0
masque1Points InsertPoint  1    0  -40   0
masque1Points InsertPoint  2    0   0    0
masque1Points InsertPoint 3   -80  40    0
masque1Points InsertPoint 5  -80  -40    0

vtkCellArray lePoly

  lePoly InsertNextCell 4
  lePoly InsertCellPoint 0
  lePoly InsertCellPoint 1
  lePoly InsertCellPoint 2
  lePoly InsertCellPoint 3

vtkPolyData polyData
    polyData SetPoints masque1Points
    polyData SetPolys lePoly

set rien {# Vecteur de cellules, sous la forme "n id01 id02 ... id0n m id11 id12 ... id1m ..." 
# Vaut ici "12 0 1 2 3 4 5 6 7 8 9 10 11"
vtkPolygon masque1Polygon
[masque1Polygon GetPointIds] SetNumberOfIds 4
  [masque1Polygon GetPointIds] SetId 0 0
  [masque1Polygon GetPointIds] SetId 1 1
  [masque1Polygon GetPointIds] SetId 2 2
  [masque1Polygon GetPointIds] SetId 3 3

vtkCellArray vca
   vca InsertNextCell 1
   vca InsertNextCell masque1Polygon

vtkPolyData vpd
   vpd SetPolys vca
}
#
vtkLinearExtrusionFilter extrudeMasque1
extrudeMasque1 SetInput polyData
extrudeMasque1 SetExtrusionType 1
extrudeMasque1 SetVector 0 0 42
extrudeMasque1 CappingOff

# La séquence classique vtkPolyDataMapper-vtkActor-vtkRenderer
vtkPolyDataMapper masque1Map
masque1Map SetInput [extrudeMasque1 GetOutput]
vtkActor masque1Actor
masque1Actor SetMapper masque1Map
ren1 AddProp masque1Actor

renWin Render

# prevent the tk window from showing up then start the event loop
wm withdraw .
