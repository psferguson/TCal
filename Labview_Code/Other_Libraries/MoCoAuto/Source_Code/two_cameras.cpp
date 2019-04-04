/*
	This code (originally an SBIG example code) was adapted by Nicholas Mondrik during June/July 2013 to
	interface with the monochromater Labview software via a communication
	file.  It (should) work(s) with any SBIG camera that uses the SBIG universal driver,
	but testing has only been done with an STF-8300M and ST-402 (the red and black SBIG CCDs in the lab).

	Current known/suspected bugs and Unimplemented features--

	Using the GetGrabState function causes the camera to miss readout steps for some reason unbeknownst to me.  As such,
	The LabView program just times how long the PD stays on using a wait command, rather than explicitly stopping the PD
	from saving when the camera changes from exposing light to digitizing light.


	Filepath control has yet to be implemented.
  ToDo:
  Make using two cameras optional.

	|============Change Log=======================================================================================================|
	|Author           |Date      |Changes                                                                                         |
	|-----------------|----------|------------------------------------------------------------------------------------------------|
	|Nicholas Mondrik |07/08/2013|Finished Primary Features.  Still need to implement Temperature Control and other documentation.|
	|Nicholas Mondrik |07/12/2013|Finished Secondary Features.  Darks and Temperature Control are now active.                     |
  |Peter Ferguson   |03/29/2019|Adding in a second camera and prefix to image names
*/

/*
Command line arguements should be passed in the following order and manner-
1. Exposure time [seconds]
2. Enable Regulation [?1:0]
3. Camera Temperature [Celsius]
4. Starting Wavelength [nanometers]
5. Ending Wavelength [nanometers]
6. Increment [nanometers]
7. Scan Prefix
*/
/* to compile run the follwoing command in visual c++
	cl /EHsc two_cameras.cpp csbigcam.cpp csbigimg.cpp SBIGUDrv.lib  cfitsio.lib /Fe..\CCDautomation2camera.exe
*/


#ifdef HAVE_CONFIG_H
 #include <config.h>
#endif

#include <ppl.h>
#include <vector>
#include <stdlib.h>
#include <stdio.h>
#include <sstream>
#include <iostream>
#include <string>
#include <fstream>
#include <direct.h>
#include <windows.h>
#include <time.h>

using namespace concurrency;
using namespace std;

#include "csbigcam.h"
#include "csbigimg.h"

#define LINE_LEN 80

int debugfunc(CSBIGCam *cptr, int wavel, double exptime) {
	stringstream stream;
	ofstream debugfile;
	string dbugline;
	GRAB_STATE dbuggrab;
	double dbugpct;
	time_t start_time;

	stream << wavel << "nmdebug.txt";
	dbugline = stream.str();
	stream.str("");
	debugfile.open(dbugline);
	if (debugfile.is_open()) {
		start_time = time(NULL);
		do {
			cptr->GetGrabState(dbuggrab, dbugpct);
			debugfile << "GRAB STATE == " << dbuggrab << " AND PCT COMP == " << dbugpct << endl;
			Sleep(100);
		} while(time(NULL) - start_time < exptime);
	} else {
		cout << "error opening debug file." << endl;
	}
	debugfile.close();
	return(0);

};


int main(int argc, char *argv[])
{
  CSBIGCam *pCam1 = (CSBIGCam *)0;
  CSBIGCam *pCam2 = (CSBIGCam *)0;
	CSBIGImg *pImg1 = (CSBIGImg *)0;
  CSBIGImg *pImg2 = (CSBIGImg *)0;
	PAR_ERROR err;
	SBIG_FILE_ERROR ferr;
  string cname1,cname2;
	string sPort1,sPort2;
	int height, width;
	double exposuretime = atof(argv[1]);
	fstream sdownfile;
	fstream InstrFile;
	MY_LOGICAL enabletempreg = atoi(argv[2]);
	double tempset = atof(argv[3]);
	int wlstart = atoi(argv[4]);
	int wlend = atoi(argv[5]);
	int wlincrement= atoi(argv[6]);
	vector<int> wlvector(1,wlstart);
	int i = 1;
	int n = 0;
  string scanprefix=argv[7];
	stringstream sstrm1, sstrm2;
	string imname1,imname2;
	bool isdark = false;

	do { // allow break out


    		// Try to Establish a link to the first camera
    		sPort1 = "USB";
    		cout << "Creating the SBIGCam Object on " << sPort1 << "..." << endl;
    		pCam1 = new CSBIGCam(DEV_USB);

        // Try to Establish a link to the first camera
    		sPort2 = "USB";
    		cout << "Creating the SBIGCam Object on " << sPort2 << "..." << endl;
    		pCam2 = new CSBIGCam(DEV_USB);

    		//Initialization Error Handling
    		if ( (err = pCam1->GetError()) != CE_NO_ERROR )
    			break;
    		cout << "Establishing a Link to the " << sPort1 << " Camera..." << endl;
    		if ( (err = pCam1->EstablishLink()) != CE_NO_ERROR )
    			break;
    		cout << "Link Established to Camera Type: " << pCam1->GetCameraTypeString() << endl;
    		if ( (err = pCam1->GetFullFrame(width, height)) != CE_NO_ERROR )
    			break;

        // second camera
        if ( (err = pCam2->GetError()) != CE_NO_ERROR )
          break;
        cout << "Establishing a Link to the " << sPort2 << " Camera..." << endl;
        if ( (err = pCam2->EstablishLink()) != CE_NO_ERROR )
          break;
        cout << "Link Established to Camera Type: " << pCam2->GetCameraTypeString() << endl;
        if ( (err = pCam2->GetFullFrame(width, height)) != CE_NO_ERROR )
          break;

        cname1=pCam1->GetCameraTypeString();
        cname2=pCam2->GetCameraTypeString();

		//CCD Tempset
    if (enabletempreg) {
      cout << "Setting CCD temperature to " << tempset << " degrees Celsius.  Please wait..." << endl;
      pCam1->SetTemperatureRegulation(enabletempreg, tempset);
      pCam2->SetTemperatureRegulation(enabletempreg, tempset);
    } else {
      cout << "No temperature control requested." << endl;
    }
		//Confirmation of range and increment
    cout << "The requested wavelength scan begins at " << wlstart << " and ends at " << wlend << " with step size " << wlincrement << endl;

		do {
			if (wlvector[i-1] == wlend) {
				break;
			}
			wlvector.push_back(wlstart + i*wlincrement);
			++i;

		} while(1);

    cout << "The exposure time requested is " << exposuretime << " seconds." <<endl;  //Avg readout time for ST-8300M ~= 9s
    cout << "Scan prefix is "<< scanprefix << endl;
    pCam1->SetExposureTime(exposuretime);
    pCam2->SetExposureTime(exposuretime);

		//This loop watches for a file named "communication.txt" in the specified directory.  When LabView wants to get an image, it creates the "communication.txt" file.
		//The program takes the image with the desired exposure parameters.  Once readout is finished, the program deletes the "communication.txt" file and LabView continues
		//to the next wavelength.  To properly shutdown the device and drivers, a file named "shutdown.txt" is created, which causes the program to break out of the loop
		//and shut down.  This file can be generated when LabView is done with the automation process by pressing the stop button in the bottom left of the front panel.

		//It should be noted that the process goes LIGHT[XXXnm] --> DARK[XXXnm] --> LIGHT[XXX+1nm] --> DARK[XXX+1nm] and so forth, as seen by the isdark flag.
		do {
			Sleep(100);
			//Check to see if we need to shut down the camera.
			sdownfile.open("shutdown.txt");
			if (sdownfile.is_open()) {
				cout << "Shutdown file is present, shutting down." << endl;
				break;
			}
			//Check to see if we need to take an image.
			InstrFile.open("communication.txt");
			if (!InstrFile.is_open()) {
				continue;
			} else {

			InstrFile.close();
			if (!isdark)
				cout << "Taking light image on " << sPort1 << "..." << endl;
			else
				cout << "Taking dark image on " << sPort1 << "..." << endl;

      pImg2 = new CSBIGImg;


      concurrency::parallel_invoke(
				[&]{pImg1 = new CSBIGImg;
						pCam1->GrabImage(pImg1, SBDF_LIGHT_ONLY);
						pImg1->AutoBackgroundAndRange();
						pImg1->HorizontalFlip();
						pImg1->VerticalFlip();
						},
				[&]{pCam2->GrabImage(pImg2, SBDF_LIGHT_ONLY);}
			);

      pImg2->AutoBackgroundAndRange();

      pImg2->HorizontalFlip();

      pImg2->VerticalFlip();

			if (err != 0)
				cout << "The error code from image acquisition is " << err << " which corresponds to " << pCam1->GetErrorString(err) << endl;
			else
				cout << "Image acquisition completed without error." << endl;



			//Save Image
			if (!isdark) {
        sstrm1 << scanprefix << "_" << cname1 <<"_" << wlvector[n] << "_" << "nm.fits";
        sstrm2 << scanprefix << "_" << cname2 <<"_" << wlvector[n] << "_" << "nm.fits";
				imname1 = sstrm1.str();
        imname2 = sstrm2.str();
				cout << "Saving image " << imname1 << "..." << endl;
				if ( (ferr = pImg1->SaveImage(imname1.c_str(), SBIF_FITS)) != SBFE_NO_ERROR )
					break;
        cout << "Saving image " << imname2 << "..." << endl;
        if ( (ferr = pImg2->SaveImage(imname2.c_str(), SBIF_FITS)) != SBFE_NO_ERROR )
					break;
        sstrm1.str("");
        sstrm2.str("");
				isdark = true;
			} else {
        sstrm1 << scanprefix << "_" << cname1 <<"_" << wlvector[n] << "_" << "nm_dark.fits";
        sstrm2 << scanprefix << "_" << cname2 <<"_" << wlvector[n] << "_" << "nm_dark.fits";
				imname1 = sstrm1.str();
        imname2 = sstrm2.str();
				cout << "Saving image " << imname1 << "..." << endl;
        if ( (ferr = pImg1->SaveImage(imname1.c_str(), SBIF_FITS)) != SBFE_NO_ERROR )
					break;
        cout << "Saving image " << imname2 << "..." << endl;
				if ( (ferr = pImg2->SaveImage(imname2.c_str(), SBIF_FITS)) != SBFE_NO_ERROR )
					break;
        sstrm1.str("");
        sstrm2.str("");
				++n;
				isdark = false;

			}
      delete pImg1;
      delete pImg2;


		//Put in a do loop to make sure no errors in removing
			do {
				cout << "Attempting to delete communication file..." << endl;
			} while(remove("communication.txt") != 0);
			cout << "Communication file deleted, CCD is ready for the next exposure." << endl;

			}

		} while(1);



		// shut down cameras
		cout << "Closing Devices..." << endl;
		if ( (err = pCam1->CloseDevice()) != CE_NO_ERROR )
			break;
    if ( (err = pCam2->CloseDevice()) != CE_NO_ERROR )
			break;
		cout << "Closing Drivers..." << endl;
		if ( (err = pCam1->CloseDriver()) != CE_NO_ERROR ){
			cout << "Error in closing driver" << endl;
			break;
		}
    if ( (err = pCam2->CloseDriver()) != CE_NO_ERROR ){
      cout << "Error in closing driver" << endl;
      break;
    }
	} while (0);
	if ( err != CE_NO_ERROR ) {
		cout << "Camera Error: " << pCam1->GetErrorString(err) << endl;
		cout << "The error code is " << err << endl;
	}
	else if ( ferr != SBFE_NO_ERROR )
		cout << "File Error: " << ferr << endl;
	else
		cout << "SUCCESS" << endl;
	delete pCam1;
  delete pCam2;
	delete pImg1;
  delete pImg2;
	return EXIT_SUCCESS;
}
