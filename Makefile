##Makefile for a Molecular Dynamics simulation program


#Compiler
F90=gfortran

#Main program
TARGET=program_main


#Energy, pressure, temperature and total momentum plot generation
energy.eps : Results.txt
	@echo "Generating plots with the results..."
	gnuplot Scripts_GNUPlot/plot_Energy_Raquel.gnu
	gnuplot Scripts_GNUPlot/plot_momentum.gnu
	gnuplot Scripts_GNUPlot/plot_rdf.gnu
	@echo Copying to Results folder...
	mkdir -p Results
	cp *.txt *.eps *.xyz Results
	@echo "Done!"

#Main program execution
Results.txt : $(TARGET).x Inputs/input.dat
	@echo "Executing the program with the input values ..." 
	mpirun -np 4 $(TARGET).x < Inputs/input.dat > log

#Compilation of the main program
$(TARGET).x : $(TARGET).o Ekinetic_Raquel.o boundary.o verlet_vel.o in_velocities_Raquel.o coordenadas_Raquel.o units_print.o temperatura.o trajectory.o radial.o moment_Raquel.o forces_RaquelNEW.o input.o kin_mpi.o verlet_mpi.o
	@echo "Compiling program_main.x ..."
	mpif90 -g -o $(TARGET).x $(TARGET).o Ekinetic_Raquel.o boundary.o verlet_vel.o in_velocities_Raquel.o coordenadas_Raquel.o units_print.o temperatura.o trajectory.o radial.o moment_Raquel.o forces_RaquelNEW.o input.o kin_mpi.o verlet_mpi.o

#$(TARGET).o : Code_MPI/program_main.f90
$(TARGET).o : Code_MPI/$(TARGET).f90
	mpif90 -g -c Code_MPI/$(TARGET).f90 Code_MPI/Ekinetic_Raquel.f90 Code_MPI/boundary.f90 Code_MPI/verlet_vel.f90 Code_MPI/in_velocities_Raquel.f90 Code_MPI/coordenadas_Raquel.f90 Code_MPI/units_print.f90 Code_MPI/temperatura.f90 Code_MPI/trajectory.f90 Code_MPI/radial.f90 Code_MPI/moment_Raquel.f90 Code_MPI/forces_RaquelNEW.f90 Code_MPI/input.f90 Code_MPI/kin_mpi.f90 Code_MPI/verlet_mpi.f90 

#Parallel
#kin_mpi.o : MPI_Code_MPI/kin_mpi.f90
#	mpif90 -g -o kin_mpi.o MPI_Code_MPI/kin_mpi.f90
#All files with extension .f90 are compiled to objects .o
#$(TARGET).o : Code_MPI/%.f90
#	@echo "Compiling the necessary subroutines ..."
#	mpif90 -g -c $<


##statistics : binning of the time series for different magnitudes
.PHONY : statistics
statistics :
	$(F90) -o binning.x Code_MPI/binning2.f90
	./binning.x
	gnuplot Scripts_GNUPlot/plot_binning.gnu
	@echo Moving results to Results_binning
	mkdir -p Results_binning
	cp *binning.txt *mit.txt *bin.eps Results_binning

##help: instructions about the use of this Makefile
.PHONY : help
help :
	@sed -n 's/^##//p' Makefile


##backup : make a compressed copy of the base code
.PHONY : backup
backup:
	tar -czvf "backup.tar.gz" Code_MPI/*.f90

##clean_all : rule to clean executable objects, results and images
.PHONY : clean_all
clean_all:
	@echo Removing compiled objects and results
	rm *.o *.txt *.eps *.xyz *.x

##clean_exe : rule to clean only executable objects
.PHONY : clean_exe
clean_exe:
	@echo Removing compiled objects only
	rm *.o *.x
