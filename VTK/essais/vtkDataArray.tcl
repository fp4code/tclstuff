set HELP(vtkDataArray) {
    




}

set VTK_TYPE(VOID)            0
set VTK_TYPE(BIT)             1 
set VTK_TYPE(CHAR)            2
set VTK_TYPE(UNSIGNED_CHAR)   3
set VTK_TYPE(SHORT)           4
set VTK_TYPE(UNSIGNED_SHORT)  5
set VTK_TYPE(INT)             6
set VTK_TYPE(UNSIGNED_INT)    7
set VTK_TYPE(LONG)            8
set VTK_TYPE(UNSIGNED_LONG)   9
set VTK_TYPE(FLOAT)          10
set VTK_TYPE(DOUBLE)         11 
set VTK_TYPE(ID_TYPE)        12

vtkVoidArray VoidA
vtkBitArray BitA
vtkCharArray CharA
vtkUnsignedCharArray UnsignedCharA
vtkShortArray ShortA
vtkUnsignedShortArray UnsignedShortA
vtkIntArray IntA
vtkUnsignedIntArray UnsignedIntA
vtkLongArray LongA
vtkUnsignedLongArray UnsignedLongA
vtkFloatArray FloatA
vtkDoubleArray DoubleA
vtkIdTypeArray IdTypeA


FloatA SetNumberOfComponents 2 ;# On utilise donc GetTuple2 et SetTuple2
FloatA SetNumberOfTuples 3

FloatA SetComponent 0 0 0
FloatA SetComponent 0 1 1
FloatA SetComponent 1 0 10
FloatA SetComponent 1 1 11
FloatA SetComponent 2 0 20
FloatA SetComponent 2 1 21

FloatA GetTuple2 1
# FloatA SetTuple2 100 101

proc dumpArray {array} {
    puts "Type = [$array GetDataType]"
    set a [$array GetNumberOfTuples]
    set b [$array GetNumberOfComponents]
    for {set i 0} {$i < $a} {incr i} {
	puts -nonewline "$i"
	for {set j 0} {$j < $b} {incr j} {
	    puts -nonewline " [$array GetComponent $i $j]"
	}
	puts {}
    }
}

dumpArray FloatA
FloatA InsertNextTuple2 55. 56.
FloatA InsertTuple2 1 33. 34.
dumpArray FloatA
