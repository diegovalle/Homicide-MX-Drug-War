########################################################
#####       Author: Diego Valle Jones
#####       Website: www.diegovalle.net
#####       Date Created: Mon Apr 19 19:30:07 2010
########################################################
#Analysis of the original homicide data from SNSP formato CIEISP


cieisp <- data.frame()
for(i in 2:8) {
  file <- paste("CIEISP/data/BD0", i, ".TXT.bz2", sep = "")
  bd <- read.table(file, sep = "\t", header = TRUE)
  bd$Entidad <- iconv(bd$Entidad, "windows-1252", "utf-8")
  if(i == 8)
    names(bd) <- names(cieisp)
  cieisp <- rbind(cieisp, bd)
}
write.csv(cieisp, "CIEISP/output/cieisp.csv")


tot <- subset(cieisp, Mes == "Total" &
                      Mes != "Totgeneral" &
                      Entidad != "Totalestados")
cieisp <- subset(cieisp, Mes != "Total" &
                         Mes != "Totgeneral" &
                         Entidad != "Totalestados")
hom <- cieisp[,c("Anio", "Mes","Entidad", "HDAF", "THD")]
hom$Mes <- factor(hom$Mes)
hom$MesN <- hom$Mes
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


print(ggplot(hom, aes(as.Date(date), HDAF / THD, group = Entidad)) +
    geom_line() +
    scale_x_date() +
    scale_y_continuous(formatter = "percent") +
    facet_wrap(~ Entidad, scale = "free_y") +
    opts(axis.text.x=theme_text(angle=60, hjust=1.2 )) +
    opts(title = "Firearm Homicides as a percentage of total homicides(based on SNSP data)"))
dev.print(png, "CIEISP/output/HomicidesGuns02-08.png", width = 960,
          height = 600)

month <- ddply(hom, .(Anio, MesN), function(df) sum(df$THD))
month$date <- as.Date(paste(month$Anio, month$MesN, "01",sep = "-"))
ggplot(month, aes(date, V1)) +
    geom_line() +
    scale_x_date()


########################################################
#Compare the CIEISP data to the INEGI data
########################################################

source("library/utilities.r")
hom2 <- read.csv(bzfile("timelines/data/county-month-gue-oax.csv.bz2"))
hom2 <- cleanHom(hom2)
hom2$County <- factor(cleanNames(hom2, "County"))


cie.ine <- merge(subset(hom2, Year.of.Murder >=2006 &
                              Year.of.Murder <= 2008),
                 hom,
                 by.x = c("County","Year.of.Murder","Month.of.Murder"),
                 by.y = c("Entidad", "Anio", "MesN")
                 )

cie.ine <- ddply(cie.ine, .(County), transform,
                 cor = cor(Total.Murders, THD))
cie.ine$County <- reorder(factor(cie.ine$County), -cie.ine$cor)

ggplot(cie.ine, aes(as.Date(date), Total.Murders - THD)) +
    geom_line(color = "blue") +
#    geom_line(aes(as.Date(date), Total.Murders), color = "red") +
    scale_x_date() +
    facet_wrap(~ County, scale = "free_y") +
    xlab("Year") + ylab("Difference in number of homicides") +
    opts(title = "Differences in recorded number of homicides INEGI - SNSP") +
    opts(axis.text.x=theme_text(angle=60, hjust=1.2 )) +
    geom_hline(yintercept = 0, color = "gray40")


mad <- function(Total.Murders, THD){
    var(Total.Murders - THD)
}

cie.ine <- ddply(cie.ine, .(County), transform,
                 cor = mad(Total.Murders, THD))
cie.ine$County <- reorder(factor(cie.ine$County), -cie.ine$cor)
print(ggplot(cie.ine, aes(as.Date(date), THD)) +
    geom_line(color = "blue") +
    geom_line(aes(as.Date(date), Total.Murders), color = "red") +
    scale_x_date() +
    facet_wrap(~ County, scale = "free_y") +
    xlab("Year") + ylab("Number of homicides") +
    opts(title = "INEGI (red) vs. SNSP (blue) Monthly Number of Homicides (Jan 2006 - Nov 2008)") +
    opts(axis.text.x=theme_text(angle=60, hjust=1.2 )))
dev.print(png, "CIEISP/output/TwoHomicides02-08.png", width = 960,
          height = 600)

hom2 <- addMonths(hom2)
pop <- monthlyPop()
homrate <- addHom(hom2, pop)
homrate <- addTrend(homrate)
homrate <- subset(homrate, year >= 2002 & year < 2008)
month <- subset(month, Anio < 2008)
month <- month[order(month$date),]
month$date <- monthSeq("2002-01-15", 12*6)
cor(homrate$murders, month$V1)

ggplot(month, aes(as.Date(date), V1)) +
    geom_line(color = "blue") +
    geom_line(data = homrate, aes(as.Date(date), murders),
              color ="red") +
    xlab("Year") + ylab("Number of Homicides") +
    opts(title = "INEGI (red) vs. SNSP (blue) monthly number of homicides") +
    scale_x_date()
