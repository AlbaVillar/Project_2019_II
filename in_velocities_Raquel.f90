! ***** Velocities inialization **** !
subroutine in_velocity(vel,N,Temp)
implicit none
integer :: N,i,j
real*8 :: Temp,kin,vel(N,3),suma(N),kinetic_en

! ** Random velocities ** !
do i=1,N
  vel(i,:)=(2d0*rand()-1d0)/2d0
end do

! ** Kinetic energy ** !
call subroutine kinetic_en(vel,N)
!kin=kinetic_en(vel,N)

! ** Reescaling Kinetic energy ** !
vel=vel*sqrt(N*3d0*Temp/(2d0*kin))

! ** Total velocity = 0 ** !
suma=0d0
do i=1,3
  do j=1,N
    suma(i)=suma(i)+vel(j,i)
  end do
end do
suma=suma/N
do i=1,N
  do j=1,3
    vel(i,j)=vel(i,j)-suma(j)
  end do
end do
end subroutine in_velocity
