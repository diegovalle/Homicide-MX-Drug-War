########################################################
#####       Author: Diego Valle Jones
#####       Website: www.diegovalle.net
#####       Date Created: Fri Apr 02 20:35:30 2010
########################################################
#What will the homicide rate be in 2009 and 2010

source("library/utilities.r")



saveplotRegM <- function(hexe){
  print(ggplot(hexe, aes(Executions, murders, label = tmon)) +
      geom_text(hjust=-.1) +
      geom_point() +
      stat_smooth(method = lm))
  dev.print(png, "predictions/output/exe-hom.png",
            width = 450, height = 300)
}

regM <- function(df, executions, saveplot = FALSE){
  #The murder rate for january and february was low cause it was low
  #in Mexico City, which isn't beset by the drug war, so we exlude it.
  #Alos exclude December 2008 because it will be off by 25% or so
  h07.08 <- df[208:227,]

  #The data for november looks wrong, so I'm using the average
  #exe[35, "Milenio"] <- (exe[34, "Milenio"] + exe[36, "Milenio"])/2
  hexe <- merge(h07.08, executions, by.x=c("year", "month"),
        by.y=c("Year", "Month"))
  hexe <- hexe[order(hexe$year, hexe$month),]
  hexe$tmon <- paste(factor(format(as.Date(hexe$date), "%b")),
                     hexe$year)
  reg <- lm(murders ~ Executions, data = hexe)
  print(summary(reg))
  if(saveplot == TRUE) saveplotRegM(hexe)
  reg
}

murderRate <- function(vec, pop = 107550697){
    (sum(vec)) / pop * 100000
}

predict09 <- function(reg) {
  e2009 <- subset(exe, Year == 2009)

  pre09 <- data.frame(predict(reg,
                              data.frame(Executions =
                                         e2009$Executions),
                              interval = "confidence"))
  res <- sapply(pre09, murderRate)
  res
}



predictChart <- function(exe, homrate) {
  pre10 <- data.frame(predict(reg,
                              data.frame(Executions =
                                         exe$Executions[25:39]),
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
  df$rate <- df$Executions / df$pop * 100000 * 12
  df
}


homRate2010 <- function(pre10, homrate){
  rate08.09 <- data.frame(rate =
                             c(homrate$rate[214:228], pre10$fit[1:15]),
                          date = 1:30)
  reg10 <- lm(rate ~ date, data = rate08.09)
  x <- predict(reg10, data.frame(date = 25:36),
               interval = "confidence")
  pre10[13:14,1:3]
  all10 <- rbind(x[3:12,], pre10[13:14,1:3])
  apply(all10,2,mean)
}

plotHomEx <- function(pre10, exe, homrate) {
  label09 <- paste("homicide rate\nin 2009 ~",round(k2009.rate[[1]],1))
  label10 <- paste("homicide rate\nin 2010 ~",round(k2010.rate[[1]],1))
  ggplot(pre10, aes(as.Date(date), fit)) +
    scale_x_date() +
    geom_line(linetype = 2, color = "darkred") +
    geom_line(data = homrate[204:228,], aes(as.Date(date), rate),
              color = "darkred") +
    geom_ribbon(aes(ymax = upr, ymin = lwr), alpha = .2,
                fill ="darkred") +
    xlab("") + ylab("Annualized Homicide Rate") +
    annotate("text", x = as.numeric(as.Date("2007-07-01")), y = 27,
             label = "homicide rate\nin 2007 = 8.3") +
    annotate("text", x = as.numeric(as.Date("2008-07-01")), y = 27,
             label = "homicide rate\nin 2008 = 12.8") +
    annotate("text", x = as.numeric(as.Date("2009-07-01")), y = 27,
             label = label09) +
    annotate("text", x = as.numeric(as.Date("2010-05-15")), y = 27,
             label = label10) +
    annotate("text", x = as.numeric(as.Date("2010-04-15")), y = 22.5,
             label = "homicide\nrate", hjust =0, color = "darkred") +
    annotate("text", x = as.numeric(as.Date("2010-04-15")), y = 12,
             label = "execution\nrate", hjust =0, color ="darkgreen") +
    geom_line(data = exe, aes(as.Date(date), rate), color = "darkgreen") +
    scale_x_date(limits = c(as.Date("2006-11-01"),
                     as.Date("2010-08-01"))) +
    scale_y_continuous(limits = c(1.5, 28)) +
    opts(title = "Monthly Homicide and Execution Rates")
}

savePlot <- function(p) {
  Cairo(file = "predictions/output/estimate.png", w = 640, h = 480)
  print(p)
  dev.off()
}


#Let's explore the differences in executions reported by the
#newpapers Milenio and Reforma
exe.st <- read.csv("predictions/data/executions-bystate.csv")
exe.st$Universal <- NULL
exe.st <- melt(exe.st, id = "State")
exe.st$State <- with(exe.st,reorder(State, value))
print(ggplot(exe.st, aes(value, State, group = variable,
                         color = variable, shape = variable)) +
    geom_point() +
    opts(title = "Differences in Reported Number of Executions in 2009"))
dev.print(png, "predictions/output/diff-execut2009.png",
            width = 500, height = 600)

#Prepare the data
hom <- read.csv(bzfile("timelines/data/county-month-gue-oax.csv.bz2"))
hom <- cleanHom(hom)
hom <- addMonths(hom)
pop <- monthlyPop()
homrate <- addHom(hom, pop)
homrate <- addTrend(homrate)

#The predictions
exe <- read.csv("predictions/data/executions-bymonth.csv")
exe$diff <- exe$Reforma - exe$Milenio
#I couldn't find the data for March so here's and estimated
exe$Reforma[39] <- exe$Milenio[39] + mean(exe$diff[32:38])
exe$Executions <- (exe$Reforma + exe$Milenio) /2

reg <- regM(homrate, exe, saveplot = TRUE)
#plot(reg)
durbin.watson(reg)
adf.test(residuals(reg))

k2009.rate <- predict09(reg)
print(round(k2009.rate,1))
pre10 <- predictChart(exe, homrate)
k2010.rate <- homRate2010(pre10, homrate)
print(round(k2010.rate,1))
exe <- exeRate(exe, c(homrate$Monthly[205:228], pre10$pop[1:15]))

savePlot(plotHomEx(pre10, exe, homrate))








