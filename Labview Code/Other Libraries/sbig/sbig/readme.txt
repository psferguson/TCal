SBIG Universal Driver for LabVIEW
---------------------------------

The purpose of these files is to simplify comunication between SBIG Cameras and labVIEW. To use it, unzip the files (and folders) to instr.lib folder in the labVIEW folder (usually C:\Program Files\National Instruments\LabVIEW X\). This driver is free and should be distributed without change. I will not take responsability of any problem you, your computer or your camera (or anything) might have using it.

Each vi has a small documentation, most of it copied from Universal Driver manual. I suggest you download it from SBIG and read to fully understand how does it work. Three small examples are included: TesLink.vi, TakeImage.vi, TestControl.vi.

The only tricky part is to set CCD Parameters correctly. Failure to do this will crash the program. To do it right you must first know available operating modes of your CCD. You can get this info in your camera manual or by using CCD GetCCDInfoImaging.vi command. Then set compatible values in ReadoutMode, Height, Width, Top and Left. Read SBIG Universal Driver for further explanation. For example, if your camera is 1024x768, don't set Width to more than 1024. Take special care when binning because you must proviede info in terms of binned pixels. I will include  some error area manager in the next version.

I have tested it with ST8, Win98 and LabVIEW 6i but it should work with LabVIEW 5 and 7 as well and any SBIG Camera compatible with SBIG Universal Driver. I guess that Win2k must correct parallel port access problem with LabVIEW.

Enjoy!

Hernán E. Grecco
hgrecco@df.uba.ar
http://www.lec.df.uba.ar/


Major improvements

1.3 Ethernet and MultiUSB implemented.
1.2 Correction to memory handling problems.
1.1 More functions added.
1.0 Initial release.