########################################################
#####       Author: Diego Valle Jones              #####
#####       Website: www.diegovalle.net            #####
#####       Date: 2010-Jan-22                      #####
########################################################

#######################################################
#Time series of the monthly homicide rate by county in
#the Mexican states with the highest homicide rates,
#plus Michoacan which had the biggest decrease in
#homicides from 2006-2008
#######################################################
library(ggplot2)
library(Cairo)

source("constants.r")

#;;;;Apply an  artificial correction to the data
#;;;;to prove that Global Warming is happening
#;;;;Oh wait, wrong file

#Draw a multiple lines plot of each narco-state
cleanHom <-  function(df, state) {
  df <- df[grep(state, df$Code), ]
  df <- subset(df, Year.of.Murder != "Total" &
              Year.of.Murder != "No especificado" &
              Month.of.Murder != "Total" &
              Month.of.Murder != "No especificado" &
              County != "No especificado")
  df$Year.of.Murder <- as.numeric(gsub('[[:alpha:]]', '',
                                        df$Year.of.Murder))
  col2cvt <- 5:ncol(df)
  df[is.na(df)] <- 0
  df$Total.Murders <- apply(df[ , col2cvt], 1, sum)
  df$Month.of.Murder <- factor(df$Month.of.Murder)
  #The months are in a weird order, so 04=Abril, etc.
  levels(df$Month.of.Murder) <- c("04","08","12","01","02","07","06","03","05","11","10","09")

  df$Date <- as.Date(paste(df$Month.of.Murder,"/",
                    "01", "/",
                    df$Year.of.Murder, sep =""), "%m/%d/%Y")
  #Make sure we code the dates as the last day of the month
  df$Date <- as.Date(format(df$Date + 31, "%Y%m01"), "%Y%m%d") - 1

  #The data for the last month of 2008 isn't complete
  df <- subset(df, Date < as.Date("12/01/2008", "%m/%d/%Y"))

  #Remove the space that separates the state code from the
  #county code so we can merge the homicide data with the
  #population data
  df$Code <- as.numeric(gsub("[ ]", "", df$Code ))
  df
}

mergeHomPop <- function(df, pop, cutoff) {
  df.pop <- merge(df, pop, by.x=c("Code", "Year.of.Murder"),
        by.y=c("Code", "Year"))
  #Only big counties!
  #Subseting by size doesn't work because populations change
  #over time, so
  #a county that started at 90,000 will be missing half the
  #the observations
  counties100 <- subset(df.pop, Population > cutoff)
  states <- unique(factor(counties100$County.x))
  df.pop <- subset(df.pop, County.x %in% states)

  df.pop$rate <- (df.pop$Total.Murders / df.pop$Population * 100000) * 12
  #since the INEGI in all its wisdom decided to simply delete
  #the rows with no monthly homicides we have to recreate the
  #database to include them
  start <- as.Date("2005/2/01")
  next.mon <- seq(start, length=47, by='1 month')
  period <- next.mon - 1
  dates.df <- data.frame(Date = rep(period,
                                    each = length(states)),
                         County.x = rep(states,
                                        length(states) *
                                        length(period))
                         )
  df.pop <- merge(dates.df, df.pop,
                   by = c("Date", "County.x"),
                   all.x = TRUE)
  #An NA means there were no murders, so we have to change it to 0
  df.pop$rate[is.na(df.pop$rate)] <- 0
  df.pop$Total.Murders[is.na(df.pop$Total.Murders)] <- 0
  df.pop
}

getData <- function(df, pop, state, cutoff){
  hom.clean <- cleanHom(df, state)
  mergeHomPop(hom.clean, pop, cutoff)
}

cleanPop <- function(filename) {
  pop <- read.csv(bzfile(filename))
  pop <- na.omit(pop)
  col2cvt <- 3:ncol(pop)
  pop[,col2cvt] <- lapply(pop[ ,col2cvt],
                          function(x){as.numeric(gsub(" ", "", x))})
  popm <- melt(pop, id = c("Clave", "Entidad.federativa.o.municipio"))
  #remove the space before the county code
  popm$variable <- as.numeric(substring(popm$variable, 2))
  names(popm) <- c("Code", "County", "Year","Population")
  popm
}

drawPlot <- function(df.pop) {
    ggplot(df.pop, aes(Date, rate)) +
      geom_point(aes(size=Total.Murders), color="darkred") +
      facet_wrap(~ County.x, as.table = FALSE, ncol = 1,
                 scale="free_y") +
      scale_x_date() +
      #geom_smooth(se = FALSE) +
      xlab("") + ylab("Homicide rate")
}

#ToDo: figure out why this doesn't work
addvline <- function(op.date) {
  geom_vline(xintercept = op.date, alpha=.4)
}

addtext <- function(p, date, opname){
  p + geom_text(aes(x,y), label = opname,
            data = data.frame(x = date, y = -10),
            size = 3, hjust = 1, vjust = 0)
#  geom_vline(aes(xintercept = date), alpha=.4)
}


hom <- read.csv(bzfile("data/county-month.csv.bz2"))
pop <- cleanPop("data/pop.csv.bz2")

#the county must be this big to enter the chart
popsize <- 100000

########################################################
#Finally, the plots
########################################################


#Baja Califronia Norte! as the ICESI would say, hahahaha
bcn.df <- getData(hom, pop, baja.california, popsize)
bcn.df$group <- cutDates(bcn.df, c(op.tij))

p <- drawPlot(bcn.df) + geom_vline(aes(xintercept = op.tij), alpha=.4)
addtext(p, op.tij, "Joint Operation Tijuana") + geom_smooth(aes(group = group), se = FALSE)
dev.print(png, file="output/Baja California.png", width=600, height=600)


#Sonora
son.df <- getData(hom, pop, sonora, popsize)
son.df$group <- cutDates(son.df, c(op.son))

p <- drawPlot(son.df) + geom_vline(aes(xintercept = op.son), alpha=.4)
addtext(p, op.son, "Operation Sonora I") + geom_smooth(aes(group = group), se = FALSE)
dev.print(png, file = "output/Sonora.png", width=600, height=600)


#Chihuahua
chi.df <- getData(hom, pop, chihuahua, popsize)
chi.df$group <- cutDates(chi.df, c(op.tria.dor, op.chi))

p <- drawPlot(chi.df) + geom_vline(aes(xintercept = op.chi), alpha=.4)
p <- addtext(p, op.chi, "Joint Operation Chihuahua")
p <- addtext(p, op.tria.dor, "Jint Operation Triangulo Dorado")
p + geom_vline(aes(xintercept = op.tria.dor), alpha=.4) + geom_smooth(aes(group = group), se = FALSE)
dev.print(png, file = "output/Chihuahua.png", width=600, height=600)


#Michoacán (I hate trying to get emacs and R to understand utf!)
mich.df <- getData(hom, pop, michoacan, popsize)
mich.df$group <- cutDates(mich.df, c(op.mich))

p <- drawPlot(mich.df) + geom_vline(aes(xintercept = op.mich), alpha=.4)
addtext(p, op.mich, "Joint Operation Michoacan") + geom_smooth(aes(group = group), se = FALSE)
dev.print(png, file = "output/Michoacan.png", width=600, height=600)


#Sinadroga
sin.df <- getData(hom, pop, sinaloa, popsize)
sin.df$group <- cutDates(sin.df, c(op.tria.dor, op.sin))

p <- drawPlot(sin.df) + geom_vline(aes(xintercept = op.sin), alpha=.4)
p <- addtext(p, op.sin, "Joint Operation Culiacan-Navolato")
p <- addtext(p, op.tria.dor, "Joint Operation Triangulo Dorado")
p + geom_vline(aes(xintercept = op.tria.dor), alpha=.4) + geom_smooth(aes(group = group), se = FALSE)
dev.print(png, file = "output/Sinaloa.png", width=700, height=600)


#Durango
dur.df <- getData(hom, pop, durango, popsize)
dur.df$group <- cutDates(dur.df, c(op.tria.dor, op.tria.dor.III))

p <- drawPlot(dur.df) + geom_vline(aes(xintercept = op.tria.dor), alpha=.4)
p <- addtext(p, op.tria.dor, "Joint Operation Triangulo Dorado")
p <- addtext(p, op.tria.dor.III, "Phase III")
p + geom_vline(aes(xintercept = op.tria.dor.III), alpha=.4) + geom_smooth(aes(group = group), se = FALSE)
dev.print(png, file = "output/Durango.png", width=600, height=600)




#The data for Oaxaca and Guerrero are in another file
hom <- read.csv(bzfile("data/county-month-gue-oax.csv.bz2"))


#Guerrero
gue.df <- getData(hom, pop, guerrero, popsize)
gue.df$group <- cutDates(gue.df, c(op.gue))

p <- drawPlot(gue.df) + geom_vline(aes(xintercept = op.gue), alpha=.4)
addtext(p, op.gue, "Joint Operation Guerrero") + geom_smooth(aes(group = group), se = FALSE)
dev.print(png, file = "output/Guerrero.png", width=600, height=600)



#The data for Nuevo Leon and Tamaulipas are in yet another file
hom <- read.csv(bzfile("data/county-month-nl-tam.csv.bz2"))



#Tamaulipas
tam.df <- getData(hom, pop, tamaulipas, popsize)
tam.df$group <- cutDates(tam.df, c(op.tam.nl))
p <- drawPlot(tam.df) + geom_vline(aes(xintercept = op.tam.nl), alpha=.4)
addtext(p, op.tam.nl, "Joint Operation Tamaulipas-Nuevo Leon") + geom_smooth(aes(group = group), se = FALSE)
dev.print(png, file = "output/Tamaulipas.png", width=600, height=900)

#Nuevo Leon
#Tamaulipas
nl.df <- getData(hom, pop, nuevo.leon, popsize)
nl.df$group <- cutDates(nl.df, c(op.tam.nl))
p <- drawPlot(nl.df)+ geom_vline(aes(xintercept = op.tam.nl), alpha=.4)
addtext(p, op.tam.nl, "Joint Operation Tamaulipas-Nuevo Leon") + geom_smooth(aes(group = group), se = FALSE)
dev.print(png, file = "output/Nuevo-Leon.png", width=600, height=900)

