########################################################
#####       Author: Diego Valle Jones
#####       Website: www.diegovalle.net
#####       Date Created: Wed Feb 17 19:25:40 2010
########################################################
#Small multiples plot to compare the INEGI and ICESI data

source("library/utilities.r")

icesi <- read.csv("INEGIvsSNSP/data/states-icesi.csv")
inegi <- read.csv("accidents-homicides-suicides/output/states.csv")

icesi <- melt(icesi, id = "State")
icesi$org <- "SNSP"

#Remove the years 1990:1996
inegi <- inegi[,-(2:8)]
inegi <- melt(inegi, id = "State")
inegi$org <- "INEGI"

ii <- rbind(inegi, icesi)
ii$variable <- rep(1997:2008, each=32)
ii$State <- cleanNames(ii, "State")

#Population of Mexico 1997-2008
#source: CONAPO
pop <- read.csv("conapo-pop-estimates/conapo-states.csv")
pop <- pop[-(33) ,-(2:8)]
pop <- melt(pop, id = "State")
pop$variable <- rep(1997:2008, each=32)
pop <- pop[order(pop$State),]
pop$State <- cleanNames(pop, "State")
ii.pop <- merge(ii, pop, by = c("State", "variable"), all.x = TRUE)
ii.pop$rate <- ii.pop$value.x / ii.pop$value.y * 100000

variat <- function(df){
  ine <- subset(df, org == "INEGI")
  sns <- subset(df, org == "SNSP")
  var(ine$rate - sns$rate)
}
ii.pop <- merge(ii.pop, ddply(ii.pop, .(State), variat), by = "State")
ii.pop$State <- with(ii.pop, reorder(factor(State), -V1))
print(ggplot(ii.pop, aes(variable, rate, group = org, color = org)) +
    geom_line(size = 2) +
    facet_wrap(~ State, scales = "free_y"))
dev.print(png, file = "INEGIvsSNSP/output/INEGI-SNSP.png", width = 960, height = 600)



dif <- cast(ii.pop[order(ii.pop$org),], State ~ variable,
            value = "rate",
            fun.aggregate = function(x) x[1] - x[2])
difm <- melt(dif, id=c("State"))
difm <- ddply(difm, .(State), transform, var = var(value))
difm$State <- reorder(factor(difm$State), -difm$var)
print(ggplot(difm, aes(as.numeric(as.character(variable)), value)) +
    geom_line(size = 1.2, color = "darkred") +
    facet_wrap(~ State) +
    geom_hline(yintercept = 0, color = "gray40") +
    opts(title = "Differences in homicide rates (INEGI - SNSP)") +
    xlab("Year") + ylab("Difference in Homicide Rate") +
    scale_x_continuous(breaks = c(1998, 2003, 2008),
                         labels = c("98", "03", "08")) +
    #scale_y_continuous(formatter="percent") +
    theme_bw())
dev.print(png, file = "INEGIvsSNSP/output/INEGI-SNSP-dif.png", width = 960, height = 600)
