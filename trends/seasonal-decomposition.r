########################################################
#####       Author: Diego Valle Jones
#####       Website: www.diegovalle.net
#####       Date Created: Sun Mar 28 11:14:38 2010
########################################################
#season and trend decomposition of the monthly murder rates in Mexico

source("library/utilities.r")
source("timelines/constants.r")

plotReg <- function(df){
  hom.ts <- ts(df$rate, start=1990, freq = 12)
  trend = time(hom.ts)
  ndays <- strptime(df$date, format = "%Y-%m-%d")$mday
  reg <- glm(rate ~ trend + factor(month) + ndays, data = df)
  reg2 <- glm(rate ~ trend + factor(year) + factor(month) +
            ndays, data = df)
  reg3 <- glm(rate ~ trend + ndays, data = df)
  print(anova(reg, reg2))
  print(summary(reg))
  print(summary(reg2))
  print(summary(reg3))
  df$fitted <- unlist(reg$fitted.values)
  df$fitted <- fitted(reg)
  print(ggplot(df, aes(as.Date(date), rate)) +
      geom_line() +
      geom_line(aes(as.Date(date), fitted,
                    legend = FALSE), color = "blue") +
      scale_x_date(major ="year") +
      opts(title = reg$call))
}

plotTrend <- function(df, ban){
  start.dw <- op.mich
  end.dw <- as.Date("2008-12-31")
  print(ggplot(df, aes(as.Date(date), rate)) +
    #geom_rect(xmin = as.numeric(start.dw), xmax = as.numeric(end.dw),
    #          ymin=0, ymax=Inf, alpha = .01, fill = "pink") +
    geom_line(color = "gray70") +
    geom_line(aes(as.Date(date), trend), color = "blue", size = 1) +
    geom_vline(aes(xintercept = as.Date("2004-09-13")), color = "gray",
               linetype = 2) +
    scale_x_date() +
    xlab("") + ylab("Annualized Homicide Rate") +
    opts(title = "Monthly Homicide Rate and Trend (the Gray Line is the Assault Weapon Ban Expiration Date)") +
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
#hom <- subset(hom, Year.of.Murder >= 1994)


#I can't see any clearcut paterns at the state level
ggplot(hom, aes(y = Total.Murders, x = Month.of.Murder,
                group = Year.of.Murder, color = Year.of.Murder)) +
    geom_line() +
    facet_wrap(~ County, scales = "free_y")

#Now I can see them
print(ggplot(hom, aes(as.Date(Date), Total.Murders)) +
    geom_line() +
    scale_x_date() +
    facet_wrap(~ County, scales = "free_y") +
    opts(title = "Monthly Number of Homicides"))
dev.print(png, "trends/output/st-murders.png", width = 960, height = 600)

#Now only since the start of the Drug War
print(ggplot(subset(hom, as.Date(Date) >= as.Date("2006/12/01")),
             aes(as.Date(Date), Total.Murders)) +
    geom_line() +
    scale_x_date() +
    facet_wrap(~ County, scales = "free_y")+
    opts(title = "Monthly Number of Homicides Since the Start of the Drug War"))
dev.print(png, "trends/output/st-drug-war-murders.png", width = 960, height = 600)

#Let's see what Chiapas looked like during the 95 Acteal massacre
print(ggplot(subset(hom, as.Date(Date) <= as.Date("1998/06/01") &
                    as.Date(Date) >= as.Date("1997/01/01") &
                    County == "Chiapas"),
             aes(as.Date(Date), Total.Murders)) +
    geom_line() +
    scale_x_date() +
    facet_wrap(~ County, scales = "free_y")+
    opts(title = "Monthly Number of Homicides Since the Start of the Drug War"))


#STL decomposition with loess
pop <- monthlyPop()
homrate <- addHom(hom, pop)
homrate <- addTrend(homrate)
homrate <-  subset(homrate, year >= 1994)

plotReg(homrate)
dev.print(png, "trends/output/regression.png", width = 800,
          height = 600)

Cairo(file = "trends/output/trend.png", width = 960, height=600)
plotTrend(homrate)
dev.off()

plotSeasonal(homrate)
dev.print(png, "trends/output/seasonal.png", width = 450, height = 300)





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

