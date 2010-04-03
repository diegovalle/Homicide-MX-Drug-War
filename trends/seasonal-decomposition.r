########################################################
#####       Author: Diego Valle Jones
#####       Website: www.diegovalle.net
#####       Date Created: Sun Mar 28 11:14:38 2010
########################################################
#season and trend decomposition of the monthly murder rates in Mexico

source("library/utilities.r")
source("timelines/constants.r")


plotTrend <- function(df){
  start.dw <- op.mich
  end.dw <- as.Date("2008-12-31")
  print(ggplot(df, aes(as.Date(date), rate)) +
    geom_rect(xmin = as.numeric(start.dw), xmax = as.numeric(end.dw),
              ymin=0, ymax=Inf, alpha = .01, fill = "red") +
    geom_line(color = "gray70") +
    geom_line(aes(as.Date(date), trend), color = "blue", size = 1.2) +
    scale_x_date() +
    xlab("") + ylab("Annualized Homicide Rate") +
    opts(title = "Monthly Homicide Rate and Trend") +
    annotate("text", x = as.numeric(start.dw), y = 16.9,
             label = "Drug\nWar", hjust =-.2))
}

plotSeasonal <- function(df){
  months <- factor(format(as.Date(df$date), "%b"))[1:12]
  print(ggplot(df[1:12,], aes(1:12, seasonal), group = 1) +
    geom_line() +
    scale_x_continuous(breaks = 1:12,
                       labels = months) +
    xlab("") +
    opts(title = "Seasonal Component of the Homicide Rate") +
    geom_hline(yintercept=0, color = "gray70"))
}

hom <- read.csv(bzfile("timelines/data/county-month-gue-oax.csv.bz2"))
hom <- cleanHom(hom)
hom <- addMonths(hom)


#No record of the 12 decapitaded bodies found in Yucatan
#http://www.eluniversal.com.mx/nacion/161981.html
hom[4863,]
#What about the 45 killed in Acteal? Unless they were the only ones
#killed that month I doubt they were recorded
hom[c(6309,6917, 261),]
#What's up with February 2008?
hom[1215,]

#I can't see any clearcut paterns at the state level
ggplot(hom, aes(y = Total.Murders, x = Month.of.Murder,
                group = Year.of.Murder, color = Year.of.Murder)) +
    geom_line() +
    facet_wrap(~ County, scales = "free_y")

#Now I can see them
print(ggplot(hom, aes(as.Date(Date), Total.Murders)) +
    geom_line() +
    scale_x_date() +
    facet_wrap(~ County, scales = "free_y"))
dev.print(png, "trends/output/st-murders.png", width = 960, height = 600)

#STL decomposition with loess
pop <- monthlyPop()
homrate <- addHom(hom, pop)
homrate <- addTrend(homrate)

Cairo(file = "trends/output/trend.png")
plotTrend(homrate)
dev.off()

plotSeasonal(homrate)
dev.print(png, "trends/output/seasonal.png", width = 450, height = 300)

plotReg(homrate)
dev.print(png, "trends/output/regression.png", width = 450, height = 300)



########################################################
#Bunch of crappy tests
########################################################
#See if the residuals are normal
hom.ts <- ts(homrate$rate, start=1990, freq = 12)
plot(stl(hom.ts, "per"))
dhom <- diff(hom.ts)
plot(dhom)
shapiro.test(dhom)
hist(dhom)
#12 month lag
lag.plot(dhom, 40)


#Arima
#fit.ar <- arima(hom.ts,order=c(1,1,1))
#tsdiag(fit.ar)
#Box.test(fit.ar$residuals)
#plot(hom.ts, xlim=c(1990,2010), ylim=c(5,19), type = "l")
#hom.pred <- predict(fit.ar, n.ahead = 12)
#lines(hom.pred$pred, col="red")
#lines(hom.pred$pred + 2 * hom.pred$se, col="red", lty=3)
#lines(hom.pred$pred - 2 * hom.pred$se, col="red", lty=3)

