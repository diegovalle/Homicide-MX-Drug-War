########################################################
#####       Author: Diego Valle Jones
#####       Website: www.diegovalle.net
#####       Date Created: Sat Feb 20 16:16:23 2010
########################################################
#Check to see if the homicide data was manipulated with
#1. Benford's law
#2. Variance

library(ggplot2)
library(boot)

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
  start <- as.Date("1990/2/01")
  next.mon <- seq(start, length=12*19, by='1 month')
  period <- next.mon - 1
  dates.df <- data.frame(Date = factor(rep(period,
                                    each = 32)),
                         County = states)
  dates <- strptime(as.character(dates.df$Date), "%Y-%m-%d")
  dates.df$Month.of.Murder <- dates$mon + 1
  dates.df$Year.of.Murder <- dates$year + 1900
  df$Month.of.Murder <- as.numeric(df$Month.of.Murder)
  df <- merge(dates.df, df,
                   by = c("Month.of.Murder",
                          "Year.of.Murder", "County"),
                   all.x = TRUE)
  df[is.na(df)] <- 0
  df
}



########################################################
#Read and clean the data
########################################################
hom <- read.csv(bzfile("../county-month/data/county-month-gue-oax.csv.bz2"))
hom <- cleanHom(hom)
hom <- addMonths(hom)

#No monthly homicide patterns
ggplot(hom, aes(y = Total.Murders, x = Month.of.Murder,
                group = Year.of.Murder, color = Year.of.Murder)) +
    geom_line() +
    facet_wrap(~ County, scales = "free_y")





########################################################
#See if the first digits of the monthly number of homicides
#follow a Benford distribution
########################################################
dBen <- function(x){
    log(1 + 1/x) / log(10)
}

firstDigit <- function(x){
    x <- as.numeric(substring(x, 1, 1))
}

benObsExp <- function(x, name =""){
    n <- length(x)
    x <- firstDigit(x)
    obs.freq <- tabulate(x, nbins = 9)
    obs.freq <- obs.freq / sum(obs.freq)
    ben.freq <- dBen(1:9)
    df <- data.frame(obs = obs.freq, ben = ben.freq, digits = 1:9)
    ggplot(df, aes(digits, ben)) + geom_line() +
        geom_point(aes(digits, obs), color = "red") +
        opts(title = name) + ylab("") +
        scale_y_continuous(formatter = "percent")
}

chiBen <- function(x) {
    n <- length(x)
    x <- firstDigit(x)
    obs.freq <- tabulate(x, nbins = 9)
    chisq.test(obs.freq, p = dBen(1:9))
}

#The original data from Benford's paper
#http://mathworld.wolfram.com/BenfordsLaw.html
death.rate <-  (c(27.0,18.6,15.7,9.4,6.7,6.5,7.2,4.8,4.1)/100) * 418
chisq.test(death.rate, p = dBen(1:9))

#For the vital statistics data
#Benford's law is scale invariant
inegi <- hom$Total.Murders
benObsExp(inegi, "INEGI")
ggsave("output/INEGI.png", dpi=90)
chiBen(inegi)

#For the police data
icesi <- melt(read.csv("../INEGIvsICESI/data/states-icesi.csv"),
           id ="State")
benObsExp(icesi$value, "ICESI")
ggsave("output/ICESI.png", dpi=90)
chiBen(icesi$value)


#Mean absolute deviation

#INEGI
y <- tabulate(firstDigit(inegi), nbins=9)
sum(abs((dBen(1:9)) - y / sum(y)))*100
#ICESI
y <- tabulate(firstDigit(icesi$value), nbins=9)
sum(abs((dBen(1:9)) - y / sum(y)))*100


#Some regressions to see the size of the difference

#Null hypothesis
summary(lm(log(dBen(1:9))~ c(1:9)))
#INEGI
y <- tabulate(firstDigit(inegi), nbins=9)
summary(lm(log(y)~c(1:9)))
#ICESI
y <- tabulate(firstDigit(icesi$value), nbins=9)
summary(lm(log(y)~c(1:9)))

#check if the last digit follows a uniform distribution
#Is this even reasonable? I don't think so
lastDigit <- function(v){
 	v - 10*floor(v/10)
}
chi.uni <- function(x) {
  v <- table(lastDigit(x))
  chisq.test(as.vector(v), p = rep(1/10, 10))
}

chi.uni(inegi)
chi.uni(icesi$value)
plot(as.vector(table(lastDigit(icesi$value))))