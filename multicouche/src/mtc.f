C23456789012345678901234567890123456789012345678901234567890123456789012

C derniere révision  Apr  9  1999 (FP)
C 8 juillet 2000, à compilation, pbs 
/home/fab/A/fidev/Tcl/multicouche/src/mtc.f:146: 
         subroutine mtc_pkd(ipolar, zeps, dd_n, zkpa_n, zp_n, zkd_n, idim)
                    1
/home/fab/A/fidev/Tcl/multicouche/src/mtc.f:221: (continued):
         call mtc_pkd(ipolar, zeps, dd_n, zkpa_n, zp_n, zkd_n, idim)
              2
Argument #4 (named `zkpa_n') of `mtc_pkd' is passed by reference at (2) but is a function at (1) [info -f g77 M GLOBALS]

REVOIR, DONC !!!

C---------------------------
C Combinaison de matrices S
C---------------------------

      subroutine mtc_sc(zs1, zs2, ierr)
      
C     Calcule la matrice zs2 = Sac comme combinaison de zs1 = Sab
C                                                    et zs2 = Sbc
C     Les matrices sont rangées dans l'ordre 11 12 21 22

C Les matrices S sont ordonnées (S11 S12 S21 S22)
C                             = (r12 t21 t12 r22)
C avec                    rab = a_out/a_in, b_in=0
C                         tab = b_out/a_in, b_in=0

      complex*16 zs1,zs2,zdenom
      dimension zs1(4), zs2(4)
      integer ierr
      zdenom=(1.0D0-zs1(4)*zs2(1))
      if (zdenom.eq.0.0) then
         ierr=1
         return
      endif
      ierr=0   
      zdenom=1.0D0/zdenom
      zs1(2)=zs1(2)*zdenom
      zs2(3)=zs2(3)*zdenom
      zs2(1)=zs1(1)+zs1(2)*zs2(1)*zs1(3)
      zs2(4)=zs2(4)+zs2(3)*zs1(4)*zs2(2)
      zs2(2)=zs1(2)*zs2(2)
      zs2(3)=zs2(3)*zs1(3)
      return
      end

C-------------------------------
C Initialisation d'une matrice S
C-------------------------------

      subroutine mtc_si(zs)

C initialise zs "unité"

C Les matrices S sont ordonnées (S11 S12 S21 S22)
C                             = (r12 t21 t12 r22)
C avec                    rab = a_out/a_in, b_in=0
C                         tab = b_out/a_in, b_in=0

      complex*16 zs
      dimension zs(4)
      zs(1)=0.0D0
      zs(2)=1.0D0
      zs(3)=1.0D0
      zs(4)=0.0D0
      return
      end

C-----------------------------------------
C Construction d'une matrice S d'interface
C----------------------------------------

      subroutine mtc_sf(p1, p2, zs, ierr)

C matrice S d'interface

C Les matrices S sont ordonnées (S11 S12 S21 S22)
C                             = (r12 t21 t12 r22)
C avec                    rab = a_out/a_in, b_in=0
C                         tab = b_out/a_in, b_in=0

      complex*16 p1, p2, zs
      integer ierr
      complex*16 denom
      dimension zs(4)

      denom = p1+p2
      if (denom.eq.0.0) then
         ierr=1
         return
      endif
      ierr=0
      denom=1.0D0/denom
      zs(1)=(p1-p2)*denom
      zs(4)=-zs(1)
      denom=2.0D0*denom
      zs(2)=p1*denom
      zs(3)=p2*denom
      return
      end

C--------------------------------
C Ajout d'une interface du côté 1
C--------------------------------

      subroutine mtc_scf(p1, p2, zs, ierr)

C mtfsc avec interface

C Les matrices S sont ordonnées (S11 S12 S21 S22)
C                             = (r12 t21 t12 r22)
C avec                    rab = a_out/a_in, b_in=0
C                         tab = b_out/a_in, b_in=0

      complex*16 p1, p2, zs1, zs
      dimension zs1(4), zs(4)
      integer ierr

      call mtc_sf(p1, p2, zs1, ierr)
      if (ierr.eq.1) then
         return
      endif
      call mtc_sc(zs1, zs, ierr)
      return
      end

C----------------------
C Ajout d'un intervalle
C----------------------

      subroutine mtc_scv(zkd_n, zs)

C mtfsc un intervalle

C Les matrices S sont ordonnées (S11 S12 S21 S22)
C                             = (r12 t21 t12 r22)
C avec                    rab = a_out/a_in, b_in=0
C                         tab = b_out/a_in, b_in=0

      complex*16 zkd_n, zs, zt
      dimension zs(4)
C revoir la reduction
      if (zkd_n.eq.0.0) then
         return
      end if
      zt = exp(3.14159265358979323846D0 * 2.0D0 * zkd_n)
      zs(1) = zt*zt*zs(1)
      zs(2) = zt*zs(2)
      zs(3) = zt*zs(3)
      end

C-------------------------------------------------
C Précalcul des termes d'interface et d'intervalle
C-------------------------------------------------

      subroutine mtc_pkd(ipolar, zeps, dd_n, zkpa_n, zp_n, zkd_n, idim)

C     calcule, à partir d'un vecteur de constantes diélectriques (zeps)
C                       d'un vecteur d'épaisseurs
C                          normalisées à lambda (dd_n)
C                       d'une composante parallèle zkpa_n
C                          (normalisée par k0=2pi/lambda)
C                       les valeurs des p (normalisés par k0) zp_n
C                       et les valeurs des kperp*epaisseur
C                          (normalisés par 2pi) zkd_n

      character*1 ipolar
      complex*16 zeps, zkpa_n, zp_n, zkd_n, zkpe, gdsqrt
      real*8 dd_n
      integer idim,i
      dimension zeps(*), dd_n(*), zp_n(*), zkd_n(*)
      external gdsqrt

      if (ipolar.eq.'E') then
         do i=1,idim
            zkpe = gdsqrt(zeps(i) - zkpa_n(i)*zkpa_n(i))
            zkd_n(i) = dd_n(i)*zkpe
            zp_n(i) = zkpe
         end do
      else if (ipolar.eq.'M') then
         do i=1,idim
            zkpe = gdsqrt(zeps(i) - zkpa_n(i)*zkpa_n(i))
            zkd_n(i) = dd_n(i)*zkpe
            zp_n(i) = zkpe/zeps(i)
         end do
      else
         call horreur('mtc_k : bad argument ipolar="'//ipolar//'"')
      end if
      end
      
C----------------------------------------
C calcul de la matrice S d'un multicouche
C----------------------------------------

      subroutine mtc_s(ipolar, zeps, dd_n, zkpa_n,
     +                 zp_n, zkd_n, zs, idim, ierr)

C     calcule, à partir d'un vecteur de constantes diélectriques (zeps(idim))
C                       d'un vecteur d'épaisseurs
C                          normalisées à lambda (dd_n(idim))
C                       d'une composante parallèle zkpa_n
C                          (normalisée par k0=2pi/lambda)

C calcule accessoirement
C                       les valeurs des p (normalisés par k0) zp_n(idim)
C                       et les valeurs des kperp*epaisseur
C                          (normalisés par 2pi) zkd_n(idim)


C Les matrices S sont ordonnées (S11 S12 S21 S22)
C                             = (r12 t21 t12 r22)
C avec                    rab = a_out/a_in, b_in=0
C                         tab = b_out/a_in, b_in=0

C La matrice correspond à S1N en allant de 1 vers N, à
C un intervalle zkd_n(1) zeps(1)
C une interface 1/2
C un intervalle zkd_n(2) zeps(2)
C une interface 2/3
C ...
C un intervalle zkd_n(N-1) zeps(N-1)
C une interface N-1/N
C un intervalle zkd_n(N) zeps(N)

      character*1 ipolar
      complex*16 zeps, zkpa_n, zp_n, zkd_n, zs
      real*8 dd_n
      integer idim, i, ierr
      dimension zeps(*), dd_n(*), zp_n(*), zkd_n(*), zs(4)
 
      call mtc_pkd(ipolar, zeps, dd_n, zkpa_n, zp_n, zkd_n, idim)

      call mtc_si(zs)
      call mtc_scv(zkd_n(idim), zs)
      do i=idim-1,1,-1
         call mtc_scf(zp_n(i), zp_n(i+1), zs, ierr)
         if (ierr.eq.1) then
            return
         end if
         call mtc_scv(zkd_n(i), zs)
      end do
      end
      
