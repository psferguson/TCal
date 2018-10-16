ccd.frame=read.csv("/storage/research/instrumentation/Tcal/data/181015/ccd_summary.csv")
photodiode.frame=read.csv("/storage/research/instrumentation/Tcal/data/181012/try_1_500_6100001_scan.dat")
bad=which(ccd.frame$lam > 380 & ccd.frame$phot_mean < 1e-10)
ccd.frame=ccd.frame[-bad,]

ccd.frame$ratio=ccd.frame$median_img/ccd.frame$phot_mean/max(ccd.frame$median_img/ccd.frame$phot_mean)
ccd.frame$ratioerr=sqrt((ccd.frame$mad_img/ccd.frame$median_img)^2)
ccd.frame$ratio[ccd.frame$lam < 375]=0
ccd.frame$ratio=ccd.frame$ratio/max(ccd.frame$ratio)
ccd.frame$ratioerr=ccd.frame$ratioerr/max(ccd.frame$ratio)
ggplot(ccd.frame, aes(lam,ratio, color="A"))+
  geom_point()+
  geom_ribbon(data=ccd.frame,aes(ymin=ratio-ratioerr, ymax=ratio+ratioerr), alpha=0.3, color=NA)+
  geom_line()+
  geom_line(aes(x=lam,y=phot_mean/max(phot_mean), color="C"))+
  geom_point(aes(x=lam,y=phot_mean/max(phot_mean), color="C"))+
  geom_line(aes(x=lam,y=median_img/max(median_img), color="B"))+
  geom_point(aes(x=lam,y=median_img/max(median_img), color="B"))+
  scale_y_continuous(name="Normalized Signal [%]", expand=c(0,0), breaks=seq(0,1,0.2), labels = seq(0,100,20))+
  scale_x_continuous(name="Wavelength [nm]",breaks = seq(300,625,25), expand=c(0,0), limits=c(300,625))+
  coord_cartesian(ylim=c(-0.1,1.35))+
  annotate("text", 550,0.1,label="10 second exposures\nErrors are CCD MAD ~30%", size=5)+
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
    legend.position = c(0.25,0.86),
    legend.key.size = unit(1.5,"lines")
  )
ggsave("/storage/research/instrumentation/Tcal/plots/181015_sbigccd_300-625.png", height = 6, width=7)
ggplot(photodiode.frame,aes(Lambda_Central,Mean_Phot))+
  geom_point()
length(photodiode.frame$Date)
length(ccd.frame$mad_img)
photodiode.frame[1,]
ccd.frame[1,]


