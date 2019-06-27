#include "tcl.h"
#include <math.h>
#include "tclBlas.h"
#include "tclcomplexes.h"
#include <string.h>

static char *tetm[] = {"TE", "TM"};
static char cpolar[] = {'E', 'M'};

static char *reim[] = {"Re", "Im"};

int multicouche_s(ClientData dummy, Tcl_Interp *interp,
			     int objc, Tcl_Obj *CONST objv[]) {
    Tcl_Obj *CONST*objPtr = objv+1;
    doublecomplex *zeps, zkpa, *zs, *zp, *zkd_n;
    double *d;
    int idim, idim1, ierr;
    int polarIndex;

    if (objc != 8) {
	Tcl_WrongNumArgs(interp, 1, objv,
	                 "TE|TM epsVector dVector kpara pVector kdNVector zs");
	return TCL_ERROR;
    }

    if (Tcl_GetIndexFromObj(interp, *objPtr++, tetm, "tetm", TCL_EXACT, &polarIndex) != TCL_OK) {
	return TCL_ERROR;
    }

    if (blasGetFullSimpleVector(interp, *objPtr++, BLASDOUBLECOMPLEX, &idim, (blasScalar**)&zeps)
	!= TCL_OK) {
	return TCL_ERROR;
    }
   
    if (blasGetFullSimpleVector(interp, *objPtr++, BLASDOUBLE, &idim1, (blasScalar**)&d)
	!= TCL_OK) {
	return TCL_ERROR;
    }
    if (idim1 != idim) {
	Tcl_SetObjResult(interp, Tcl_NewStringObj("pas les même dimensions", -1));
	return TCL_ERROR;
    }
   
    if (complexGetDoubleComplexFromObj(interp, *objPtr++, &zkpa) != TCL_OK) {
	return TCL_ERROR;
    }

    if (blasGetFullSimpleVector(interp, *objPtr++, BLASDOUBLECOMPLEX, &idim1, (blasScalar**)&zp)
	!= TCL_OK) {
	return TCL_ERROR;
    }
    if (idim1 != idim) {
	Tcl_SetObjResult(interp, Tcl_NewStringObj("pas les même dimensions", -1));
	return TCL_ERROR;
    }
   
    if (blasGetFullSimpleVector(interp, *objPtr++, BLASDOUBLECOMPLEX, &idim1, (blasScalar**)&zkd_n)
	!= TCL_OK) {
	return TCL_ERROR;
    }
    if (idim1 != idim) {
	Tcl_SetObjResult(interp, Tcl_NewStringObj("pas les même dimensions", -1));
	return TCL_ERROR;
    }
   
    if (blasGetFullSimpleVector(interp, *objPtr++, BLASDOUBLECOMPLEX, &idim1, (blasScalar**)&zs)
	!= TCL_OK) {
	return TCL_ERROR;
    }
    if (idim1 != 4) {
	Tcl_SetObjResult(interp, Tcl_NewStringObj("dim(zs) != 4", -1));
	return TCL_ERROR;
    }
   
    mtc_s_(&cpolar[polarIndex], zeps, d, &zkpa, &idim, zp, zkd_n, zs, &ierr);
    
    if (ierr != 0) {
	Tcl_SetObjResult(interp, Tcl_NewStringObj("Erreur de calcul", -1));
	return TCL_ERROR;
    }

    Tcl_ResetResult(interp);
    return TCL_OK;
}


int Multicouche_Init(Tcl_Interp *interp) {
    Tcl_CreateObjCommand(interp, "::multicouche::s"  , multicouche_s  , 0, NULL);
    return TCL_OK;
}





