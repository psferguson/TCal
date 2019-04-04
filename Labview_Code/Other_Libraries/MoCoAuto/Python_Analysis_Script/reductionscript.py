#Script to examine Photodiode ouput, watch for saturation of photodiode,
#and do preliminary data reduction of PD data.

import os
import pandas
import numpy as np

pdcol = 0
stopflag = False
max_val = 2.5 #Maximum voltage before PD is declared saturated

print "Enter the full path to the Photodiode data files."
path_to_data = raw_input()

os.chdir(path_to_data)

print "Enter the name of the consolidated filter file (the one with pre-calculated averages)."
filtername = raw_input()

while (pdcol == 0):
	print "Enter the letter of the Photodiode: (options are B,C,D, and E)  If you don't know, its not a big deal, as the values are fairly close."
	pdname = raw_input()
	if (pdname == 'C' or pdname == 'c'):
		pdcol = 1
	elif (pdname == 'B' or pdname == 'b'):
		pdcol = 2
	elif (pdname == 'D' or pdname == 'd'):
		pdcol = 3
	elif (pdname == 'E' or pdname == 'e'):
		pdcol = 4
	else:
		print "Invalid Entry.  Try Again: (Options are (B,C,D,E)"
		
print "Working..."
data = pandas.read_table(filtername, header=None, skiprows=22, sep=r"\s*")
pdcaldata = pandas.read_table('PD_CAL.txt', header=1, sep=r"\s*")
pdcaldata = np.array(pdcaldata)
hc = 1.986446*10**-16 #in J.nm

#[:,2] is the WL column and [:,3] is the average column.
data = np.array(data)
#procdat = processed data, has form
#WL   |   AVG PD VAL  |  AVG PD DARK  |  ADJ PD VAL  |  PHOTONS
procdat = np.empty([0,5])
for currWL in range (300,901):
	wlpresent = False
	wlcounter = 0
	wlcounterdark = 0
	lightsum = 0
	darksum = 0
	adjavg = 0
	for i in range (0, len(data[:,2])):
		if (data[i,2] == currWL):
			wlpresent = True
			if (data[i,0] == 1):
				lightsum = lightsum + data[i,3]
				wlcounter = wlcounter + 1
			else:
				darksum = darksum + data[i,3]
				wlcounterdark = wlcounterdark + 1
	if (wlpresent == True):
		lightsum = lightsum / wlcounter
		darksum = darksum / wlcounterdark
		if (lightsum >= max_val):
			print "Wavelength " + str(currWL) + "nm may be saturated."
		adjavg = lightsum - darksum
		if ((currWL < 300) or (currWL > 900)):
			print "You cannot use this script for wavelengths outside of 300-900nm.  This is because the photodiodes have not been calibrated outside of this range."
			stopflag = True
			break
		pdindex = currWL - 300
		photons = adjavg / pdcaldata[pdindex,1] / (hc/currWL)
		newrow = [currWL,lightsum,darksum,adjavg,photons]
		procdat = np.vstack([procdat,newrow])

		
if (stopflag==False):
	head = 'WL[nm]    AvgPDVal    AvgPDDark  AdjPDAvg    Photons/sec'
	np.savetxt('PD_PROC_DATA.txt',procdat,delimiter="    ",fmt='%2.4f', header=head)
	print "File has been output as PD_PROC_DATA.txt in the same directory as the photodiode files."
else:
	print "The program will now exit."
	




