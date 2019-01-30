---------------------------------------------------------------
README FOR MONOCHROMATOR AUTOMATION SOFTWARE
            AND SBIG CCDS
---------------------------------------------------------------
Updated: 07/15/2013
Author: Nicholas Mondrik
MOCOAUTOMATION version: 1.0


=========================
1. SETUP AND INSTALLATION
=========================
    -To install the labview portion of the program, copy and pase the 
     "mocoglobalshutter_v2_Folder" into a directory on the computer you
     wish to use.  The computer must have at least LabVIEW 2009 or later
     to run the software.
     
     Next, open the "MOCOAUTOMATION_1.0.vi" file with labview.  Find the Event
     Structure, and change it to the '[10] "Automation": Value Change' event.  You will
     see a great many strings being manipulated.  You will need to change 6 directory strings:
     The green-outlined path variable that creates the .bat file that launches CCDautomation.exe,
     The pink-outlined string that writes into the .bat file, and the second green-outlined path 
     variable that sets the working directory to the directory where the .bat file and .exe file
     will be.

     The next 3 strings you need to change are located in the case structure in the middle of the
     code.  They should contain "[your_path_here]\communication.txt".  This controls where the 
     "communication.txt" file is created.  This file must be in the same directory as the
     "CCDautomation.exe" file in order for the system to work.

	=============================================================================
	It is recommended that you set these paths to the same folder that the 
	"MOCOAUTOMATION_1.0.vi" is in.  This program does not manipulate directories 
	with the exception of the photodiode file locations, so it may not work if 
	you choose to change the install locations.
	=============================================================================
	
    -To install the CCD automation portion of the program, copy and paste the "CCDautomation.exe"
     and the "cfitsio.dll" files into the same directory as "MOCOAUTOMATION_1.0.vi".  If you need
     the C++ redistributable (Windows should complain if you try to run the .exe without it), there
     is a file named "vcredist_x86.exe" in the Drivers and Libraries folder that will install them.
     A copy of "cfitsio.dll" is also in this folder.


====================
2. AUTOMATING A SCAN
====================
	**These instructions assume you are familiar with how the monochromator functions**
        **Before starting any scans, navigate to your folder with "MOCOAUTOMATION_1.0.vi" and **
        **"CCDautomation.exe", and delete any files named "shutdown.txt" or "communication.txt"**

    -To automate a scan, start up and initialize the monochromator via the "MOCOAUTOMATION_1.0.vi".
     Start the photodiode software via "1608fsdr_v2.vi" and adjust the settings appropriately.  Both
     programs should now be running.  Press the "Automation" button on the "MOCOAUTOMATION_1.0.vi" and 
     enter the desired scan parameters.  Be aware that if you would like to use the photodiode data reduction script,
     only integer wavelengths between 300nm and 900nm can be used.  To enable temperature regulation, flip
     the switch into the up position.  No matter what value you enter in the temperature field, if the switch
     is not up, the CCD will not cool down.  The "Wait for Temp:" button will tell LabVIEW to wait for 5 minutes
     before it begins the scan in order for the CCD to cool down.  If you enable temperature control but leave
     this button off, the program will begin cooling down the CCD and taking exposures simultaneously.

    -After pressing the okay button, you should see a command prompt open.  The prompt should begin displaying
     messages about its current status.  In addition, you should see photodiode files begin to populate the directory
     you chose. 

     -A bit more about the imaging process-
      The software begins by moving to the starting wavelength, turning on the photodiode, and taking an exposure.
      After a length of time (determined by the input exposure time) the photodiode stops saving data.  The camera
      continues to operate, as it must readout the exposure to a file. This data is stored in a file with name 
      "xxxnm.fits"  where xxx is the wavelength.  Next, LabVIEW closes the shutter of the monochromator, and repeats
      the same process of saving photodiode data and taking an exposure.  This time, however, the photodiode files will
      have "shutter0" rather than "shutter1" indicating that the shutter is closed.  The fits files will be marked as 
      "xxxnmdark.fits" to indicate that it is a dark frame.  After the darks are finished, the software iterates to the
      next wavelength and continues operation.

    -To shut down the camera and software properly, USE THE STOP BUTTON IN THE LOWER RIGHT CORNER OF THE
     "MOCOAUTOMATION_1.0.vi"PANEL.  This closes the camera and drivers properly.  After shutting down the software,
     it is best to unplug the CCD and monochromator controller to keep wear on them as low as possible.  After shutting
     down the camera, navigate to the directory with "CCDautomation.exe" and delete the "shutdown.txt" and
     "communication.txt" if they exist.  


========================
3. BASIC TROUBLESHOOTING
========================
    -For errors with the CCD automation software:
	-Is the CCD plugged in and powered on?
	-Is the C++ redistributable installed correctly?
	-Have all of the paths been changed appropriately?
	-Is the "shutdown.txt" file deleted from the directory where the executable is located?
	-Is the "communication.txt" file deleted from the directory where the executable is located?
	-Is the "cfitsio.dll" in the same directory as the .exe file?
	-Check where the "communication.txt" file is being created.  Is it in the same directory as
		"CCDautomation.exe"?

    -For errors with the "MOCOAUTOMATION_1.0.vi":
	-Is the monochromator controller plugged in and powered on?
	-If you are using the Serial -> USB connector, make sure you have the appropriate driver installed.
		for the Dynex one, there is a driver in the drivers and libraries folder named 
		"PL2303_Prolific_DriverInstaller_v1210.exe".  If you are using a different converter, make
		sure you have properly installed the appropriate driver.
	-If the software still does not recognize the controller, make sure the appropriate COM port (COM1) is
		being used.  If you use a converter, the OS often will not assign the COM port as COM1, even if
		there are no other COM ports on the machine.  To change this, go to 
		
		Control Panel >> Device Manager >> Ports >> [Your Converter here] >> Right Click >> Properties >>
		>> Port Settings >> Advanced >> Change Port Number to 1
	-If you have just installed the software on a new computer, you may need a .ini file to tell the controller
		how it should configure itself.  There is a copy of a good one in the "Drivers_and_Libraries" directory.
		This is the file that is saved whenever you click the save settings button.
	
    -For errors with the photodiode software:
	-Did you correctly run instacal?
	-Did you set the proper values on the front panel?
	-Did you enter the correct file path to an *existing directory* in the save location box?

    -If all else fails, restart the computer and try again.