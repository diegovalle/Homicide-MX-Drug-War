#CIEISP 2007
#http://www.pfp.gob.mx/portalWebApp/ShowBinary?nodeId=/BEA%20Repository/368010//archivo

#CIESIP 2006
#http://www.ssp.gob.mx/portalWebApp/ShowBinary?nodeId=/BEA%20Repository/368009//archivo

#CIEISP 2005
#http://www.ssp.gob.mx/portalWebApp/ShowBinary?nodeId=/BEA%20Repository/368008//archivo

m07 <- c(44, 33, 61, 50, 41, 40, 51, 38, 42, 47, 38, 42)
m06 <- c(47, 36, 40, 46, 55, 44, 55, 88, 58, 65, 60, 67)
m05 <- c(33, 37, 40, 35, 38, 32, 39, 22, 34, 37, 39, 41)

source("library/utilities.r")
source("timelines/constants.r")
hom <- read.csv(bzfile("timelines/data/county-month-gue-oax.csv.bz2"))
hom <- cleanHom(hom)
hom$County <- factor(cleanNames(hom, "County"))
hom <- subset(hom, County == "Michoacán" &
                   Year.of.Murder >= 2005 &
                   Year.of.Murder <= 2007)

mich.hom <- data.frame(tot = c(m05,m06,m07, hom$Total.Murders),
           type = rep(c("SNSP", "INEGI"), each=12*3),
           month = rep(1:12),
           year = rep(2005:2007, each = 12))
mich.hom$Date <-  as.Date(paste(mich.hom$year, mich.hom$month, "15"),
                          "%Y%m%d")

Cairo(file = "CIEISP/output/michoacan.png", width=700, height=400)
print(ggplot(mich.hom, aes(as.Date(Date), tot, group = type,
                     color = type)) +
    geom_line(size = 1.2) +
    scale_x_date() +
    xlab("") + ylab("Monthly number of homicides") +
    opts(title="Differences in homicides in Michoacan") +
    geom_vline(aes(xintercept = op.mich), alpha = .7) +
    annotate("text", x = op.mich, y = 20,  hjust = 1.01, vjust = 0,
             label="Joint Operation Michoacan", ))
dev.off()
