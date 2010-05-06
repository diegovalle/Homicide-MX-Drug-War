########################################################
#####       Author: Diego Valle Jones
#####       Website: www.diegovalle.net
#####       Date Created: Sat Feb 20 16:16:23 2010
########################################################
#Check to see if the homicide data was manipulated with
#1. Benford's law

source("library/utilities.r")

########################################################
#Read and clean the data
########################################################
hom <- read.csv(bzfile("timelines/data/county-month-gue-oax.csv.bz2"))
hom <- cleanHom(hom)
hom <- addMonths(hom)
hom <- subset(hom, Year.of.Murder >= 1994)

########################################################
#See if the first digits of the monthly number of homicides
#follow a Benford distribution
########################################################
dBen <- function(x){
    log(1 + 1/x) / log(10)
}

firstDigit <- function(x){
    x <- as.numeric(substring(formatC(x, format = 'e'), 1, 1))
}

benObsExp <- function(x, name =""){
    n <- length(x)
    x <- firstDigit(x)
    obs.freq <- tabulate(x, nbins = 9)
    obs.freq <- obs.freq / sum(obs.freq)
    ben.freq <- dBen(1:9)
    name <- paste(name, "homicide data (red) vs. Benford's law (black)")
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
print(benObsExp(inegi, "INEGI"))
ggsave("Benford/output/INEGI.png", dpi=72, width = 6, height = 6)
chiBen(inegi)

#For the police data
icesi <- melt(read.csv("INEGIvsSNSP/data/states-icesi.csv"),
           id ="State")
print(benObsExp(icesi$value, "SNSP"))
ggsave("Benford/output/ICESI.png", dpi=72, width = 6, height = 6)
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
y <- dBen(1:9)
fitBen <- lm(log(y) ~ c(1:9))
#INEGI
y1 <- tabulate(firstDigit(inegi), nbins=9)
fitInegi <- lm(log(y) ~ c(1:9))
#ICESI
y2 <- tabulate(firstDigit(icesi$value), nbins=9)
fitIcesi <- lm(log(y) ~ c(1:9))

anova(fitInegi, fitBen)
anova(fitIcesi, fitBen)


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
