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

proc setDouble {varName double} {
    upvar $varName var
    set var [expr {double($double)}]
}

# Un vtkVoxel est un parallèlépipède parallèle aux axes.
# C'est une extension de vtkCell3D
# qui est une extension de vtkCell 
# qui contient un vtkIdList (PointsIds)

proc newVoxel {name groupe} {
    vtkVoxel $name
    set pid [$name GetPointIds]
    for {set i 0; set ip [expr {4*($groupe+1)}]} {$i < 4} {incr i; incr ip} {
	$pid InsertId $i $ip
    }
    for {incr ip -8} {$i < 8} {incr i; incr ip} {
	$pid InsertId $i $ip
    }
}

set X1base -100
set Y1base -100
set X2base  120
set Y2base  100

vtkPoints bigBloc
bigBloc SetNumberOfPoints 40

bigBloc InsertPoint  0 $X1base $Y1base 0
bigBloc InsertPoint  1 $X2base $Y1base 0
bigBloc InsertPoint  2 $X1base $Y2base 0
bigBloc InsertPoint  3 $X2base $Y2base 0
bigBloc InsertPoint  4 $X1base $Y1base -0.1
bigBloc InsertPoint  5 $X2base $Y1base -0.1
bigBloc InsertPoint  6 $X1base $Y2base -0.1
bigBloc InsertPoint  7 $X2base $Y2base -0.1
bigBloc InsertPoint  8 $X1base $Y1base -0.2
bigBloc InsertPoint  9 $X2base $Y1base -0.2
bigBloc InsertPoint 10 $X1base $Y2base -0.2
bigBloc InsertPoint 11 $X2base $Y2base -0.2
bigBloc InsertPoint 12 $X1base $Y1base -0.25
bigBloc InsertPoint 13 $X2base $Y1base -0.25
bigBloc InsertPoint 14 $X1base $Y2base -0.25
bigBloc InsertPoint 15 $X2base $Y2base -0.25
bigBloc InsertPoint 16 $X1base $Y1base -0.30
bigBloc InsertPoint 17 $X2base $Y1base -0.30
bigBloc InsertPoint 18 $X1base $Y2base -0.30
bigBloc InsertPoint 19 $X2base $Y2base -0.30
bigBloc InsertPoint 20 $X1base $Y1base -0.60
bigBloc InsertPoint 21 $X2base $Y1base -0.60
bigBloc InsertPoint 22 $X1base $Y2base -0.60
bigBloc InsertPoint 23 $X2base $Y2base -0.60
bigBloc InsertPoint 24 $X1base $Y1base -0.65
bigBloc InsertPoint 25 $X2base $Y1base -0.65
bigBloc InsertPoint 26 $X1base $Y2base -0.65
bigBloc InsertPoint 27 $X2base $Y2base -0.65
bigBloc InsertPoint 28 $X1base $Y1base -0.70
bigBloc InsertPoint 29 $X2base $Y1base -0.70
bigBloc InsertPoint 30 $X1base $Y2base -0.70
bigBloc InsertPoint 31 $X2base $Y2base -0.70
bigBloc InsertPoint 32 $X1base $Y1base -0.75
bigBloc InsertPoint 33 $X2base $Y1base -0.75
bigBloc InsertPoint 34 $X1base $Y2base -0.75
bigBloc InsertPoint 35 $X2base $Y2base -0.75
bigBloc InsertPoint 36 $X1base $Y1base -5
bigBloc InsertPoint 37 $X2base $Y1base -5
bigBloc InsertPoint 38 $X1base $Y2base -5
bigBloc InsertPoint 39 $X2base $Y2base -5

newVoxel ContactOhmiqueE 0
newVoxel SubEmetteur     1
newVoxel Emetteur        2
newVoxel Base            3
newVoxel Collecteur      4
newVoxel SubCollecteur   5
newVoxel ContactOhmiqueC 6
newVoxel Buffer          7
newVoxel Substrat        8

proc unstructuredGridOneVoxel {name} {
    vtkUnstructuredGrid ${name}_Grid
    ${name}_Grid Allocate 1 1
    ${name}_Grid InsertNextCell [$name GetCellType] [$name GetPointIds]
    ${name}_Grid SetPoints bigBloc

    # La séquence classique vtkPolyDataMapper-vtkActor-vtkRenderer
    vtkDataSetMapper ${name}_Map
    ${name}_Map SetInput ${name}_Grid
    vtkActor ${name}_Actor
    ${name}_Actor SetMapper  ${name}_Map
    ren1 AddProp ${name}_Actor
}

unstructuredGridOneVoxel ContactOhmiqueE
unstructuredGridOneVoxel SubEmetteur
unstructuredGridOneVoxel Emetteur
unstructuredGridOneVoxel Base
unstructuredGridOneVoxel Collecteur
unstructuredGridOneVoxel SubCollecteur
unstructuredGridOneVoxel ContactOhmiqueC
unstructuredGridOneVoxel Buffer
unstructuredGridOneVoxel Substrat

[ContactOhmiqueE_Actor GetProperty] SetDiffuseColor 1.0 0.3 1.0
[SubEmetteur_Actor GetProperty] SetDiffuseColor     1.0 0.3 0.3
[Emetteur_Actor GetProperty] SetDiffuseColor        1.0 0.3 0.3
[Base_Actor GetProperty] SetDiffuseColor            0.3 1.0 0.3
[Collecteur_Actor GetProperty] SetDiffuseColor      1.0 0.3 0.3
[SubCollecteur_Actor GetProperty] SetDiffuseColor   1.0 0.3 0.3
[ContactOhmiqueC_Actor GetProperty] SetDiffuseColor 1.0 0.3 1.0
[Buffer_Actor GetProperty] SetDiffuseColor          1.0 0.3 0.3
[Substrat_Actor GetProperty] SetDiffuseColor        1.0 0.3 0.3

# First render, forces the renderer to create a camera with a
# good initial position
renWin Render

########## métallisation Ti-Au ##########

# Crée un vecteur de points
# L'allocation est dynamique
vtkPoints masque1Points
masque1Points InsertPoint  0  -80  -40   0
masque1Points InsertPoint  1    0  -40   0
masque1Points InsertPoint  2    0   -1   0
masque1Points InsertPoint  3   15   -1   0
masque1Points InsertPoint  4   15   -2.5 0
masque1Points InsertPoint  5   20   -2.5 0
masque1Points InsertPoint  6   20    2.5 0
masque1Points InsertPoint  7   15    2.5 0
masque1Points InsertPoint  8   15    1   0
masque1Points InsertPoint  9    0    1   0
masque1Points InsertPoint 10    0   40   0
masque1Points InsertPoint 11  -80   40   0

# Vecteur de cellules, sous la forme "n id01 id02 ... id0n m id11 id12 ... id1m ..." 
# Vaut ici "12 0 1 2 3 4 5 6 7 8 9 10 11"
vtkCellArray masque1Poly
masque1Poly InsertNextCell 12;#number of points
masque1Poly InsertCellPoint 0
masque1Poly InsertCellPoint 1
masque1Poly InsertCellPoint 2
masque1Poly InsertCellPoint 3
masque1Poly InsertCellPoint 4
masque1Poly InsertCellPoint 5
masque1Poly InsertCellPoint 6
masque1Poly InsertCellPoint 7
masque1Poly InsertCellPoint 8
masque1Poly InsertCellPoint 9
masque1Poly InsertCellPoint 10
masque1Poly InsertCellPoint 11
#
# L'ensemble qui décrit vertices, lines, polygons, et triangle strips
vtkPolyData masque1_Profile
# le vtkPolyData est une extension de vtkPointSet
masque1_Profile SetPoints masque1Points
# le vtkPolyData Contient spécifiquement un vecteur (vtkCellArray) de lignes,
# indexées à partir des points
# Ici "lines" contient "12 0 1 2 3 4 5 6 7 8 9 10 11"
# Ce qui veut dire qu'il y a 12 segments reposants sur les 13 points d'index 0 1 .. 12
masque1_Profile SetPolys masque1Poly


proc fromMasque {masque couche z0 dz r v b} {
# L'extrusion du polygone concave crée un capping faux (BUG de VTK)
    vtkDelaunay2D  ${masque}_${couche}_Del
    ${masque}_${couche}_Del SetInput ${masque}_Profile
    ${masque}_${couche}_Del SetSource ${masque}_Profile
    vtkLinearExtrusionFilter extrude${masque}_${couche}
    extrude${masque}_${couche} SetInput [${masque}_${couche}_Del GetOutput]
    extrude${masque}_${couche} SetExtrusionType 1
    extrude${masque}_${couche} SetVector 0 0 $dz
    extrude${masque}_${couche} CappingOn
    # La séquence classique vtkPolyDataMapper-vtkActor-vtkRenderer
    vtkPolyDataMapper ${masque}_${couche}_Map
    ${masque}_${couche}_Map SetInput [extrude${masque}_${couche} GetOutput]
    vtkActor ${masque}_${couche}_Actor
    [${masque}_${couche}_Actor GetProperty] SetDiffuseColor $r $v $b
    ${masque}_${couche}_Actor SetPosition 0 0 $z0
    ${masque}_${couche}_Actor SetMapper ${masque}_${couche}_Map
    ren1 AddProp ${masque}_${couche}_Actor
}

fromMasque masque1 TiAu 0 0.45 1 1 0

########## masque 2 ##########

# Crée un vecteur de points
# L'allocation est dynamique
vtkPoints masque2Points
masque2Points InsertPoint  0  -90  -50   0
masque2Points InsertPoint  1    0  -50   0
masque2Points InsertPoint  2    0  -12.5 0
masque2Points InsertPoint  3   25  -12.5 0
masque2Points InsertPoint  4   25  -50   0
masque2Points InsertPoint  5  105  -50   0
masque2Points InsertPoint  6  105   50   0
masque2Points InsertPoint  7   25   50   0
masque2Points InsertPoint  8   25   12.5 0
masque2Points InsertPoint  9    0   12.5 0
masque2Points InsertPoint 10    0   50   0
masque2Points InsertPoint 11  -90   50   0

vtkCellArray masque2Poly
masque2Poly InsertNextCell 12;#number of points
masque2Poly InsertCellPoint 0
masque2Poly InsertCellPoint 1
masque2Poly InsertCellPoint 2
masque2Poly InsertCellPoint 3
masque2Poly InsertCellPoint 4
masque2Poly InsertCellPoint 5
masque2Poly InsertCellPoint 6
masque2Poly InsertCellPoint 7
masque2Poly InsertCellPoint 8
masque2Poly InsertCellPoint 9
masque2Poly InsertCellPoint 10
masque2Poly InsertCellPoint 11
#
# L'ensemble qui décrit vertices, lines, polygons, et triangle strips
vtkPolyData masque2_Profile
# le vtkPolyData est une extension de vtkPointSet
masque2_Profile SetPoints masque2Points
# le vtkPolyData Contient spécifiquement un vecteur (vtkCellArray) de lignes,
# indexées à partir des points
# Ici "lines" contient "12 0 1 2 3 4 5 6 7 8 9 10 11"
# Ce qui veut dire qu'il y a 12 segments reposants sur les 13 points d'index 0 1 .. 12
masque2_Profile SetPolys masque2Poly

set suite {

vtkLight light
light SetFocalPoint 0 0 0
light SetPosition 2 2 10

ren1 RemoveProp ContactOhmiqueE_Actor
fromMasque masque1 ContactOhmiqueE -0.1 0.1 1.0 0.3 1.0
ren1 RemoveProp SubEmetteur_Actor
fromMasque masque1 SubEmetteur -0.2 0.1 1.0 0.3 0.3
ren1 RemoveProp Emetteur_Actor
fromMasque masque1 Emetteur -0.25 0.05 1.0 0.3 0.3

ren1 RemoveProp Base_Actor
fromMasque masque2 Base -0.30 0.05 0.3 1.0 0.3
ren1 RemoveProp SubCollecteur_Actor
fromMasque masque2 SubCollecteur -0.60 0.3 1.0 0.3 0.3
ren1 RemoveProp Collecteur_Actor
fromMasque masque2 Collecteur -0.65 0.05 1.0 0.3 0.3

}


# prevent the tk window from showing up then start the event loop
wm withdraw .



