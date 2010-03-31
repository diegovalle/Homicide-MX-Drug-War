########################################################
#####       Author: Diego Valle Jones
#####       Website: www.diegovalle.net
#####       Date Created: Sat Jan 23 21:13:48 2010
########################################################
#The homicide rate according to the INEGI
#plus some charts comparing it to that in the US,
#and England and Wales



#From 1950-2005
#Source: FBI, Uniform Crime Reports, 1950-2005
#http://bjs.ojp.usdoj.gov/content/homicide/tables/totalstab.cfm
#and for 2006-2008 from
#http://www.fbi.gov/ucr/cius2008/data/table_01.html
#Since it has data up to 2008, it's the one we use
homicideUS<-c(4.6, 4.4, 4.6, 4.5, 4.2, 4.1, 4.1, 4, 4.8,
4.9, 5.1, 4.8, 4.6, 4.6, 4.9, 5.1, 5.6, 6.2,
6.9, 7.3, 7.9, 8.6, 9, 9.4, 9.8, 9.6, 8.8,
8.8, 9, 9.7, 10.2, 9.8, 9.1, 8.3, 7.9, 7.9,
8.6, 8.3, 8.4, 8.7, 9.4, 9.8, 9.3, 9.5, 9,
8.2, 7.4, 6.8, 6.3, 5.7, 5.5, 5.6, 5.6, 5.7,
5.5, 5.6, 5.7, 5.6, 5.4 )

#US 1900-2004
#Source: National Center for Health Statistics, Vital Statistics
#http://www.ojp.gov/bjs/glance/sheets/hmrt.csv
#homicideUS<-c(1.2, 1.2, 1.2, 1.1, 1.3, 2.1, 3.9, 4.9, 4.8,
#4.2, 4.6, 5.5, 5.4, 6.1, 6.2, 5.9, 6.3, 6.9,
#6.5, 7.2, 6.8, 8.1, 8, 7.8, 8.1, 8.3, 8.4,
#8.4, 8.6, 8.4, 8.8, 9.2, 9, 9.7, 9.5, 8.3,
#8, 7.6, 6.8, 6.4, 6.3, 6, 5.9, 5.1, 5, 5.7,
#6.4, 6.1, 5.9, 5.4, 5.3, 4.9, 5.2, 4.8, 4.8,
#4.5, 4.6, 4.5, 4.5, 4.6, 4.7, 4.7, 4.8, 4.9,
#5.1, 5.5, 5.9, 6.8, 7.3, 7.7, 8.3, 9.1, 9.4,
#9.7, 10.1, 9.9, 9, 9.1, 9.2, 10, 10.7, 10.3,
#9.6, 8.6, 8.4, 8.4, 9, 8.7, 9, 9.3, 10, 10.5,
#10, 10.1, 9.6, 8.7, 7.9, 7.4, 6.8, 6.2, 6.1,
#7.1, 6.1, 6.1, 5.9)

#England and Wales 1967-2008
#http://www.homeoffice.gov.uk/rds/pdfs09/hosb0209.pdf
#Table 1.01 Offences 1 initially recorded by the police as homicide by current classification2: England and Wales, 1955 to 2007/08
#Thanks data.gov.uk
homicideEW <- c(0.73, 0.74, 0.68, 0.7, 0.83, 0.83, 0.8, 1.07,
0.9, 0.99, 0.85, 0.96, 1.11, 1.11, 1.01, 1.12,
0.97, 1.08, 1.07, 1.12, 1.19, 1.09, 1.03, 1.09,
1.23, 1.14, 1.11, 1.24, 1.3, 1.14, 1.18, 1.18,
1.25, 1.3, 1.49, 1.54, 1.81, 1.47, 1.48, 1.35,
1.38, 1.41)
#http://scienceblogs.com/deltoid/1996/08/international-00028.php
#homicideEW<-c(1.26, 1.58, 1.42, 1.44, 1.36, 1.62, 1.76, 1.67,
#1.96, 1.82, 1.85, 1.71, 1.74, 1.43, 1.78, 1.7,
#1.58, 1.69, 1.55, 1.63, 1.53, 1.65, 1.51, 1.52,
#1.61, 1.57, 1.57, 1.57, 1.49, 1.56, 1.37, 1.43,
#1.07, 1.17, 1.02, 1.08, 1.13, 1.02, 1.13, 1.08,
#0.98, 1.04, 1.01, 0.97, 1.05, 1, 0.94, 0.94,
#0.84, 0.77, 0.77, 0.92, 0.85, 0.81, 0.81, 0.86,
#0.91, 0.73, 0.75, 0.69, 0.61, 0.54, 0.79, 0.83,
#0.66, 0.64, 0.68, 0.71, 0.82, 0.76, 0.75, 0.72,
#0.79, 0.75, 0.72, 0.72, 0.88, 0.86, 0.77, 0.88,
#0.74, 0.74, 0.85, 0.7, 0.75, 0.96, 0.76, 0.84,
#1.15, 0.81, 0.86, 0.78, 0.68, 0.79, 0.75, 0.91,
#0.74, 0.7, 0.63, 0.7, 0.71, 0.58, 0.59, 0.62,
#0.57, 0.64, 0.65, 0.63, 0.68, 0.76, 0.86, 0.86,
#0.81, 0.81, 0.94, 0.98, 0.95, 1.22, 1.03, 1.15,
#0.98, 1.09, 1.28, 1.26, 1.12, 1.25, 1.11, 1.24,
#1.25, 1.33, 1.37, 1.29, 1.25, 1.32, 1.42, 1.37,
#1.31)

#Mexico 1997-2008
#The equivalent of the data from the FBI
#http://www.icesi.org.mx/documentos/estadisticas/estadisticas/denuncias_homicidio_doloso_1997_2008.xls
#homicideMX<-c(17.10767812, 16.28038211, 15.06772946, 13.76493156,
#14.24853323, 12.99185544, 12.5098585, 11.34930884, 10.82764727,
#11.05514124, 9.727695883, 11.78918555)

#Mexico 1990-2008
#INEGI
#The equivalent of Vital Statistics, calculated from the directory homicides-suicides-accidents
hom <- read.csv("accidents-homicides-suicides/output/homicide.csv")
homicideMX <- hom$rate
#From the World Bank: Mexico 1980-1990
#c(11866,12485	12258	11819	14453	15497	15358	14810	14934)

#brazil 1990-1999
#http://www.paho.org/english/hcp/hcn/vio/violence-graphs.htm
#2000-2006 Wikipedia
#http://en.wikipedia.org/wiki/Homicide_rate
homicideBZ <- c(18.6, 17.5, 15.6, 16.7, 17.5, 19.3, 24, 25, 26, 25,
        26.7,27.8,28.4,28.9,27.4,26.6,25.7)



kyears <- 1950:2008
hom <- data.frame(year = c(kyears),
                  EW = c(rep(NA, length(kyears) -
                                 length(homicideEW)), homicideEW),
                  MX = c(rep(NA, length(kyears) -
                                 length(homicideMX)), homicideMX),
                  US = c(homicideUS),
                  BZ = c(rep(NA, length(kyears) -
                                 length(homicideBZ) - 2), homicideBZ,
                                 NA, NA)
                  )
mhom <- melt(hom, id = c("year"))
mhom <- subset(mhom, year >= 1990)

#International comparison
Cairo(file = "historic/output/ew-mx-us-homicide.png", width=450)
p <- ggplot(data = mhom, aes(year, value, group = variable,
            color = variable))  +
  geom_line(size = 1) +
  labs(y = "Homicide rate",x="") +
  opts (title = "Homicide rates in Brazil, Mexico, the US,\nand England and Wales (1990-2008)")
get.pos <-
  dl.indep(unique(transform(d,x = 2006, y = y[16]+1)))
print(direct.label(p, get.pos))
dev.off()






#line plot of the mexican homicide rate 1990-2008
Cairo(file = "historic/output/homicide-mx-1990-2008.png")
print(ggplot(hom[hom$year >= 1990, ], aes(year, MX),
       ylab = "Homicide rate")   +
  geom_line(size = 1) +
  opts(title = "Homicide rate in Mexico, 1990-2008 and 2009 (estimate)") +
  labs(y = "Homicide rate", x = "") +
  #Estimate for 2009. Based on a linear regression of the number of
  #executions in 2009 according to Reforma, and the fact that 2600
  #homicides occured in Ciudad Juárez.
  #See trends/seasonal-decomposition.r
  geom_line(data = data.frame(x=c(2008,2009), #,2010),
            y = c(homicideMX[19], 15.52)), #,17.5)),
            aes(x, y), color = "gray40", size=1, linetype=2) +
  geom_rect(xmin = 2006, xmax = 2009,
            ymin=0, ymax=Inf, alpha = .02, fill = "red") +
  annotate("text", x = 2007.5, y = 16.9, label = "Drug War"))
dev.off()
