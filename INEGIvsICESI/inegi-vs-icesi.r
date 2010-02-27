########################################################
#####       Author: Diego Valle Jones
#####       Website: www.diegovalle.net
#####       Date Created: Wed Feb 17 19:25:40 2010
########################################################
#Small multiples plot to compare the INEGI and ICESI data

library(ggplot2)
icesi <- read.csv("data/states-icesi.csv")
inegi <- read.csv("../accidents-homicides-suicides/output/states.csv")

icesi <- melt(icesi, id = "State")
icesi$org <- "ICESI"

#Remove the years 1990:1996
inegi <- inegi[,-(2:8)]
inegi <- melt(inegi, id = "State")
inegi$org <- "INEGI"

ii <- rbind(inegi, icesi)
ii$variable <- rep(1997:2008, each=32)

#Population of Mexico 1997-2008
#source: CONAPO
pop <- read.csv("../conapo-pop-estimates/conapo-states.csv")
pop <- pop[-(33) ,-(2:8)]
pop <- melt(pop, id = "State")
pop$variable <- rep(1997:2008, each=32)
pop <- pop[order(pop$State),]

ii.pop <- merge(ii, pop, by = c("State", "variable"), all.x = TRUE)

ii.pop$rate <- ii.pop$value.x / ii.pop$value.y * 100000

ggplot(ii.pop, aes(variable, rate, group = org, color = org)) +
    geom_line(size = 2) +
    facet_wrap(~ State, scales = "free_y")

dev.print(png, file = "output/INEGI-ICESI.png", width = 960, height = 600)

