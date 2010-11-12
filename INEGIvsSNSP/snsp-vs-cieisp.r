########################################################
#####       Author: Diego Valle Jones
#####       Website: www.diegovalle.net
#####       Date Created: Fri May 21 18:07:05 2010
########################################################
#Compare the data the SNSP gave to the ICESI with that of contained
#in the original CIEISP forms
source("library/utilities.r")

cieisp <- read.csv("CIEISP/output/cieisp.csv")
snsp <- read.csv("INEGIvsSNSP/data/states-icesi.csv")

cieisp <- subset(cieisp, Mes == "Total")
cieisp <- cieisp[ ,c(2:4,12)]

snsp$State <- cleanNames(snsp, "State")
snsp <- melt(snsp, id = "State")
snsp$Anio <- as.numeric(gsub("X", "", snsp$variable))

cie.snsp <- merge(snsp, cieisp, by.y=c("Entidad","Anio"),
                  by.x=c("State", "Anio"))
cie.snsp$variable <- NULL;cie.snsp$Mes <- NULL
names(cie.snsp) <- c("State", "Anio", "SNSP", "CIEISP")

mcie <- melt(cie.snsp, id = c("State","Anio"))
mcie <- ddply(mcie, .(State), transform,
                     dif = abs(mean(value[1:7] - value[8:14])))
mcie$State <- reorder(factor(mcie$State), -mcie$dif)

print(ggplot(mcie, aes(Anio, value, group = variable,
                       color = variable)) +
    geom_line() +
    opts(title = "Differences in reported homicides according to the SNSP data and the original CIEISP forms") +
    opts(axis.text.x=theme_text(angle=60, hjust=1.2 )) +
    ylab("Number of Homicides") +
    facet_wrap(~State, scale = "free_y"))
dev.print(png, file = "INEGIvsSNSP/output/SNSP-vs-CIEISP.png", width = 960, height = 600)


mx <- subset(mcie, State == "México")
inegi <- c(1957,1909,1739,2017,1743,1235,1559)
mx <- rbind(mx, data.frame(State = "México",
                          Anio = 2002:2008,
                          variable = "INEGI",
                          value = inegi,
                          dif = 0))

print(ggplot(mx, aes(Anio, value, group = variable,
                     color = variable)) +
    geom_line(size = 2, alpha = .4) +
    opts(title = "Differences in reported homicides according to\nSNSP data, the original CIEISP forms, and the INEGI\nin the State of Mexico") +
    opts(axis.text.x=theme_text(angle=60, hjust=1.2 )) +
    ylab("Number of Homicides") +
    xlab(""))
dev.print(png, file = "INEGIvsSNSP/output/mxSNSP-vs-CIEISP-vs-INEGI.png", width = 640, height = 480)


