library(ggplot2)
library(cowplot)
tl100monit=read.csv("/storage/research/instrumentation/Tcal/data/181218_photodiode/test_loop_100_monit_val.dat", header = FALSE)
fast=read.csv("/storage/research/instrumentation/Tcal/data/181218_photodiode/test_loop_fast_l10_d10.dat", header = FALSE)
slow=read.csv("/storage/research/instrumentation/Tcal/data/181218_photodiode/test_loop_pause_1sec_l10_d10.dat", header = FALSE)

qplot(data=slow, V2-2e-9,V3)
qplot(data=fast, V2-2e-9,V3)+
  geom_point(data=slow, aes(V2-2e-9,V3), color="red")+
  scale_x_log10()+
  scale_y_log10()

qplot(data=tl100monit, V2-2e-9, V3)

mlb=read.csv("/storage/research/instrumentation/Tcal/data/EQ-99X Radiance 220-1700.csv")
qplot(mlb$Wavelength, mlb$Spectral.Radiance..mW.mm.2.nm.sr., geom="path")
mlb$val=mlb[,2]/max(mlb[,2])
mlb=mlb[mlb$Wavelength>400 & mlb$Wavelength<900,]
s5=read.csv("/storage/research/instrumentation/Tcal/data/190124/phot_scan0001_scan.dat")
s6=read.csv("/storage/research/instrumentation/Tcal/data/190124/phot_scan0002_scan.dat")
s7=read.csv("/storage/research/instrumentation/Tcal/data/190124/phot_scan0003_scan.dat")
s4=read.csv("/storage/research/instrumentation/Tcal/data/190124/phot_scan0004_scan.dat")
s1=read.csv("/storage/research/instrumentation/Tcal/data/190124/scan1/scan1_0001_scan.dat")
s2=read.csv("/storage/research/instrumentation/Tcal/data/190124/scan2/scan1_0001_scan.dat")
s3=read.csv("/storage/research/instrumentation/Tcal/data/190124/scan3/scan3_0001_scan.dat")
s1$scan="1"
s2$scan="2"
s3$scan="3"
s4$scan="4"
s5$scan="5"
s6$scan="6"
s7$scan="7"
scans=rbind(s1,s2,s3,s4,s5,s6,s7)

pscans=scans[scans$Type=="Light",]
pscans$val=pscans$Mean_Phot-scans$Mean_Phot[scans$Type=="Dark"]
pscans$err=sqrt(pscans$SD_phot^2/pscans$num_read_phot+scans$SD_phot[scans$Type=="Dark"]^2/scans$num_read_phot[scans$Type=="Dark"])
pscans$resid=as.numeric(apply(pscans[,c(9,11)], 1,function(row){return(row[2]-mean(pscans$val[pscans$Img_filename==row[1]]))}))
pscans[1,9]
mean(pscans$val[pscans$Img_filename==400])
library(plyr)
a=
as.numeric(a)
ggplot(pscans,aes(Img_filename, val, color=scan))+
  geom_path()+
  geom_path(data=mlb, aes(Wavelength,val*max(pscans$val)), color="black")+
  scale_x_continuous(name=bquote(lambda*"[nm]"))+
  scale_y_continuous(name=bquote("Mean Photodiode Signal[W]"))+
  geom_errorbar(aes(ymin=val-err,ymax=val+err))+
  scale_color_discrete(name="Scan Number")+
  panel_border(colour = "black", size=1)+
  annotate("text", x=600,y=2e-10, label="Black line is MLB lab measurement", size=5)+
  theme(
    plot.title=element_text(hjust=0.5,size=25, face="plain"),
    title=element_text(size=13, face="plain"),
    axis.line.x= element_line(color="black", size=0.5),
    axis.line.y= element_line(color="black", size=0.5),
    axis.ticks.length =unit(-0.25, "cm"),
    axis.text.x=element_text(margin=unit(c(0.5,0.5,0.5,0.5), "cm")),
    axis.text.y=element_text(margin=unit(c(0.5,0.5,0.5,0.5), "cm")),
    axis.title.y = element_text(size=25),
    axis.title.x = element_text(size=25),
    legend.text=element_text(size=13),
    legend.key=element_rect(fill="white"),
    legend.direction = "horizontal",
    #legend.title = element_blank(),
    legend.position = c(0.41,0.9),
    legend.key.size = unit(1.5,"lines")
  )
ggsave("/storage/research/instrumentation/Tcal/plots/190124_repeatability_photodiode.png", height=6)

ggplot(pscans, aes(Img_filename,resid/val, color=scan))+
  geom_point()+
  scale_x_continuous(name=bquote(lambda*"[nm]"))+
  scale_y_continuous(name="Photodiode residual\nfrom mean value [%]",breaks = c(-0.05,-0.03,-0.01,0,0.01,0.03,0.05), labels = c(-5,-3,-1,0,1,3,5))+
  geom_errorbar(aes(ymin=(resid-err)/val,ymax=(resid+err)/val))+
  scale_color_discrete(name="Scan Number")+
  panel_border(colour = "black", size=1)+
  coord_cartesian(ylim=c(-0.05,0.05),xlim=c(390,910))+
  theme(
    plot.title=element_text(hjust=0.5,size=25, face="plain"),
    title=element_text(size=13, face="plain"),
    axis.line.x= element_line(color="black", size=0.5),
    axis.line.y= element_line(color="black", size=0.5),
    axis.ticks.length =unit(-0.25, "cm"),
    axis.text.x=element_text(margin=unit(c(0.5,0.5,0.5,0.5), "cm")),
    axis.text.y=element_text(margin=unit(c(0.5,0.5,0.5,0.5), "cm")),
    axis.title.y = element_text(size=25),
    axis.title.x = element_text(size=25),
    legend.text=element_text(size=13),
    legend.key=element_rect(fill="white"),
    legend.direction = "horizontal",
    #legend.title = element_blank(),
    legend.position = c(0.41,0.9),
    legend.key.size = unit(1.5,"lines")
  )

ggsave("/storage/research/instrumentation/Tcal/plots/190124_repeatability_residual.png", height=6)
ccd.frame1=read.csv("/storage/research/instrumentation/Tcal/data/190124/scan1/ccd_summary_1.csv")
ccd.frame2=read.csv("/storage/research/instrumentation/Tcal/data/190124/scan2/ccd_summary_1.csv")
ccd.frame3=read.csv("/storage/research/instrumentation/Tcal/data/190124/scan3/ccd_summary_1.csv")

ccd.frame1$run="1"
ccd.frame2$run="2"
ccd.frame3$run="3"
ccd.frame1$median_img=-1*ccd.frame1$median_img
ccd.frame=rbind(ccd.frame1,ccd.frame2,ccd.frame3)
ccd.frame=read.csv("/storage/research/instrumentation/Tcal/data/190128/ccd_summary_1.csv")
ccd.frame$run="1"
ccd.frame$ratio=ccd.frame$median_img/ccd.frame$phot_mean/max(ccd.frame$median_img/ccd.frame$phot_mean)
ccd.frame$ratioerr=sqrt((ccd.frame$mad_img/ccd.frame$median_img)^2/(3000*2000)+(ccd.frame$phot_sd_l/ccd.frame$phot_mean)^2/ccd.frame$phot_nmeas_l+(ccd.frame$phot_sd_d/ccd.frame$phot_mean)^2/ccd.frame$phot_nmeas_d)


ggplot(ccd.frame, aes(lam, ratio, color=run))+
  geom_point(size=0.5)+
  geom_errorbar(aes(ymin=ratio-ratioerr, ymax=ratio+ratioerr))+
  scale_x_continuous(name="Wavelength [nm]",breaks = seq(300,925,50), expand=c(0,0))+
  scale_y_continuous(name="Ratio", expand=c(0,0), seq(0,1.1, 0.2))+
  coord_cartesian(ylim=c(-0.05,1.1),xlim=c(350,950))+
  panel_border(colour = "black", size=1)+
  scale_color_discrete(name="Scan Number")+
  theme(
    plot.title=element_text(hjust=0.5,size=25, face="plain"),
    title=element_text(size=13, face="plain"),
    axis.line.x= element_line(color="black", size=0.5),
    axis.line.y= element_line(color="black", size=0.5),
    axis.ticks.length =unit(-0.25, "cm"),
    axis.text.x=element_text(margin=unit(c(0.5,0.5,0.5,0.5), "cm")),
    axis.text.y=element_text(margin=unit(c(0.5,0.5,0.5,0.5), "cm")),
    axis.title.y = element_text(size=25),
    axis.title.x = element_text(size=25),
    legend.text=element_text(size=13),
    legend.key=element_rect(fill="white"),
    #legend.direction = "horizontal",
    #legend.title = element_blank(),
    legend.position = c(0.71,0.75),
    legend.key.size = unit(1.5,"lines")
  )
ggsave("/storage/research/instrumentation/Tcal/plots/190128_repeatability_ratio.png", height=6)


ggplot(ccd.frame, aes(lam, median_img, color=run))+
  geom_point()+
  geom_errorbar(aes(ymin=median_img-mad_img/sqrt(3000*2000), ymax=median_img+mad_img/sqrt(3000*2000)))+
  scale_x_continuous(name="Wavelength [nm]",breaks = seq(300,925,50), expand=c(0,0))+
  scale_y_continuous(name="Ratio residual\nfrom mean value [%]", expand=c(0,0), seq(0,5e3, 500))+
  coord_cartesian(ylim=c(0,5.2e3),xlim=c(350,950))+
  panel_border(colour = "black", size=1)+
  scale_color_discrete(name="Scan Number")+
  theme(
    plot.title=element_text(hjust=0.5,size=25, face="plain"),
    title=element_text(size=13, face="plain"),
    axis.line.x= element_line(color="black", size=0.5),
    axis.line.y= element_line(color="black", size=0.5),
    axis.ticks.length =unit(-0.25, "cm"),
    axis.text.x=element_text(margin=unit(c(0.5,0.5,0.5,0.5), "cm")),
    axis.text.y=element_text(margin=unit(c(0.5,0.5,0.5,0.5), "cm")),
    axis.title.y = element_text(size=25),
    axis.title.x = element_text(size=25),
    legend.text=element_text(size=13),
    legend.key=element_rect(fill="white"),
    #legend.direction = "horizontal",
    #legend.title = element_blank(),
    legend.position = c(0.71,0.75),
    legend.key.size = unit(1.5,"lines")
  )
ggsave("/storage/research/instrumentation/Tcal/plots/190124_repeatability_ccd.png", height=6)

ccd.frame$resid=as.numeric(apply(ccd.frame[,c("lam","ratio")], 1,function(row){return(row[2]-mean(ccd.frame$ratio[ccd.frame$lam==row[1]]))}))

ggplot(ccd.frame, aes(lam, resid/ratio, color=run))+
  geom_point()+
  geom_errorbar(aes(ymin=(resid-ratioerr)/ratio, ymax=(resid+ratioerr)/ratio))+
  geom_hline(yintercept = 0, linetype="dashed")+
  scale_x_continuous(name="Wavelength [nm]",breaks = seq(300,925,50), expand=c(0,0))+
  scale_y_continuous(name="Ratio residual\nfrom mean value [%]", expand=c(0,0), c(seq(-0.01,0.01, 0.004),0),labels = c(seq(-1,1, 0.4),0))+
  coord_cartesian(ylim=c(-0.01,0.01),xlim=c(390,910))+
  panel_border(colour = "black", size=1)+
  scale_color_discrete(name="Scan Number")+
  theme(
    plot.title=element_text(hjust=0.5,size=25, face="plain"),
    title=element_text(size=13, face="plain"),
    axis.line.x= element_line(color="black", size=0.5),
    axis.line.y= element_line(color="black", size=0.5),
    axis.ticks.length =unit(-0.25, "cm"),
    axis.text.x=element_text(margin=unit(c(0.5,0.5,0.5,0.5), "cm")),
    axis.text.y=element_text(margin=unit(c(0.5,0.5,0.5,0.5), "cm")),
    axis.title.y = element_text(size=25),
    axis.title.x = element_text(size=25),
    legend.text=element_text(size=13),
    legend.key=element_rect(fill="white"),
    legend.direction = "horizontal",
    #legend.title = element_blank(),
    legend.position = c(0.31,0.85),
    legend.key.size = unit(1.5,"lines")
  )
ggsave("/storage/research/instrumentation/Tcal/plots/190124_repeatability_ratio_residual.png")

