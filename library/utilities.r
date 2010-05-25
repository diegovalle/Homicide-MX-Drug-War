########################################################
#####       Author: Diego Valle Jones
#####       Website: www.diegovalle.net
#####       Date Created: Thu Feb 04 13:35:41 2010
########################################################
#Shared functions

#Group dates into intervals
cutDates <- function(df, dates, hack = 0) {
  DateMid <- as.Date(format(df$Date, "%Y%m15"),
                              "%Y%m%d") + hack
  vec <- c(DateMid[1], dates, DateMid[length(DateMid)] + 1000)
  as.numeric(as.factor(cut(DateMid, vec)))
}

#Get rid of the full name of the states (eg: Veracruz de
#Ignacio de la Llave changes to Veracruz
cleanNames <- function(df, varname = "County"){
  df[[varname]] <- gsub("* de .*","", df[[varname]])
  df[[varname]]
}

monthSeq <- function(st, len){
  #start <- as.Date(st)
  #next.mon <- seq(start, length = len, by='1 month')
  #next.mon - 1
  seq(as.Date(st), length = len, by='1 month')
}

monthlyPop <- function() {
  pop <- read.csv("conapo-pop-estimates/conapo-states.csv")
  pop2 <- data.frame(year = rep(1990:2008, each = 12),
                   month = rep(1:12))
  pop2$Monthly.Pop[pop2$month == 6] <- unlist(pop[33,2:ncol(pop)])
  pop2$Monthly <- na.spline(pop2$Monthly.Pop, na.rm=FALSE)
  pop2
}

addHom <- function(df, pop) {
  hom.st <- ddply(df, .(Month.of.Murder, Year.of.Murder),
                 function(df) sum(df$Total.Murders))
  hom.st <- hom.st[order(hom.st$Year.of.Murder,
                         hom.st$Month.of.Murder),]
  pop$murders <- hom.st$V1
  pop$rate <- (pop$murders / pop$Monthly) * 100000 * 12
  start <- as.Date("1990/01/15")
  next.mon <- seq(start, length = 12*19, by='1 month')
  period <- next.mon - 1
  pop$date <- period
  pop
}

addTrend <- function(df){
  hom.ts <- ts(df$rate, start=1990, freq = 12)
  hom.stl <- stl(hom.ts, "per")
  cbind(df, data.frame(hom.stl$time.series))
}

cleanHom <-  function(df) {
  df <- subset(df, Code  == "#NAME?" &
              Year.of.Murder != "Total" &
              Year.of.Murder != "No especificado" &
              Month.of.Murder != "Total" &
              Month.of.Murder != "No especificado" &
              County != "Extranjero"
               )
  df$Year.of.Murder <- as.numeric(gsub('[[:alpha:]]', '',
                                        df$Year.of.Murder))
  df <- subset(df, Year.of.Murder >= 1990)
  col2cvt <- 5:ncol(df)
  df[is.na(df)] <- 0
  df$Total.Murders <- apply(df[ , col2cvt], 1, sum)
  df$Month.of.Murder <- factor(df$Month.of.Murder)
  #The months are in a weird order, so 04=Abril, etc.
  levels(df$Month.of.Murder) <- c("04","08","12","01","02","07","06","03","05","11","10","09")
  df
}

addMonths <- function(df){
  states <- unique(factor(df$County))
  start <- as.Date("1990/1/15")
  next.mon <- seq(start, length=12*19, by='1 month')
  period <- next.mon
  dates.df <- data.frame(Date = factor(rep(period,
                                    each = 32)),
                         County = states)
  dates <- strptime(as.character(dates.df$Date), "%Y-%m-%d")
  dates.df$Month.of.Murder <- dates$mon + 1
  dates.df$Year.of.Murder <- dates$year + 1900
  df$Month.of.Murder <- as.numeric(as.character(df$Month.of.Murder))
  df <- merge(dates.df, df,
                   by = c("Month.of.Murder",
                          "Year.of.Murder", "County"),
                   all.x = TRUE)
  df[is.na(df)] <- 0
  df
}
