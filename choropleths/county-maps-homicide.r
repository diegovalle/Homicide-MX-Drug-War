########################################################
#####       Author: Diego Valle Jones
#####       Website: www.diegovalle.net
#####       Date Created: Sun Jan 24 19:33:22 2010
########################################################
#Maps of the homicide rate by county according to the INEGI
#data source: Estadísticas Vitales INEGI


#Clean data file with all homicides *registered* by county and sex
cleanHomicide <- function(filename, sex) {
  df <- read.csv(bzfile(filename), skip = 4)
  names(df)[1:4] <- c("Code","County","Year.of.Murder","Sex")
  df <- df[-grep("=CONCATENAR", df$Code),]
  #df <- df[-grep("FUENTE: INEGI. Estadísticas de mortalidad.", df$Code),]
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
cleanPopINEGI <- function(filename, year, type = "Total") {
  pop <- read.csv(filename)
  pop <- na.omit(pop)
  pop <- subset(pop, County != "Total" &
                     Code != "#NAME?")
  pop$Clave <- as.numeric(gsub(" ", "", pop$Code))
  pop$Code <- NULL
  if (type == "Total") {
    pop$Hombres <- NULL
    pop$Mujeres <- NULL
  } else if (type == "Mujer"){
    pop$Total <- NULL
    pop$Hombres <- NULL
  }
  pop$Year <- year
  names(pop)[2] <- "Population"
  pop
}

#Plot a map of the murder rate
drawMap <- function(vector, title, breaks) {
  plotvar<- unlist(vector)
  nclr <- 9
  plotclr <- brewer.pal(nclr,"Reds")
  class <- classIntervals(plotvar, nclr, style="fixed",
                          fixedBreaks = breaks)
  colcode <- findColours(class, plotclr)
  plot(mexico.ct.shp, col = colcode, lty = 0, border = "gray")
  plot(mexico.st.shp, add = TRUE, lwd=1, border = "gray30")
  title(main = title)
  inter <- paste(names(attr(colcode, "table")),c("","",""))
  inter[1] <- "0"
  legend(3600000,2300000, legend=inter, #use axes=T to find the pos!
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

savePlot <- function(df, year, breaks){
    name <- config$titles.ch
    map <- mergeMap(df, year)
    filename <- paste("choropleths/output/", name, ", ",
                      as.character(year), ".png", sep ="")
    title <- paste(name, ", ", as.character(year), sep ="")
    Cairo(file = filename,
          width=960, height=600, type="png", bg="white")
    print(drawMap(map$rate, title, breaks))
    dev.off()
    TRUE
}

#read the file with population data from 2006-2008
#read the files with population data from the censuses
readPop <- function(type){
  if(type=="Total") {
    popm <- cleanPopCONAPO("choropleths/data/pop.csv.bz2")
  } else{
    popm <- cleanPopCONAPO("choropleths/data/pop-w.csv.bz2")
  }
  pop90 <- cleanPopINEGI("choropleths/data/inegi1990.csv", 1990, type)
  pop95 <- cleanPopINEGI("choropleths/data/inegi1995.csv", 1995, type)
  pop00 <- cleanPopINEGI("choropleths/data/inegi2000.csv", 2000, type)

  rbind(popm, pop90, pop95, pop00)
}

mergeHomPop <- function(hom, popm){
  hom.popm <- merge(hom, popm, by.x = c("CLAVE", "Year.of.Murder"),
                    by.y = c("Clave", "Year"))
  hom.popm$rate<- (hom.popm$tot / hom.popm$Population) *
                          100000
  hom.popm <- hom.popm[order(-hom.popm$rate),]
  #The municpalities in Oaxaca have changed since the CONAPO
  #released its population database, we have to merge them
  #by name. Hopefully their boundaries haven't changed much
  changed <- setdiff(hom$CLAVE, popm$Clave)
  hom.ch <- subset(hom, CLAVE %in% changed)
  hom.popm.ch <- merge(hom.ch, popm, by.x = c("County",
                                             "Year.of.Murder"),
                    by.y = c("County", "Year"))
  hom.popm.ch$CLAVE <- NULL
  hom.popm.ch$rate<- (hom.popm.ch$tot / hom.popm.ch$Population) *
                          100000
  hom.popm.ch$County.y <- hom.popm.ch$County
  names(hom.popm.ch)[1] <- "County.x"
  names(hom.popm.ch)[25] <- "CLAVE"
  rbind(hom.popm, hom.popm.ch)
}

#For memory reasons these are global variables
#County map
mexico.ct.shp <- readShapePoly(map.inegi.ct,
                               IDvar = "CLAVE",
                               proj4string = CRS("+proj=aea"))
#State map
mexico.st.shp <- readShapePoly(map.inegi.st,
                               proj4string = CRS("+proj=aea"))


if(config$sex == "Female"){
  type <- "Mujer"
  config$titles.ch <- config$choropleths$ftitle.ch
  breaks <- c(0,0.05,1,2,3,4,5,10,20,Inf)
} else {
  type <- "Total"
  config$titles.ch <- config$choropleths$mtitle.ch
   breaks <- c(0,0.1,3,6,12,20,40,60,80,Inf)
}

#################################################################
#Read the files with the data and population, then merge them
################################################################
hom <- cleanHomicide("states/data/homicide-mun-2008.csv.bz2", type)
popm <- readPop(type)
hom.popm <- mergeHomPop(hom, popm)

########################################################
#Draw choropleths of Mexico
########################################################
sapply(c(1990,1995,2000, 2006:2008), savePlot, breaks = breaks,
       df = hom.popm)

