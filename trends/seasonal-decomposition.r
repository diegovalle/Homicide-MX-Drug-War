########################################################
#####       Author: Diego Valle Jones
#####       Website: www.diegovalle.net
#####       Date Created: Sun Mar 28 11:14:38 2010
########################################################
#season and trend decomposition of the monthly murder rates in Mexico

source("library/utilities.r")
source("timelines/constants.r")

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
  start <- as.Date("1990/2/01")
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

#a decomposition with linear regression
plotReg <- function(df){
  hom.ts <- ts(df$rate, start=1990, freq = 12)
  trend = time(hom.ts)
  ndays <- strptime(df$date, format = "%Y-%m-%d")$mday
  reg <- lm(rate ~ 0 + trend + factor(year) + factor(month) +
            ndays, data = df)
  summary(reg)
  df$fitted <- unlist(reg$fitted.values)
  df$fitted <- fitted(reg)
  print(ggplot(df, aes(as.Date(date), rate)) +
      geom_line() +
      geom_line(aes(as.Date(date), fitted,
                    legend = FALSE), color = "blue") +
      scale_x_date(major ="year") +
      opts(title = reg$call))
}


hom <- read.csv(bzfile("timelines/data/county-month-gue-oax.csv.bz2"))
hom <- cleanHom(hom)
hom <- addMonths(hom)

#I can't see any clearcut paterns at the state level
ggplot(hom, aes(y = Total.Murders, x = Month.of.Murder,
                group = Year.of.Murder, color = Year.of.Murder)) +
    geom_line() +
    facet_wrap(~ County, scales = "free_y")

#Now I can see them
ggplot(hom, aes(as.Date(Date), Total.Murders)) +
    geom_line() +
    scale_x_date() +
    facet_wrap(~ County, scales = "free_y")

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
#How are homicides and executions related?
#What will the homicide rate be in 2009 and 2010
########################################################
#The murder rate started rising after may 2007
h2007 <- homrate[210:227,]
exe <- read.csv("trends/data/executions.csv")
hexe <- merge(h2007, exe, by.x=c("year", "month"),
      by.y=c("Year", "Month"))
hexe <- hexe[order(hexe$year, hexe$month),]
hexe$tmon <- paste(factor(format(as.Date(hexe$date), "%b")), hexe$year)
reg <- lm(murders ~ Executions, data = hexe)
print(ggplot(hexe, aes(Executions, murders, label = tmon)) +
    geom_text() +
    stat_smooth(method = lm))
dev.print(png, "trends/output/exe-hom.png", width = 450, height = 300)
e2009 <- subset(exe, Year == 2009)
#Reforma is missing 1600 executions, mainly in Chihuahua. Based on this
#I'm assuming that the newspaper missed 150 executions on average each
#month
pre09 <- data.frame(predict(reg, data.frame(Executions =
                                          e2009$Executions + 150),
                   interval = "confidence"))
murderRate <- function(vec, pop = 107550697){
    (sum(vec)) / pop * 100000
}
sapply(pre09, murderRate)

#The prediction for 2010, arrggh, so far in January in and February
#there have been 150 more executions on average than last year
pre10 <- data.frame(predict(reg, data.frame(Executions =
                                          e2009$Executions + 180 + 150),
                   interval = "confidence"))
sapply(pre10, murderRate, 108396211)


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


#A regression
M <- factor(rep(1:12, 19))
Y <- factor(rep(1990:2008, each = 12))
trend = time(hom.ts)
reg = lm(hom.ts ~ 0 + trend + M + Y, na.action=NULL)
summary(reg)
plot(hom.ts, type="l", lty="dashed")
lines(fitted(reg), col=2)

#Arima
fit.ar <- arima(hom.ts,order=c(1,1,1))
tsdiag(fit.ar)
Box.test(fit.ar$residuals)
plot(hom.ts, xlim=c(1990,2010), ylim=c(5,19), type = "l")
hom.pred <- predict(fit.ar, n.ahead = 12)
lines(hom.pred$pred, col="red")
lines(hom.pred$pred + 2 * hom.pred$se, col="red", lty=3)
lines(hom.pred$pred - 2 * hom.pred$se, col="red", lty=3)

