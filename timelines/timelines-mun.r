########################################################
#####       Author: Diego Valle Jones              #####
#####       Website: www.diegovalle.net            #####
#####       Date: 2010-Jan-22                      #####
########################################################

#######################################################
#Time series of the monthly homicide rate by county in
#the Mexican states where joint military operations
#took place from 2006-2008
#######################################################

source("timelines/constants.r")
source("library/utilities.r")

#;;;;Apply an  artificial correction to the data
#;;;;to prove that Global Warming is happening
#;;;;Oh wait, wrong file

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
  #The months are in alphabetical order, so 04=Abril, etc.
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

mergeHomPop <- function(df, pop, cutoff, counties = NULL) {
  df$Month.of.Murder <- as.numeric(as.character(df$Month.of.Murder))
  df.pop <- merge(df, pop, by.x=c("Code", "Year.of.Murder",
                                  "Month.of.Murder"),
        by.y=c("Code", "Year", "Month"), all.x=TRUE)
  #Only big counties!
  #Subseting by size doesn't work because populations change
  #over time, so
  #a county that started at 90,000 will be missing half the
  #the observations
  counties100 <- subset(df.pop, Population > cutoff)
  states <- unique(factor(counties100$County.x))
  df.pop <- subset(df.pop, County.x %in% states)
  if(!is.null(counties)){
    states <- factor(counties)
    df.pop <- subset(df.pop, County.x %in% counties)
  }

  df.pop$rate <- (df.pop$Total.Murders / df.pop$value * 100000) * 12
  #since the INEGI in all its wisdom decided to simply delete
  #the rows with no monthly homicides we have to recreate the
  #database to include them
  start <- as.Date(as.Date("2005/02/01"))
  next.mon <- seq(start, length=47, by='1 month')
  period <- next.mon - 1
  dates.df <- data.frame(Date = rep(period,
                                    each = length(states)),
                         County.x = rep(states, length(period))
                         )
  dates.df$DateMid <- as.Date(format(dates.df$Date, "%Y%m15"),
                              "%Y%m%d")
  df.pop <- merge(dates.df, df.pop,
                   by = c("Date", "County.x"),
                   all.x = TRUE)
  #An NA means there were no murders, so we have to change it to 0
  df.pop$rate[is.na(df.pop$rate)] <- 0
  df.pop$Total.Murders[is.na(df.pop$Total.Murders)] <- 0
  df.pop
}

getData <- function(df, pop, state, cutoff, counties = NULL){
  hom.clean <- cleanHom(df, state)
  mergeHomPop(hom.clean, pop, cutoff, counties)
}

addMonths <- function(pop){
  allmonths <- seq(2005, 2008.9999, by = 1/12)
  pop2 <- data.frame(time=allmonths, Year=floor(allmonths),
                     month = 1:12)
  pop2 <- merge(pop, pop2, by = "Year", all.y = TRUE)
  pop2$Monthly.Pop[pop2$month == 6] <-
      pop2[pop2$month == 6,]$Population

  estimates <- ddply(pop2, .(Code),
             function(df) na.spline(df$Monthly.Pop, na.rm=FALSE))
  estimates <- melt(estimates, id="Code")
  estimates$Month <- rep(1:12, each=2454)
  estimates$Year <- rep(2005:2008, each=2454*12)
  pop <- merge(pop, estimates, by = c("Year", "Code"))
  pop
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
  addMonths(popm)
}

#http://stackoverflow.com/questions/2270201/how-to-get-geom-vline-and-facet-wrap-from-ggplot2-to-work-inside-a-function
drawTS <- function(df.pop, operations, title, method) {
    date.df <- data.frame(d = as.Date(unlist(operations),
                                      origin = "1970-01-01"),
                          t = names(operations))
    df.pop$County.x <- reorder(factor(df.pop$County.x), -df.pop$rate)
    ggplot(df.pop, aes(DateMid, rate)) +
      geom_point(aes(size=Total.Murders), color="darkred", alpha =.9) +
      scale_x_date() +
      geom_smooth(aes(group = group), se = FALSE, method = method) +
      xlab("") + ylab("Annualized Homicide Rate") +
      geom_text(aes(x = d, label = t, y = -9),
                   data = date.df,
                   size = 3, hjust = 1, vjust = 0) +
      geom_vline(aes(xintercept = d), data = date.df,
                        alpha = .4) +
      facet_wrap(~ County.x, ncol = 1,
                 scale="free_y") +
      scale_size("Number of\nHomicides") +
      opts(title = title)
      #theme_bw()
      #opts(legend.position = "none")
}

createPlot <- function(df.pop, operations, title = "", method, hack) {
  df.pop$group <- cutDates(df.pop, unlist(operations), hack)
  drawTS(df.pop, operations, title, method)
}

breaks <- function(df, brks, h, ll){
  ndays <- strptime(df$Date, format = "%Y-%m-%d")$mday
  rate <- ts(df$rate, start=2005, freq=12)
  #fd <- Fstats(rate ~ 1)
  bp.mun <- breakpoints(rate ~ ndays, h)
  x <- confint(bp.mun, breaks = brks)
  data.frame(x$confint)
}

convertToDate <- function(x){
    d <- as.Date(paste((x %% 12) + 1,"/",
                    "15", "/",
                    floor(x / 12) + 2005, sep =""), "%m/%d/%Y")
    #as.Date(format(d + 31, "%Y%m01"), "%Y%m%d") - 1
    #format(d, format = "%b")
}

convertDateToChar <- function(df){
  dateToChar <- function(x){
      as.character(as.Date(x))
      format(as.Date(x), format = "%b-%y")
  }
  dateToFullChar <- function(x){
      as.character(as.Date(x))
      format(as.Date(x), format = "%d-%b-%y")
  }
  df[,2:4] <- sapply(df[,2:4], dateToChar)
  df[,5:ncol(df)] <- sapply(df[,5:ncol(df)], dateToFullChar)
  df
}

addOps <- function(df, ll){
  cbind(df, t(unlist(ll)))
}

joinBreaksOps <- function(df, ll){
  df[2:4] <- sapply(df[2:4], convertToDate)
  df <- addOps(df, ll)
  names(df)[1:4] <- c("Municipality", "Lower", "Breakpoints", "Upper")
  convertDateToChar(df)
}

findbreaks <- function(df, brks = 1, h = .15, ll){
  breakpoints <- ddply(df, .(County.x), breaks, brks, h, ll)
  joinBreaksOps(breakpoints, ll)
}

savePlot <- function(df, ll, title = "", width = 700, height = 600,
                      file, method = lm, hack = 0) {
    Cairo(width, height, file=file, type="png", bg="white")
    print(createPlot(df, ll, title, method, hack))
    dev.off()
}


hom <- read.csv(bzfile("timelines/data/county-month.csv.bz2"))
pop <- cleanPop("timelines/data/pop.csv.bz2")

#the county must be this big to enter the chart
popsize <- 100000

########################################################
#Finally, the plots
########################################################
report.ll <- list()

#Baja Califronia Norte! as the ICESI would say, hahahaha
bcn.df <- getData(hom, pop, baja.california, popsize)
ll.bcn <- list("Joint Operation Tijuana" = op.tij,
           "E.A.F. Captured" = doctor)
#This is a horrible hack. stat_smooth dies when it tries do
#do an lm with n = 1
savePlot(bcn.df, ll.bcn,
         "Baja California - Homicide Rates and Military Operations",
          file = "timelines/output/Baja California.png",
          hack = 15)
report.ll$bcn <- findbreaks(bcn.df, h = 3, ll = ll.bcn)



#Sonora
son.df <- getData(hom, pop, sonora, popsize)
ll.son <- list("Operation Sonora I" = op.son)
savePlot(son.df, ll.son,
         "Sonora - Homicide Rates and Military Operations",
         file = "timelines/output/Sonora.png")
report.ll$son <- findbreaks(son.df, 1, ll = ll.son)

#Chihuahua
chi.df <- getData(hom, pop, chihuahua, popsize)
ll.chi <- list("Joint Operation Triangulo Dorado" = op.tria.dor,
           "Joint Operation Chihuahua" = op.chi)
savePlot(chi.df, ll.chi,
         "Chihuahua - Homicide Rates and Military Operations",
         file = "timelines/output/Chihuahua.png", height=700)
report.ll$chi <- findbreaks(chi.df, 1, ll = ll.chi)

#Interesting municipalities in Chihuahua (bordering the US)
muni <- c("Janos", "Ascensión",
          "Guadalupe",
          "Ojinaga", "Praxedis G. Guerrero",
          "Ahumada",
          "Nuevo Casas Grandes",
          "Coyame del Sotol")
chi.bdr.df <- getData(hom, pop, chihuahua, 0, muni)
savePlot(chi.bdr.df, ll.chi,
         "Chihuahua - Municipalities Near the US Border (excluding C. Juarez)",
         file = "timelines/output/Chihuahua-border.png", height=700)
report.ll$chi.bdr <- findbreaks(chi.bdr.df, 1, ll = ll.chi)

#Now just the ones with a high murder rate (and Creel 'cause of the name)
muni <- c("Coronado", "Matamoros", "Balleza", "Nonoava",
           "Valle de Zaragoza", "Hidalgo del Parral",
           "San Francisco de Borja", "Namiquipa", "Ocampo",
           "Guazapares","Bocoyna")
chi.int.df <- getData(hom, pop, chihuahua, 0, muni)
savePlot(chi.int.df, ll.chi,
         "Chihuahua - Some Municipalities with a High Homicide Rate",
         file = "timelines/output/Chihuahua-interstng.png", height=700)
report.ll$chi.int <- findbreaks(chi.int.df, 1, ll = ll.chi)


#MichoacÃ¡n (I hate trying to get emacs and R to understand utf!)
mich.df <- getData(hom, pop, michoacan, popsize)
ll.mich <- list("Joint Operation Michoacan" = op.mich,
                "A.B.L. Captured" = bel.ley)
savePlot(mich.df, ll.mich,
         "Michoacan - Homicide Rates and Military Operations",
         file = "timelines/output/Michoacan.png", height=700)
report.ll$mich <- findbreaks(mich.df, 2, ll = ll.mich)

#Interesting Municipalities in Michoacán (Pacific coast and bordering Guerrero)
muni <- c("Aquila", "Chinicuila", "Coalcomán de Vázquez Pallares",
          "Tepalcatepec",
          "Aguililla", "Tumbiscatío", "Arteaga", "Apatzingán",
          "Churumuco", "Huetamo", "Carácuaro", "Turicato",
          "Tacámbaro")
mich.int.df <- getData(hom, pop, michoacan, 0, muni)
savePlot(mich.int.df, ll.mich,
         "Michoacan - Municipalities near the Pacific and Guerrero",
         file = "timelines/output/Michoacan-interstng.png", height=900)
report.ll$mich.int <- findbreaks(mich.int.df, 2, ll = ll.mich)


#Sinadroga
sin.df <- getData(hom, pop, sinaloa, popsize)
ll.sin <- list("Joint Operation Triangulo Dorado" = op.tria.dor,
           "Joint Operation Culiacan-Navolato" = op.sin)
savePlot(sin.df, ll.sin,
         "Sinaloa - Homicide Rates and Military Operations",
         file = "timelines/output/Sinaloa.png", height=700)
report.ll$sin <- findbreaks(sin.df, 1, ll = ll.sin)

#Municipalities in Sinaloa with a high homicide rate
muni <-  c("Badiraguato", "Sinaloa", "Mocorito", "Cosalá",
           "San Ignacio")
sin.int.df <- getData(hom, pop, sinaloa, 0, muni)
savePlot(sin.int.df, ll.sin,
         "Sinaloa - Municipalities with a high homicide rate",
         file = "timelines/output/Sinaloa-interstng.png", height=900)
report.ll$sin.int <- findbreaks(sin.int.df, 1, ll = ll.sin)


#Durango
dur.df <- getData(hom, pop, durango, popsize)
ll.dur <- list("Joint Operation Triangulo Dorado" = op.tria.dor,
           "Phase III"=op.tria.dor.III)
savePlot(dur.df, ll.dur,
         "Durango - Homicide Rates and Military Operations",
         file = "timelines/output/Durango.png")
report.ll$dur <- findbreaks(dur.df, 1, ll = ll.dur)

#Municpalities in Durango with a high murder rate
muni <- c("Súchil", "Mezquital", "Pueblo Nuevo", "San Dimas",
          "Vicente Guerrero", "Poanas", "Guanaceví", "Tepehuanes",
          "Ocampo", "El Oro")
dur.int.df <- getData(hom, pop, durango, 0, muni)
savePlot(dur.int.df, ll.dur,
         "Durango - Municipalities with a high homicide rate",
         file = "timelines/output/Durango-interstng.png", height = 900)
report.ll$dur.int <- findbreaks(dur.int.df, 1, ll = ll.dur)

#The data for Oaxaca and Guerrero are in another file
hom <- read.csv(bzfile("timelines/data/county-month-gue-oax.csv.bz2"))

#Guerrero
gue.df <- getData(hom, pop, guerrero, popsize)
ll.gue <- list("Joint Operation Guerrero" = op.gue,
           "A.B.L. Captured" = bel.ley)
savePlot(gue.df, ll.gue,
         "Guerrero - Homicide Rates and Military Operations",
         file = "timelines/output/Guerrero.png", height=700)
report.ll$gue <- findbreaks(gue.df, 2, ll = ll.gue)


#Interesting Municipalities in guerrero
muni <- c("Zirándaro", "Coyuca de Catalán", "La Unión de Isidoro Montes de Oca", "Coahuayutla de José María Izazaga", "Pungarabato", "Cutzamala de Pinzón", "Arcelia")
gue.df.b <- getData(hom, pop, guerrero, 0, muni)
savePlot(gue.df.b, ll.gue,
         "Guerrero - Municipalities Bordering Michoacan",
         file = "timelines/output/Guerrero-mich-border.png",
         height=700)
report.ll$gue.int <- findbreaks(gue.df.b, 2, ll = ll.gue)



#There were some changes in the municipalities of Oaxaca and
#their populations don't match the ones in the CONAPO data
#so I'm excluding them
#report.ll$oax <- findbreaks(getData(hom, pop, oaxaca, 50000),
#                            2, ll = ll)


#The data for Nuevo Leon and Tamaulipas is in yet another file
hom <- read.csv(bzfile("timelines/data/county-month-nl-tam.csv.bz2"))
popsize <- 250000

#Tamaulipas
tam.df <- getData(hom, pop, tamaulipas, popsize)
ll.tam <- list("Troops in N.L." = foxy.troops,
               "Joint Operation Tamaulipas-Nuevo Leon" = op.tam.nl)
savePlot(tam.df, ll.tam,
         "Tamaulipas - Homicide Rates and Military Operations",
         file = "timelines/output/Tamaulipas.png",
         method = lm)
report.ll$tam <- findbreaks(tam.df, 2, ll = ll.tam)

#Nuevo Leon
nl.df <- getData(hom, pop, nuevo.leon, popsize)
ll.nl <- list("Joint Operation Tamaulipas-Nuevo Leon" = op.tam.nl)
savePlot(nl.df, ll.nl,
         "Nuevo Leon - Homicide Rates and Military Operations",
         file = "timelines/output/Nuevo-Leon.png")
report.ll$nl <- findbreaks(nl.df, 1, ll = ll.nl)

muni <- c("Apodaca", "Cadereyta Jiménez",
          "Juárez", "García",
          "Gral. Escobedo", "Guadalupe",
          "Monterrey",
          "Santa Catarina", "San Nicolás de los Garza",
          "San Pedro Garza García", "Santiago")
mont.df <- getData(hom, pop, nuevo.leon, 0, muni)
savePlot(mont.df, ll.nl,
         "Nuevo Leon - Metropolitan Area of Monterrey",
         file = "timelines/output/Monterrey.png", height=700)
report.ll$mont <- findbreaks(mont.df, 1, ll = ll.nl)

#Veracruz
hom <- read.csv(bzfile("timelines/data/county-month-ver.csv.bz2"))
popsize <- 250000

ver.df <- getData(hom, pop, veracruz, popsize)
ll.ver <- list("Joint Operation Veracruz" = op.ver)
savePlot(ver.df, ll.ver,
         "Veracruz - Homicide Rates and Military Operations",
         file = "timelines/output/Veracruz.png")
report.ll$ver <- findbreaks(ver.df, 1, ll = ll.ver)

muni <- c("Veracruz", "Xalapa",
          "Poza Rica de Hidalgo", "Minatitlán")
ver.int.df <- getData(hom, pop, veracruz, 0, muni)
savePlot(ver.int.df, ll.ver,
         "Veracruz - Interesting Municipalities",
         file = "timelines/output/Veracruz-int.png", height=700)
report.ll$ver.int <- findbreaks(ver.int.df, 1, ll = ll.ver)



Sweave("timelines/report/report.Rnw",
        output = "timelines/report/report.tex")
