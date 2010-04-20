########################################################
#####       Author: Diego Valle Jones
#####       Website: www.diegovalle.net
#####       Date Created: Mon Apr 19 19:30:07 2010
########################################################
#This program does this and that


cieisp <- data.frame()
for(i in 2:8) {
  file <- paste("CIEISP/data/BD0", i, ".txt.bz2", sep = "")
  bd <- read.table(file, sep = "\t", header = TRUE)
  if(i == 8)
    names(bd) <- names(cieisp)
  cieisp <- rbind(cieisp, bd)
}



tot <- subset(cieisp, Mes == "Total" &
                      Mes != "Totgeneral" &
                      Entidad != "Totalestados")
cieisp <- subset(cieisp, Mes != "Total" &
                         Mes != "Totgeneral" &
                         Entidad != "Totalestados")
hom <- cieisp[,c("Anio", "Mes","Entidad", "HDAF", "THD")]
hom$Mes <- factor(hom$Mes)
hom$MesN <- hom$Mes
levels(hom$Mes)
levels(hom$MesN) <-
       c("04","08","12","01","02","07","06","03","05","11","10","09")
hom$date <- as.Date(paste(hom$Anio, hom$MesN, "01",sep = "-"))

print(ggplot(hom, aes(as.Date(date), THD, group = Entidad)) +
    geom_line() +
    scale_x_date() +
    facet_wrap(~ Entidad, scale = "free_y") +
    opts(axis.text.x=theme_text(angle=60, hjust=1.2 )) +
    opts(title = "Monthly Number of Homicides (based on SNSP data)"))
dev.print(png, "CIEISP/output/Homicides02-08.png", width = 960,
          height = 600)
