---------------------------------------------------------------
README FOR PYTHON DATA REDUCTION SCRIPT
---------------------------------------------------------------
Updated: 07/15/2013
Author: Nicholas Mondrik

You will need the Pandas and Numpy external modules installed to run this script.

To use this script you need the master filter file from the photodiode
LabVIEW software.  You also need the PD_CAL.txt file in the same directory
as the filter file.  You should also have the letter of the photodiode you
are using, but it is not necessary.

The purpose of this script is two-fold:
	1. Scan the averages to determine if saturation has 
		occurred.
	2. Do preliminary reduction of photodiode data.

This software displays on the command prompt the names of the files
which are suspected to have saturated.  You should confirm this manually.
It also outputs a file with the Wavelength, Average PD value, average PD dark value,
Adjusted PD value (light - dark), and photons/sec.  The following is the formula used:

Photons/sec = ADJ_PD_VAL / PD_CALIBRATION_VAL / JOULES_PER_PHOTON

Where the joules per photon is found from E = hc/lambda