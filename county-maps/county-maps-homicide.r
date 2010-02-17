########################################################
#####       Author: Diego Valle Jones
#####       Website: www.diegovalle.net
#####       Date Created: Sun Jan 24 19:33:22 2010
########################################################
#Maps of the homicide rate by county according to the INEGI
#data source: Estad√≠sticas Vitales INEGI

library(ggplot2)
library(Hmisc)
library(maptools)
library(RColorBrewer)
library(classInt)
library(Cairo)

#location of the INEGI maps
source("../maps-locations.r")


#Clean data file with all homicides *registered* by county and sex
cleanHomicide <- function(filename, sex) {
  df <- read.csv(bzfile(filename), skip = 4)
  names(df)[1:4] <- c("Code","County","Year.of.Murder","Sex")
  df <- df[-grep("=CONCATENAR", df$Code),]
  #df <- df[-grep("FUENTE: INEGI. EstadÌsticas de mortalidad.", df$Code),]
  df <- df[-grep("Total", df$County),]
  df <- df[-grep("No especificado", df$County),]
  df <- df[-grep("Total", df$Year.of.Murder),]
  df <- df[-grep("No especificado", df$Year.of.Murder),]
  if (sex=="Total") {
    df <- df[grep("Total", df$Sex),]
  } else if (sex == "Mujer") {
     df <- df[grep("Mujer", df$Sex),]
  } else if (sex == "Dfbre") {
    df <- df[grep("Dfbre", df$Sex),]
  }

  df$X.4 <- NULL
  df$Year.of.Murder <- as.numeric(gsub('[[:alpha:]]', '',
                                   df$Year.of.Murder))
  df <- subset(df, Year.of.Murder >= 1990)
  col2cvt <- 5:ncol(df)
  df[,col2cvt] <- lapply(df[,col2cvt],
                          function(x){
                              as.numeric(gsub(",", "", x))})
  df[is.na(df)] <- 0
  df$tot <- apply(df[ , col2cvt], 1, sum)
  df$CLAVE <- as.numeric(gsub(" ", "", df$Code))
  df
}

#population from the CONAPO
cleanPopCONAPO <- function(filename) {
  pop <- read.csv(bzfile(filename))
  pop <- na.omit(pop)
  col2cvt <- 3:ncol(pop)
  pop[,col2cvt] <- lapply(pop[ ,col2cvt],
                          function(x){
                              as.numeric(gsub(" ", "", x))})
  popm <- melt(pop, id = c("Clave", "Entidad.federativa.o.municipio"))
  #The CONAPO adds a "0" to the county codes, remove it
  popm$variable <- substring(popm$variable, 2)
  names(popm) <- c("Clave", "County", "Year", "Population")
  popm
}

#population from the inegi
cleanPopINEGI <- function(filename, year) {
  pop <- read.csv(filename)
  pop <- na.omit(pop)
  pop <- subset(pop, County != "Total" &
                     Code != "#NAME?")
  pop$Clave <- as.numeric(gsub(" ", "", pop$Code))
  pop$Code <- NULL
  pop$Hombres <- NULL
  pop$Mujeres <- NULL
  pop$Year <- year
  names(pop)[2] <- "Population"
  pop
}

#################################################################
#Read the files with the data and population, then merge them
################################################################
hom <- cleanHomicide("../states/data/homicide-mun-2008.csv.bz2", "Total")
#read the file with population data from 2006-2008
popm <- cleanPopCONAPO("data/pop.csv.bz2")
#read the files with population data from the censuses
pop90 <- cleanPopINEGI("data/inegi1990.csv", 1990)
pop95 <- cleanPopINEGI("data/inegi1995.csv", 1995)
pop00 <- cleanPopINEGI("data/inegi2000.csv", 2000)
#combine them in a single data.frame
popm <- rbind(popm, pop90, pop95, pop00)

hom.popm <- merge(hom, popm, by.x = c("CLAVE", "Year.of.Murder"),
                  by.y = c("Clave", "Year"))
hom.popm$rate<- (hom.popm$tot / hom.popm$Population) *
                        100000
hom.popm <- hom.popm[order(-hom.popm$rate),]
#plot(hom.popm$rate)

########################################################
#Draw a map of Mexico
########################################################

#For memory reasons these are global variables
#County map
mexico.ct.shp <- readShapePoly(map.inegi.ct,
                               IDvar = "CLAVE",
                               proj4string = CRS("+proj=aea"))
#State map
mexico.st.shp <- readShapePoly(map.inegi.st,
                               proj4string = CRS("+proj=aea"))

#Plot a map of the murder rate
drawMap <- function(vector, title) {
  plotvar<- unlist(vector)
  nclr <- 9
  plotclr <- brewer.pal(nclr,"Reds")

  #doesn't look as good with continuous colors
  #clr.inc <- colorRampPalette(brewer.pal(9, "Reds"))
  #obs <- 60
  #index <- round(vector) + 1
  #colcode <- ifelse(vector > 60,
  #                  clr.inc(obs)[60],
  #                  clr.inc(obs)[index])

  class <- classIntervals(plotvar, nclr, style="fixed",
                          fixedBreaks =
                          c(0,0.1,3,6,12,20,40,60,80,Inf))
  colcode <- findColours(class, plotclr)
  plot(mexico.ct.shp, col = colcode, lty = 0, border = "gray")
  plot(mexico.st.shp, add = TRUE, lwd=1, border = "gray30")
  title(main = title)
  inter <- paste(names(attr(colcode, "table")),c("","",""))
  inter[1] <- "0"
  legend(3600000,2200000, legend=inter, #use axes=T to find the pos!
      fill=attr(colcode, "palette"), cex=1, bty="n")
  par(bg='white')
}

#As always it's a pain to make sure the counties line up
#with the correct data
mergeMap <- function(df, year){
  hom.popmX <- subset(df, Year.of.Murder == year)
  mun.complete<-data.frame(CLAVE = mexico.ct.shp$CLAVE)
  hom.popmX$CLAVE <- gsub(" ", "", hom.popmX$Code)
  map<-merge(mun.complete, hom.popmX, by = "CLAVE", all.x = TRUE)
  map$rate[is.na(map$rate)] <- 0
  map
}

#From 2006 to 2008, and 1990, 1995, 2000
#CairoSVG(file = "output/Homicide rate by county, 2008.svg", dpi = 50)
Cairo(file = "output/Homicide rate by county, 2008.png", width=960, height=600)
map <- mergeMap(hom.popm, 2008)
drawMap(map$rate, "Homicide rate by county, 2008")
dev.off()

Cairo(file = "output/Homicide rate by county, 2007.png", width=960, height=600)
map <- mergeMap(hom.popm, 2007)
drawMap(map$rate, "Homicide rate by county, 2007")
dev.off()

Cairo(file = "output/Homicide rate by county, 2006.png", width=960, height=600)
map <- mergeMap(hom.popm, 2006)
drawMap(map$rate, "Homicide rate by county, 2006")
dev.off()


Cairo(file = "output/Homicide rate by county, 1990.png", width=960, height=600)
map <- mergeMap(hom.popm, 1990)
drawMap(map$rate, "Homicide rate by county, 1990")
dev.off()

Cairo(file = "output/Homicide rate by county, 1995.png", width=960, height=600)
map <- mergeMap(hom.popm, 1995)
drawMap(map$rate, "Homicide rate by county, 1995")
dev.off()

Cairo(file = "output/Homicide rate by county, 2000.png", width=960, height=600)
map <- mergeMap(hom.popm, 2000)
drawMap(map$rate, "Homicide rate by county, 2000")
dev.off()
