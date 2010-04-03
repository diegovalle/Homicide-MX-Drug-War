########################################################
#####       Author: Diego Valle Jones
#####       Website: www.diegovalle.net
#####       Date Created: Fri Apr 02 20:35:30 2010
########################################################
#What will the homicide rate be in 2009 and 2010

source("library/utilities.r")

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

plotRegM <- function(hexe){
  print(ggplot(hexe, aes(Milenio, murders, label = tmon)) +
      geom_text() +
      stat_smooth(method = lm))
  dev.print(png, "trends/output/exe-hom.png",
            width = 450, height = 300)
}

regM <- function(df, executions){
  #The murder rate started rising after may 2007. Exclude December 2008
  #because it's not complete
  h07.08 <- df[210:227,]

  #The data for november looks wrong, so I'm using the average
  #exe[35, "Milenio"] <- (exe[34, "Milenio"] + exe[36, "Milenio"])/2
  hexe <- merge(h07.08, executions, by.x=c("year", "month"),
        by.y=c("Year", "Month"))
  hexe <- hexe[order(hexe$year, hexe$month),]
  hexe$tmon <- paste(factor(format(as.Date(hexe$date), "%b")),
                     hexe$year)
  reg <- lm(murders ~ Milenio, data = hexe)
  print(summary(reg))
  plotRegM(hexe)
  reg
}

murderRate <- function(vec, pop = 107550697){
    (sum(vec)) / pop * 100000
}

predict09 <- function(reg) {
  e2009 <- subset(exe, Year == 2009)

  pre09 <- data.frame(predict(reg,
                              data.frame(Milenio = e2009$Milenio),
                              interval = "confidence"))
  res <- sapply(pre09, murderRate)
  res
}



predictChart <- function(exe, homrate) {
  pre10 <- data.frame(predict(reg,
                              data.frame(Milenio = exe$Milenio[25:39]),
                              interval = "confidence"))
  pre10$date <- monthSeq("2009/2/01", 15)

  pop <- c(homrate$Monthly.Pop, rep(NA,11),
           107550697, rep(NA,11), 108396211)

  pre10$pop <- na.spline(pop, na.rm=FALSE)[235:249]
  pre10 <- rbind(pre10, data.frame(fit = homrate[228, "murders"],
                   lwr = homrate[228, "murders"],
                   upr = homrate[228, "murders"],
                   date = homrate[228, "date"],
                   pop = homrate[228, "Monthly"]))
  pre10[1:3] <- sapply(pre10[1:3],
                       function(x) x / pre10$pop * 100000 * 12)
  pre10
}

exeRate <- function(df, population){
  df$date <- monthSeq("2007/2/01", 39)
  df$pop <- population
  df$rate <- df$Milenio / df$pop * 100000 * 12
  df
}

homRate2010 <- function(pre10) {
  reg10 <- lm(pre10$fit[1:15] ~ time(pre10$date[1:15]))
  summary(reg10)
  (sum(12.36 + .4 * 16:24) + sum(pre10$fit[13:15])) / 12
  #predict(reg10, data.frame(17:32))
}

plotHomEx <- function(pre10, exe, homrate) {
  ggplot(pre10, aes(as.Date(date), fit)) +
    scale_x_date() +
    geom_line(linetype = 2, color = "darkred") +
    geom_line(data = homrate[204:228,], aes(as.Date(date), rate),
              color = "darkred") +
    geom_ribbon(aes(ymax = upr, ymin = lwr), alpha = .2,
                fill ="darkred") +
    xlab("") + ylab("Annualized Homicide Rate") +
    annotate("text", x = as.numeric(as.Date("2007-02-15")), y = 24,
             label = "rate in 2007\n        8.3", hjust =-.2) +
    annotate("text", x = as.numeric(as.Date("2008-02-15")), y = 24,
             label = "rate in 2008\n        12.8", hjust =-.2) +
    annotate("text", x = as.numeric(as.Date("2009-02-15")), y = 24,
             label = "rate in 2009\n        15", hjust =-.2) +
    annotate("text", x = as.numeric(as.Date("2010-01-15")), y = 24,
             label = "rate in 2010\n     19.8?", hjust =-.2) +
    annotate("text", x = as.numeric(as.Date("2010-04-15")), y = 20,
             label = "homicide\nrate", hjust =0, color = "darkred") +
    annotate("text", x = as.numeric(as.Date("2010-04-15")), y = 12.5,
             label = "execution\nrate", hjust =0, color ="darkgreen") +
    geom_line(data = exe, aes(as.Date(date), rate), color = "darkgreen") +
    scale_x_date(limits = c(as.Date("2006-11-01"),
                     as.Date("2010-08-01"))) +
    opts(title = "Monthly Homicide and Execution Rates")
}

savePlot <- function(p) {
  Cairo(file = "predictions/output/estimate.png", w = 640, h = 480)
  print(p)
  dev.off()
}

#Prepare the data
hom <- read.csv(bzfile("timelines/data/county-month-gue-oax.csv.bz2"))
hom <- cleanHom(hom)
hom <- addMonths(hom)
pop <- monthlyPop()
homrate <- addHom(hom, pop)
homrate <- addTrend(homrate)

#The predictions
exe <- read.csv("predictions/data/executions.csv")
reg <- regM(homrate, exe)

k2009.rate <- predict09(reg)
k2009.rate
pre10 <- predictChart(exe, homrate)
exe <- exeRate(exe, c(homrate$Monthly[205:228], pre10$pop[1:15]))

savePlot(plotHomEx(pre10, exe, homrate))

homRate2010(pre10)
