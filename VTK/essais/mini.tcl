package require vtk
package require vtkinteraction

    vtkCylinderSource         leCylindre
    vtkCylinderSource         leCylindre2
set leCylindrePolyData       [leCylindre  GetOutput]
set leCylindrePolyData2      [leCylindre2 GetOutput]
    vtkPolyDataMapper         leMappeurDuCylindre  ; leMappeurDuCylindre  SetInput        $leCylindrePolyData
    vtkPolyDataMapper         leMappeurDuCylindre2 ; leMappeurDuCylindre2 SetInput        $leCylindrePolyData2
    vtkActor                  l_ActeurDuCylindre   ; l_ActeurDuCylindre   SetMapper       leMappeurDuCylindre
    vtkActor                  l_ActeurDuCylindre2  ; l_ActeurDuCylindre2  SetMapper       leMappeurDuCylindre2

    vtkRenderer               leRendeur            ; leRendeur            AddProp         l_ActeurDuCylindre
                                                     leRendeur            AddProp         l_ActeurDuCylindre2
    vtkRenderWindow           leRendeurDeFenetre   ; leRendeurDeFenetre   AddRenderer     leRendeur
                                                     leRendeurDeFenetre   Render

    vtkRenderWindowInteractor l_Interacteur        ; l_Interacteur        SetRenderWindow leRendeurDeFenetre
                                                     l_Interacteur        Initialize
# wm withdraw .

# Les touches de commande sont

# Button-Left   : rotation
# Button-Middle : translation
# Button-Right  : zoom

# w             : wireframe
# s             : solid

# r             : reset-camera

# Les objets vtkCylinderSource permettent de fabriquer des vtkPolyData
# qui seront pris par le vtkPolyDataMapper
# On change ici la hauteur et le diamêtre d'un des cylindres, et on le débouche

leCylindre2          SetHeight      1.5
leCylindre2          SetRadius      0.25
leCylindre2          SetCapping      0                            ; leRendeurDeFenetre Render

# Comme on vient de le dire, les cylindres sont des vtkPolyData
# On peut changer le nombre de facettes

leCylindre           SetResolution   32                           ; leRendeurDeFenetre Render
leCylindre2          SetResolution   32                           ; leRendeurDeFenetre Render

# Le vtkPolyDataMapper transforme le vtkPolyData en primitives graphiques.
# Pas grand chose à modifier, sauf si l'objet est très gros.
# Dans ce cas, on peut ajuster des paramètres qui jouent sur l'encombrement mémoire.

# Les primitives graphiques sont récupérées par l'objet vtkActor
# Cet objet possède les notions de couleur, texture, type de représentation.

[l_ActeurDuCylindre  GetProperty] SetColor 1.0000 0.3882 0.2784   ; leRendeurDeFenetre Render

[l_ActeurDuCylindre  GetProperty] SetRepresentationToWireframe    ; leRendeurDeFenetre Render

# Par défaut, les propriétés internes sont reprises des propriétés externes.
# On peut aussi créer un objet vtkProperty spécifique

vtkProperty interieurDuCylindre2
l_ActeurDuCylindre2 SetBackfaceProperty interieurDuCylindre2
interieurDuCylindre2 SetColor 0.0000 1.0000 0.0000                ; leRendeurDeFenetre Render

# L'objet vtkActor est une extension de l'objet vtkProp3D
# À ce titre, c'est lui qui permet de faire des transformations géométriques

l_ActeurDuCylindre   RotateX         30.0                         ; leRendeurDeFenetre Render
l_ActeurDuCylindre   RotateY        -45.0                         ; leRendeurDeFenetre Render

# L'objet vtkRenderer est chargé de la combinaison des vtkProp
# avec une caméra et des éclairages en vue de la fabrication de l'image.

leRendeur            SetBackground 0.1 0.2 0.4                    ; leRendeurDeFenetre Render
[leRendeur           GetActiveCamera] Zoom 1.5                    ; leRendeurDeFenetre Render

# L'objet vtkRenderWindow crée physiquement l'image : en relief ou autre.
# Cet objet est une extension de vtkWindow. C'est à ce niveau qu'on définit les dimensions de la fenêtre

leRendeurDeFenetre   SetSize 300 300                              ; leRendeurDeFenetre Render

# Pour récupérer l'image sous forme de fichier, il faut créer un objet vtkWindowToImageFilter

vtkWindowToImageFilter leFiltre                                   ; leFiltre SetInput leRendeurDeFenetre

# Et un système d'impression dans un format voulu :

vtkPNGWriter l_Imprimeur                                          ; l_Imprimeur SetInput [leFiltre GetOutput]
                                                                    l_Imprimeur SetFileName "/home/fab/Z/cylindres.png"

# C'est parti !

leRendeurDeFenetre Render
leFiltre Modified               ;# requis. Attention, cette commande lit la fenêtre X11 telle qu'elle est affichée ou cachée !
l_Imprimeur Write

# Revenons maintenant au vtkPolyData. Simplifions le cylindre. Avec trois facettes, on va avoir un prisme

leCylindre           SetResolution   3                            ; leRendeurDeFenetre Render

# On a déjà récupéré le pointeur sur le vtkPolyData, c'est $leCylindrePolyData

set nombreDeCellules [$leCylindrePolyData GetNumberOfCells] ;# 5 cellules pour le prisme

# Ce n'est pas la méthode préférée

catch {unset A}
catch {unset B}
for {set i 0} {$i < $nombreDeCellules} {incr i} {
    set cell [$leCylindrePolyData GetCell $i]
    set A($i) $cell
    lappend B($cell) $i
}

foreach cell [array names B] {
    puts stderr "$cell [$cell GetCellType] [$cell GetClassName]"   
}

###################################

# Création manuelle d'un cube :


 vtkPoints monCubePoints
  monCubePoints SetNumberOfPoints 8
  monCubePoints InsertPoint 0 0 0 0
  monCubePoints InsertPoint 1 1 0 0
  monCubePoints InsertPoint 2 0 1 0
  monCubePoints InsertPoint 3 1 1 0
  monCubePoints InsertPoint 4 0 0 1
  monCubePoints InsertPoint 5 1 0 1
  monCubePoints InsertPoint 6 0 1 1
  monCubePoints InsertPoint 7 1 1 1

# Parallèlépipède orthogonal
vtkVoxel monCube
# récupération du vtkldList du vtkCell inclus dans le vtkCell3D inclus dans le vtkVoxel
set listeDesPointsDeMonCube [monCube GetPointIds]
# Le vtkldList est un tableau key/value int/int
  $listeDesPointsDeMonCube InsertId 0 0
  $listeDesPointsDeMonCube InsertId 1 1
  $listeDesPointsDeMonCube InsertId 2 2
  $listeDesPointsDeMonCube InsertId 3 3
  $listeDesPointsDeMonCube InsertId 4 4
  $listeDesPointsDeMonCube InsertId 5 5
  $listeDesPointsDeMonCube InsertId 6 6
  $listeDesPointsDeMonCube InsertId 7 7
# ensemble combiné de n'importe quelles cellules
vtkUnstructuredGrid monCubeGrid
  monCubeGrid Allocate 1 1
  monCubeGrid InsertNextCell [monCube GetCellType] $listeDesPointsDeMonCube
  monCubeGrid SetPoints monCubePoints
vtkDataSetMapper monCubeMapper
  monCubeMapper SetInput monCubeGrid
vtkActor monCubeActor
  monCubeActor SetMapper monCubeMapper
  [monCubeActor GetProperty] SetDiffuseColor 1 0 0

leRendeur AddProp monCubeActor
