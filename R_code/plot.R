library(ggplot2)
library(cowplot)
ccd.frame1=read.csv("/storage/research/instrumentation/Tcal/data/181217/repeatability_test/Scan1/ccd_summary_1.csv")
ccd.frame2=read.csv("/storage/research/instrumentation/Tcal/data/181217/repeatability_test/Scan2/ccd_summary_1.csv")
ccd.frame3=read.csv("/storage/research/instrumentation/Tcal/data/181217/repeatability_test/Scan3/ccd_summary_1.csv")
ccd.frame4=read.csv("/storage/research/instrumentation/Tcal/data/181217/repeatability_test/Scan4/ccd_summary_1.csv")
ccd.frame5=read.csv("/storage/research/instrumentation/Tcal/data/181217/repeatability_test/Scan5/ccd_summary_1.csv")
ccd.frame1$run="1"
ccd.frame2$run="2"
ccd.frame3$run="3"
ccd.frame4$run="4"
ccd.frame5$run="5"

ccd.frame=rbind(ccd.frame1,ccd.frame2,ccd.frame3,ccd.frame4,ccd.frame5)
ccd.frame
bad=which( (ccd.frame$phot_nmeas_l > 400) | (ccd.frame$phot_nmeas_d > 400)) 
ccd.frame=ccd.frame[-bad,]
ggplot(ccd.frame[,], aes(lam,phot_mean, color=run))+
  geom_point()+
  geom_errorbar(aes(ymin=phot_mean-phot_sd_l,ymax=phot_mean+phot_sd_l))

ccd.frame$ratio=ccd.frame$median_img/ccd.frame$phot_mean/max(ccd.frame$median_img/ccd.frame$phot_mean)
ccd.frame$ratioerr=sqrt((ccd.frame$mad_img/ccd.frame$median_img)^2/(3000*2000)+(ccd.frame$phot_sd_l/ccd.frame$phot_mean)^2/ccd.frame$phot_nmeas_l+(ccd.frame$phot_sd_d/ccd.frame$phot_mean)^2/ccd.frame$phot_nmeas_d)

ccd.frame$ratio[ccd.frame$lam < 375]=0
#ccd.frame$ratio=ccd.frame$ratio/max(ccd.frame$ratio)
#ccd.frame$ratioerr=ccd.frame$ratioerr/max(ccd.frame$ratio)
ccd.frame$qual="good"
ccd.frame$qual[ccd.frame$phot_sd/ccd.frame$phot_mean > 0.04]="bad"
ccd.frame[1,]
ggplot(data=ccd.frame[ccd.frame$ratioerr <0.01,], aes(lam,phot_nmeas_l, color=run))+
  geom_point(data=ccd.frame[ccd.frame$ratioerr >0.01,], aes(lam,phot_nmeas_l), color="black")+
  geom_point()
  
ggplot(ccd.frame, aes(phot_sd/phot_mean, color=qual, fill=qual))+
  geom_histogram(bins=30)+scale_x_continuous(limits = c(-0,0.1))


ggplot(ccd.frame, aes(lam, median_img, color=run))+
  geom_errorbar(aes(ymin=median_img-mad_img/(3000*2000), ymax=median_img+mad_img/(3000*2000)))+
  geom_point()+
  annotate("text", y=6e3,x=775,label="CCD 10s exposures\n(dark and light)\nstepsize=20nm\nrepeated 5 times", size=6)+
  scale_x_continuous(name="Wavelength [nm]",breaks = seq(300,925,50), expand=c(0,0), limits=c(300,905))+
  scale_y_continuous(name="Median CCD Signal Value[ADU]", expand=c(0,0), seq(0,10000, 2e3), limits = c(0,1e4))+
  panel_border(colour = "black", size=1)+
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
    legend.title = element_blank(),
    legend.position = c(0.61,0.95),
    legend.key.size = unit(1.5,"lines")
  )
ggsave("/storage/research/instrumentation/Tcal/plots/181219_ccdvlam.png", height = 6, width=7.5)

ccd.frame$phot_sd=sqrt(ccd.frame$phot_sd_l^2/ccd.frame$phot_nmeas_l+ccd.frame$phot_sd_d^2/ccd.frame$phot_nmeas_d)

ggplot(ccd.frame[abs(ccd.frame$phot_sd/ccd.frame$phot_mean) < 0.04,], aes(lam, phot_mean, color=run))+
  geom_errorbar(aes(ymin=phot_mean-phot_sd, ymax=phot_mean+phot_sd))+
  geom_point()+
  geom_path()+
  annotate("text", y=7e-10,x=775,label="photodiode 10s average\n(dark and light)\nstepsize=20nm\nrepeated 5 times", size=6)+
  annotate("text", y=2e-10,x=550,label="only plotting where:\nphotodiode error/signal < 4% ", size=6)+
  scale_x_continuous(name="Wavelength [nm]",breaks = seq(300,925,50), expand=c(0,0))+
  scale_y_continuous(name="Mean photodiode Signal[W]", expand=c(0,0), seq(0,1e-9, 2e-10))+
  coord_cartesian(ylim=c(-1e-10,1e-9),xlim=c(350,950))+
  panel_border(colour = "black", size=1)+
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
    legend.title = element_blank(),
    legend.position = c(0.61,0.95),
    legend.key.size = unit(1.5,"lines")
  )
ggsave("/storage/research/instrumentation/Tcal/plots/181219_photvlam_4pct.png", height = 6, width=7.5)
scale=max(ccd.frame$ratio[abs(ccd.frame$phot_sd/ccd.frame$phot_mean) < 0.04])

ggplot(ccd.frame[,], aes(lam,ratio/scale, color=run))+
  geom_errorbar(aes(ymin=(ratio-ratioerr)/scale, ymax=(ratio+ratioerr)/scale))+
  geom_point()+
  geom_path()+
  #annotate("text", y=1,x=775,label="Ratio of ccd and photodiode\n(dark and light)\nstepsize=20nm\nrepeated 5 times", size=6)+
  #annotate("text", y=0.2,x=550,label="only plotting where:\nphotodiode error/signal < 4% ", size=6)+
  scale_x_continuous(name="Wavelength [nm]",breaks = seq(300,925,50), expand=c(0,0))+
  scale_y_continuous(name="Ratio", expand=c(0,0), seq(0,1.5, 0.2))+
  coord_cartesian(ylim=c(0,1.35),xlim=c(350,950))+
  panel_border(colour = "black", size=1)+
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
    legend.title = element_blank(),
    legend.position = c(0.61,0.95),
    legend.key.size = unit(1.5,"lines")
  )

ggsave("/storage/research/instrumentation/Tcal/plots/181219_ratiovlam_all.png", height = 6, width=7.5)

  
ggplot(ccd.frame, aes(lam,ratio, color="A", group=run))+
  geom_errorbar(aes(ymax=ratio+3*ratioerr, ymin=ratio-3*ratioerr))+
  geom_line(aes(x=lam,y=phot_mean/max(phot_mean), color="C", group=run))+
  geom_point(aes(x=lam,y=phot_mean/max(phot_mean), color="C", group=run))+
  geom_line(aes(x=lam,y=median_img/max(median_img), color="B", group=run))+
  geom_point(aes(x=lam,y=median_img/max(median_img), color="B", group=run))+
  geom_point()+
  geom_line()+
  scale_y_continuous(name="Normalized Signal [%]", expand=c(0,0), breaks=seq(0,1,0.2), labels = seq(0,100,20))+
  scale_x_continuous(name="Wavelength [nm]",breaks = seq(300,925,50), expand=c(0,0), limits=c(300,905))+
  coord_cartesian(ylim=c(-0.1,1.35))+
  geom_hline(yintercept = 1.04)+
  annotate("text", 700,1.2,label="10 second exposures\nErrors are SD of the mean for\nboth ccd and photodiode", size=5)+
  panel_border(colour = "black", size=1)+
  scale_color_manual(labels=c("Relative Transmission \nof System","CCD Signal","Photodiode signal"),values=c( "red", "black","darkblue"))+
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
    legend.title = element_blank(),
    legend.position = c(0.01,0.89),
    legend.key.size = unit(1.5,"lines")
  )

ggplot(ccd.frame, aes(phot_nmeas_d+phot_nmeas_l, fill=qual))+
  geom_histogram(aes(y=..density..), binwidth = 6)
  stat_bin(geom="step", binwidth = 5)


ggplot(ccd.frame[ccd.frame$ratioerr<0.5,], aes(lam,ratio/max(ratio), color=run))+
  geom_point()+
  geom_path()+
  geom_errorbar(aes(ymax=(ratio+ratioerr)/max(ratio),ymin=(ratio-ratioerr)/max(ratio)))
ggplot(ccd.frame3, aes(lam,phot_mean))+
  geom_point()
ggsave("/storage/research/instrumentation/Tcal/plots/181022_sbigccd_375-905.png", height = 6, width=7)
ggplot(photodiode.frame,aes(Lambda_Central,Mean_Phot))+
  geom_point()
length(photodiode.frame$Date)
length(ccd.frame$mad_img)
photodiode.frame[1,]
ccd.frame[1,]


