#R version 3.1.1 (2014-07-10)
#Laszlo Frazer 2015
#laszlo@laszlofrazer.com

#Reduce data collected by the vibrational sum frequency generation labview program
#for special case of three photon sum frequency "X3"
#using the spectral axis of the CCD
#you also need the file plottemplate.gp in the working directory

#Ensure that leading spaces, used to pad the file name, are sorted before digits
Sys.setlocale("LC_COLLATE", "C")

#command line argument 1:  the file stem, which is the part of the file name that is the same for every file, not including any spaces before the scan number
#command line argument 2:  a calibration spectrum recorded in winspec

#set these manually
calibrationoffset<-40; #per cm
laserwavelength<-809.1; #nanometers

file<-commandArgs(TRUE);
#quit if wrong number of command line arguments
stopifnot(2==length(file));

#picoseconds; time step used when running the data acquisition program
timestep<-as.numeric(read.csv(paste(file[1],"metadata.txt",sep=""),header=F,stringsAsFactors=F)[1,])

#read spectral calibration from first column of file
#convert nm to wavenumber shift relative to laser beam
spectrumcal<-(1e7/read.table(file[2])[1:1338,1]-1e7/laserwavelength+calibrationoffset);


#determine number of scans
scans<-strtoi(
	      substr(
		     unlist(
			    strsplit(#separate out the file stem
				     tail(
					  list.files(path=".",pattern=paste(file[1],".*s.*up.txt",sep=""))
					  ,1
					  )
				     ,file[1]))[[2]],
		     	1,5#five letters to describe number of scans
		     )
	      )+1;
print(paste("There are",scans,"scans in this dataset."));
#note that files are zero-indexed, so the number of scans is one more than the highest numbered file

#read in a sample unpumped file to see where on the nonspectral axis of the chip there is signal
firstunpumped<-read.table(list.files(path=".",pattern=paste(file[1],".*",0,"s.*up.txt",sep=""))[1]);


#loop through scans
#zero indexed
for(j in 0:(scans-1)){
	print(j);
	allratio<-{};

	#find the files for this scan, pumped and unpumped
	pumpedfiles<-list.files(path=".",pattern=paste(file[1],".*",j,"s.*[0123456789]p.txt",sep=""));

		
	for( i in 1:length(pumpedfiles)){
		#read region of CCD data which contains signal on the non-wavelength axis
		pumpedspectrum<-rowSums(read.table(pumpedfiles[i]));
		
		#compute transmittance
		ratio<-pumpedspectrum

		allratio<-rbind(allratio,ratio);
	}

	#compute sum across scans
	#warning: propagates NA
	if(j==0){
		allscan<-allratio;
	} else {
		allscan<-allscan+allratio;
	}
}

#prepend spectral calibration
allscan<-rbind(spectrumcal,allscan);

rows<-nrow(allscan);
write.table(
	    rbind(c(rows,timestep*0:(rows-2)),t(allscan))
	  ,paste(file[1],"reducedvsfg.gp",sep=""),row.names=FALSE,col.names=FALSE
	  );

#remove infitinites
allscan[is.infinite(allscan)]<-NA;

#write out wavelength integrated data
write.table(cbind(
			  timestep*0:(rows-2) #time calibration
			,colSums(t(allscan[2:rows,]),na.rm=TRUE) #data
		),paste(file[1],"reducedtime.gp",sep=""),row.names=FALSE,col.names=FALSE);

#prepare plot file
#TIMEPLACEHOLDER is obsolete
system(paste("sed 's/TIMEPLACEHOLDER/",timestep,"/' plottemplate.gp|sed 's/ROWSPLACEHOLDER/",rows,"/g'| sed 's/FILEPLACEHOLDER/",file[1],"/g' > ",file[1],"plotsettings.gp",sep=""));

#run plotting software
system(paste("gnuplot -e \"load '",file[1],"plotsettings.gp'\"",sep=""));

#convert to EPS to PDF
#for convenience of Windows users
system(paste("find . -name \"",file[1],"*.eps\" -exec epstopdf {} \";\"",sep=""));
