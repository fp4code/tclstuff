# 27 juin 2003 (FP)

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

# substrat
vtkPoints Layer0_Points
Layer0_Points SetNumberOfPoints 4
Layer0_Points InsertPoint  0 -147.5 -262.5  0
Layer0_Points InsertPoint  1  230   -262.5  0
Layer0_Points InsertPoint  2  230    115    0
Layer0_Points InsertPoint  3 -147.5  115    0

vtkPoints Layer1_Points
Layer1_Points SetNumberOfPoints 16
Layer1_Points InsertPoint  0 0      0   0
Layer1_Points InsertPoint  1 0     95   0
Layer1_Points InsertPoint  2 39     0   0
Layer1_Points InsertPoint  3 45   -35   0
Layer1_Points InsertPoint  4 45   -15   0
Layer1_Points InsertPoint  5 46.5 -15   0
Layer1_Points InsertPoint  6 46.5  -7.5 0
Layer1_Points InsertPoint  7 46.5   0   0
Layer1_Points InsertPoint  8 48.5 -15   0
Layer1_Points InsertPoint  9 48.5  -7.5 0
Layer1_Points InsertPoint 10 48.5   0   0
Layer1_Points InsertPoint 11 50   -35   0
Layer1_Points InsertPoint 12 50   -15   0
Layer1_Points InsertPoint 13 56     0   0
Layer1_Points InsertPoint 14 100    0   0
Layer1_Points InsertPoint 15 100   95   0

vtkPoints Layer3_Points
Layer3_Points SetNumberOfPoints 12
Layer3_Points InsertPoint  0  -5 -215 0
Layer3_Points InsertPoint  1  -5  -45 0
Layer3_Points InsertPoint  2  -5   -5 0
Layer3_Points InsertPoint  3  -5  100 0
Layer3_Points InsertPoint  4  35  -45 0
Layer3_Points InsertPoint  5  35   -5 0
Layer3_Points InsertPoint  6  60  -45 0
Layer3_Points InsertPoint  7  60   -5 0
Layer3_Points InsertPoint  8 105 -215 0
Layer3_Points InsertPoint  9 105  -45 0
Layer3_Points InsertPoint 10 105   -5 0
Layer3_Points InsertPoint 11 105  100 0


vtkPoints Layer4_Points
Layer4_Points SetNumberOfPoints 38
Layer4_Points InsertPoint  0 -135  -250   0
Layer4_Points InsertPoint  1 -135  -227.5 0
Layer4_Points InsertPoint  2 -135    30   0
Layer4_Points InsertPoint  3  -35  -227.5 0
Layer4_Points InsertPoint  4  -35   -40   0
Layer4_Points InsertPoint  5  -35   -10   0
Layer4_Points InsertPoint  6  -35    30   0
Layer4_Points InsertPoint  7    0  -210   0
Layer4_Points InsertPoint  8    0   -50   0
Layer4_Points InsertPoint  9   30   -40   0
Layer4_Points InsertPoint 10   30   -10   0
Layer4_Points InsertPoint 11   40   -40   0
Layer4_Points InsertPoint 12   40   -10   0
Layer4_Points InsertPoint 13   43.5 -50   0
Layer4_Points InsertPoint 14   43.5 -40   0
Layer4_Points InsertPoint 15   46.5 -50   0
Layer4_Points InsertPoint 16   46.5 -47   0
Layer4_Points InsertPoint 17   46.5 -43   0
Layer4_Points InsertPoint 18   46.5 -40   0
Layer4_Points InsertPoint 19   48.5 -50   0
Layer4_Points InsertPoint 20   48.5 -47   0
Layer4_Points InsertPoint 21   48.5 -43   0
Layer4_Points InsertPoint 22   48.5 -40   0
Layer4_Points InsertPoint 23   51.5 -50   0
Layer4_Points InsertPoint 24   51.5 -40   0
Layer4_Points InsertPoint 25   55   -40   0
Layer4_Points InsertPoint 26   55   -10   0
Layer4_Points InsertPoint 27   65   -40   0
Layer4_Points InsertPoint 28   65   -10   0
Layer4_Points InsertPoint 29  100  -210   0
Layer4_Points InsertPoint 30  100   -50   0
Layer4_Points InsertPoint 31  115  -227.5 0
Layer4_Points InsertPoint 32  115   -40   0
Layer4_Points InsertPoint 33  115   -10   0
Layer4_Points InsertPoint 34  115    30   0
Layer4_Points InsertPoint 35  215  -250   0
Layer4_Points InsertPoint 36  215  -227.5 0
Layer4_Points InsertPoint 37  215    30   0

vtkPoints Layer5_Points
Layer5_Points SetNumberOfPoints 30
Layer5_Points InsertPoint  0 -137.5 -252.5 0
Layer5_Points InsertPoint  1 -137.5 -225   0
Layer5_Points InsertPoint  2 -137.5  105   0
Layer5_Points InsertPoint  3  -30   -225   0
Layer5_Points InsertPoint  4  -30    -42.5 0
Layer5_Points InsertPoint  5  -30     -7.5 0
Layer5_Points InsertPoint  6  -30    105   0
Layer5_Points InsertPoint  7  -10   -220   0
Layer5_Points InsertPoint  8  -10    -47.5 0
Layer5_Points InsertPoint  9  -10     -2.5 0
Layer5_Points InsertPoint 10  -10    105   0
Layer5_Points InsertPoint 11   32.5  -42.5 0
Layer5_Points InsertPoint 12   32.5  -37.5 0
Layer5_Points InsertPoint 13   32.5  -12.5 0
Layer5_Points InsertPoint 14   32.5   -7.5 0
Layer5_Points InsertPoint 15   62.5  -42.5 0
Layer5_Points InsertPoint 16   62.5  -37.5 0
Layer5_Points InsertPoint 17   62.5  -12.5 0
Layer5_Points InsertPoint 18   62.5   -7.5 0
Layer5_Points InsertPoint 19  107.5 -220   0
Layer5_Points InsertPoint 20  107.5  -47.5 0
Layer5_Points InsertPoint 21  107.5   -2.5 0
Layer5_Points InsertPoint 22  107.5  105   0
Layer5_Points InsertPoint 23  112.5 -225      0
Layer5_Points InsertPoint 24  112.5  -42.5    0
Layer5_Points InsertPoint 25  112.5   -7.5    0
Layer5_Points InsertPoint 26  112.5  105      0
Layer5_Points InsertPoint 27  220   -252.5    0
Layer5_Points InsertPoint 28  220   -225      0
Layer5_Points InsertPoint 29  220    105      0

vtkPoints Layer7_Points
Layer7_Points SetNumberOfPoints 16
Layer7_Points InsertPoint  0 -130   -207.5 0
Layer7_Points InsertPoint  1 -130     25   0
Layer7_Points InsertPoint  2  -40   -207.5 0
Layer7_Points InsertPoint  3  -40     25   0
Layer7_Points InsertPoint  4    5   -205   0
Layer7_Points InsertPoint  5    5    -55   0
Layer7_Points InsertPoint  6    5      5   0
Layer7_Points InsertPoint  7    5     90   0
Layer7_Points InsertPoint  8   95   -205   0
Layer7_Points InsertPoint  9   95    -55   0
Layer7_Points InsertPoint 10   95      5   0
Layer7_Points InsertPoint 11   95     90   0
Layer7_Points InsertPoint 12  120 -207.5   0
Layer7_Points InsertPoint 13  120   25     0
Layer7_Points InsertPoint 14  210 -207.5   0
Layer7_Points InsertPoint 15  210   25     0

vtkQuad aQUAD
vtkTriangle aTRIANGLE

proc newQuad {ids} {
    global aQUAD
    if {[llength $ids] != 4} {
	return -code error "newQuad expect 4 elements list, not \"$ids\""
    }
    set quad [aQUAD NewInstance]
    set quadPointIds [$quad GetPointIds]
    set i 0
    foreach id $ids {
	$quadPointIds SetId $i $id
	incr i
    }
    return $quad
}

proc newTriangle {ids} {
    global aTRIANGLE
    if {[llength $ids] != 3} {
	return -code error "newTriangle expect 3 elements list, not \"$ids\""
    }
    set triangle [aTRIANGLE NewInstance]
    set trianglePointIds [$triangle GetPointIds]
    set i 0
    foreach id $ids {
	$trianglePointIds SetId $i $id
	incr i
    }
    return $triangle
}



# ${name}_Points doit exister
# crée ${name}_UnstructuredGrid ${name}_Mapper ${name}_Actor
proc newLayer {name listOfQuads listOfTriangles} {
    global aQUAD aTRIANGLE
    set unstructuredGridName ${name}_UnstructuredGrid
    vtkUnstructuredGrid $unstructuredGridName
    set n 0
    incr n [llength $listOfQuads]
    incr n [llength $listOfTriangles]
    $unstructuredGridName Allocate $n $n
    foreach q $listOfQuads {
	$unstructuredGridName InsertNextCell [aQUAD GetCellType] [[newQuad $q] GetPointIds]
	$unstructuredGridName SetPoints ${name}_Points
    }
    foreach t $listOfTriangles {
	$unstructuredGridName InsertNextCell [aTRIANGLE GetCellType] [[newTriangle $t] GetPointIds]
	$unstructuredGridName SetPoints ${name}_Points
    }
    vtkDataSetMapper ${name}_Mapper
    ${name}_Mapper SetInput ${name}_UnstructuredGrid

    vtkActor ${name}_Actor
    ${name}_Actor SetMapper ${name}_Mapper
}

proc fromMasqueSimple {layer couche z0 dz} {
    global COLOR
# L'extrusion du polygone concave crée un capping faux (BUG de VTK)
    set extf ${layer}_${couche}_LinearExtrusionFilter
    vtkLinearExtrusionFilter $extf
    set gf ${layer}_${couche}_GeometryFilter
    vtkGeometryFilter $gf
    $gf SetInput ${layer}_UnstructuredGrid
    $extf SetInput [$gf GetOutput]
    $extf SetExtrusionType 1
    $extf SetVector 0 0 $dz
    $extf CappingOn
    # La séquence classique vtkPolyDataMapper-vtkActor-vtkRenderer
    vtkPolyDataMapper ${layer}_${couche}_Map
    ${layer}_${couche}_Map SetInput [$extf GetOutput]
    vtkActor ${layer}_${couche}_Actor
    set rvb $COLOR($couche)
    [${layer}_${couche}_Actor GetProperty] SetDiffuseColor [lindex $rvb 0] [lindex $rvb 1] [lindex $rvb 2]
    ${layer}_${couche}_Actor SetPosition 0 0 $z0
    ${layer}_${couche}_Actor SetMapper ${layer}_${couche}_Map
    ren1 AddProp ${layer}_${couche}_Actor
}


set COLOR(ContactOhmiqueE) {0.6 0.2 0.2}
set COLOR(SubEmetteur) {1.0 0.3 0.3}
set COLOR(Emetteur) {1.0 0.3 0.3}
set COLOR(Base) {1.0 0.3 0.3}
set COLOR(Collecteur) {0.3 1.0 0.3}
set COLOR(SubCollecteur) {0.3 1.0 0.3}
set COLOR(ContactOhmiqueC) {0.6 0.2 0.2}
set COLOR(Buffer) {0.3 1.0 0.3}
set COLOR(Substrat)  {0.3 1.0 0.3}
set COLOR(TiAu) {1 1 0}
set COLOR(Resine) {0.9 0.9 0.7}

newLayer Layer0 {{0 1 2 3}} {}
newLayer Layer1 {{0 14 15 1} {3 11 12 4} {5 8 10 7}} {}
newLayer Layer3 {{0 8 9 1} {2 10 11 3} {4 6 7 5}} {}
newLayer Layer4 {{0 35 36 1} {1 3 6 2} {4 9 10 5} {7 29 30 8} {11 25 26 12} {15 19 22 18} {27 32 33 28} {31 36 37 34}}\
                {{13 15 16} {14 17 18} {19 23 20} {21 24 22}}
newLayer Layer5 {{0 27 28 1} {1 3 6 2} {4 11 14 5} {7 19 20 8} {9 21 22 10} {12 16 17 13} {15 24 25 18} {23 28 29 26}} {}
newLayer Layer7 {{0 2 3 1} {4 8 9 5} {6 10 11 7} {12 14 15 13}} {}

fromMasqueSimple Layer1 TiAu             0    0.45
fromMasqueSimple Layer1 ContactOhmiqueE -0.1  0.1
fromMasqueSimple Layer1 SubEmetteur     -0.2  0.1
fromMasqueSimple Layer1 Emetteur        -0.25 0.05
fromMasqueSimple Layer3 Base            -0.30 0.05
fromMasqueSimple Layer3 SubCollecteur   -0.60 0.3
fromMasqueSimple Layer3 Collecteur      -0.65 0.05
fromMasqueSimple Layer0 ContactOhmiqueC -0.70 0.05
fromMasqueSimple Layer0 Buffer          -0.75 0.05
fromMasqueSimple Layer0 Substrat        -5.75 5

fromMasqueSimple Layer4 TiAu            -0.30  0.11
#fromMasqueSimple Layer4 TiAu            0.45 0.11

fromMasqueSimple Layer5 Resine           -0.3 1.4



ren1 AddProp Layer1_TiAu_Actor ; renWin Render
ren1 AddProp Layer1_ContactOhmiqueE_Actor ; renWin Render
ren1 AddProp Layer1_SubEmetteur_Actor ; renWin Render
ren1 AddProp Layer1_Emetteur_Actor ; renWin Render
ren1 AddProp Layer3_Base_Actor ; renWin Render
ren1 AddProp Layer3_SubCollecteur_Actor ; renWin Render
ren1 AddProp Layer3_Collecteur_Actor ; renWin Render
ren1 AddProp Layer4_TiAu_Actor ; renWin Render
ren1 AddProp Layer5_Resine_Actor ; renWin Render

# Pour récupérer l'image sous forme de fichier, il faut créer un objet vtkWindowToImageFilter

vtkWindowToImageFilter leFiltre                                   ; leFiltre SetInput renWin

# Et un système d'impression dans un format voulu :

vtkPNGWriter l_Imprimeur                                          ; l_Imprimeur SetInput [leFiltre GetOutput]


proc iii {f} {
# C'est parti !

    l_Imprimeur SetFileName Z/$f
    renWin Render
    leFiltre Modified               ;# requis. Attention, cette commande lit la fenêtre X11 telle qu'elle est affichée ou cachée !
    l_Imprimeur Write

}


set rien {

ren1 RemoveProp Layer1_TiAu_Actor
ren1 RemoveProp Layer1_ContactOhmiqueE_Actor
ren1 RemoveProp Layer1_SubEmetteur_Actor
ren1 RemoveProp Layer1_Emetteur_Actor
ren1 RemoveProp Layer3_Base_Actor
ren1 RemoveProp Layer3_SubCollecteur_Actor
ren1 RemoveProp Layer3_Collecteur_Actor
ren1 RemoveProp Layer4_TiAu_Actor
ren1 RemoveProp Layer5_Resine_Actor

ren1 RemoveProp  Layer1_SubEmetteur_Actor
ren1 RemoveProp Emetteur_Actor
ren1 RemoveProp Base_Actor
ren1 RemoveProp SubCollecteur_Actor
ren1 RemoveProp Collecteur_Actor

}
dd source TBHpsgV2.tcl

ren1 AddProp Layer1_Actor
ren1 AddProp Layer3_Actor
ren1 AddProp Layer4_Actor
ren1 AddProp Layer7_Actor

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

[

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


set rien {
ren1 RemoveProp Layer1_Actor
ren1 RemoveProp Layer3_Actor
ren1 RemoveProp Layer4_Actor
ren1 RemoveProp Layer7_Actor
}
