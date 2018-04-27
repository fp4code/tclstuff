#include "tcl.h"

int twice(
        ClientData clientData,
        Tcl_Interp *interp,
        Tcl_Value *args,
        Tcl_Value *resultPtr) {
    resultPtr->type = TCL_DOUBLE;
    resultPtr->doubleValue = 2.0*args[0].doubleValue;
    return TCL_OK;
}

int Twice_Init(Tcl_Interp *interp) {
    Tcl_ValueType doudou[] = {TCL_DOUBLE, TCL_DOUBLE};
    Tcl_CreateMathFunc(interp, "twice", 1, doudou, twice, NULL);
    return TCL_OK;
}

