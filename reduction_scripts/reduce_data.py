import numpy as np
import sys
import os
from astropy.io import fits
import pandas as pd
from statsmodels import robust
<<<<<<< HEAD:reduce_data.py
path="C:\\Users\\astrolab\\Desktop\\Peter_Ferguson\\TCal\\scans\\190125\\"
path
files=os.listdir(path)
images_list=[i for i in files if "nm.fits" in i ]
images_list=[i for i in files if "5nm.fits" in i]
scan_list=[i for i in files if "scan.dat" in i ]
lamlist=[float(i[0:3]) for i in images_list ]
images_list=[x for _,x in sorted(zip(lamlist,images_list))]
=======
>>>>>>> fa670579dda14bf75e9a0fad2ed325cb389928db:reduction_scripts/reduce_data.py
def im_sum_stat(image_name):
    light=path+image_name
    dark=path+image_name[0:len(image_name)-5]+"dark.fits"
    lightimg=fits.open(light)
    darkimg=fits.open(dark)
    lightdat=lightimg[0].data
    darkdat=darkimg[0].data
    subtracted=lightdat.astype(float)-darkdat.astype(float)
    median=np.median(subtracted)
    mad=np.median(np.abs(subtracted-median))
    lightimg.close()
    darkimg.close()
    return image_name,median,mad
def phot_sum_stat(scan_name):
    pdiode_frame=pd.read_csv(path+scan_name)
    range(int(len(pdiode_frame['Date'])/2))
    val=[]
    errl=[]
    errd=[]
    nmeasl=[]
    nmeasd=[]
    for i in range(int(len(pdiode_frame['Date'])/2)):
        light=pdiode_frame['Mean_Phot'][2*i]
        dark=pdiode_frame['Mean_Phot'][2*i+1]
        val.append(light-dark)
        errl.append(pdiode_frame['SD_phot'][2*i])
        errd.append(pdiode_frame['SD_phot'][2*i+1])
        nmeasl.append(pdiode_frame['num_read_phot'][2*i])
        nmeasd.append(pdiode_frame['num_read_phot'][2*i+1])
    return val, errl,errd,nmeasl,nmeasd


path="/storage/research/instrumentation/Tcal/data/181217/repeatability_test/Scan5/"
files=os.listdir(path)
images_list=[i for i in files if "0nm.fits" in i ]
#images_list=[i for i in files if "5nm.fits" in i]
scan_list=[i for i in files if "scan.dat" in i ]
lamlist=[float(i[0:3]) for i in images_list ]
images_list=[x for _,x in sorted(zip(lamlist,images_list))]
images_summary=[im_sum_stat(i) for i in images_list]
imstats=pd.DataFrame({'name':[i[0] for i in images_summary],'median_img':[i[1] for i in images_summary],'mad_img':[i[2] for i in images_summary]})
imstats['lam']=[float(i[0:3]) for i in imstats['name']]
imstats['phot_mean'],imstats['phot_sd_l'],imstats['phot_sd_d'],imstats['phot_nmeas_l'],imstats['phot_nmeas_d']=phot_sum_stat(scan_list[0])
imstats.to_csv(path+"ccd_summary_1.csv", index=False)
import matplotlib.pyplot as plt
plt.plot(imstats['lam'],imstats['median_img'])
alt.Chart(imstats).mark_line().encode(
    x='lam',
    y='mean_img',
    )
x = np.arange(100)
data = pd.DataFrame({'x': x,
                     'sin(x)': np.sin(x / 5)})

alt.Chart(data).mark_line().encode(
    x='x',
    y='sin(x)'
)

list=["nm.fits" in i for i in files]

[m for l in files for ]
a="nm.fits" in files[0]
a==True

"nm.fits" in files

fits.open()
