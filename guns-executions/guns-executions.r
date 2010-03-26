########################################################
#####       Author: Diego Valle Jones
#####       Website: www.diegovalle.net
#####       Date Created: Wed Mar 24 11:44:12 2010
########################################################
#Compare the homicide rate with the execution rate and the homicide
#with firearm rate

source("library/utilities.r")

########################################################
#Homicides, Homicides with Firearm, and Executions
########################################################
homr <- read.csv("accidents-homicides-suicides/output/homicide.csv")
exe <- read.csv("guns-executions/data/firearm-executions.csv")
exe$Homicides <- c(homr$Tot[11:19], NA)
exer <- exe
exer[,c(2,3,5)] <- sapply(exer[,c(2,3,5)],
                         function(x) x / exer$Population * 100000)
mexer <- melt(exer[,c(1:3,5)], id = "Year")
mexer$variable <- factor(factor(mexer$variable),
                         levels = c("Homicides",
                                     "Executions",
                                     "Firearm.Homicides"))

p <- ggplot(mexer, aes(Year, value, group = variable,
                       color = variable)) +
    geom_line() + ylab("Rate") +
    opts(title = "")
mid.points <- dl.indep(data.frame(d[3,],hjust=-0.2,vjust=-0.5))
print(direct.label(p, mid.points))
dev.print(png, "guns-executions/output/homicides-executions.png",
          width = 500, height = 400)

#murder with firearm as a percentage of total homicides,
#the proportion of murders with firearm has risen mostly because it
#has decreased *more slowly* than the overall homicide rate
ggplot(exe, aes(Year, Firearm.Homicides / Homicides)) +
    geom_line() +
    scale_y_continuous(formatter = "percent")


############################################################
#Small Multiples of Homicide and Homicide with Firearm Rates
#############################################################
fir.state <- read.csv("guns-executions/data/firearm-hom-statetot.csv")
state <- read.csv("accidents-homicides-suicides/output/states.csv")
pop <- read.csv("conapo-pop-estimates/conapo-states.csv")

state <- merge(fir.state, state[,c(1,12:19)], by = "State")
state <- merge(state, pop[ ,c(1,12:19)], by = "State")

clmns <- 18:25
state[2:9] <- state[2:9] / state[,clmns] * 100000
state[10:17] <- state[10:17] / state[, clmns] *100000

mstate <- melt(state[,1:17], id ="State")
mstate$type <- factor(rep(c("Firearm\nHomicides", "Homicides"),
                          each = 31*8))
mstate$variable <- rep(2000:2007, each = 31)

mstate$type <- factor(mstate$type, levels = rev(levels(mstate$type)))
correl <- function(df){
    f <- subset(df, type == "Firearm\nHomicides")
    h <- subset(df, type == "Homicides")
    cor(f$value,h$value)[1]
    #summary(lm(f$value ~ h$value))$r.squared

}
mstate <- merge(mstate, ddply(mstate, .(State), correl), by = "State")
mstate$State <- cleanNames(mstate, "State")
mstate$State <- paste(mstate$State,"-", round(mstate$V1,2))
mstate$State <- with(mstate, reorder(factor(State), -V1))
scale_color <- scale_colour
print(ggplot(mstate, aes(variable, value,
                         color = type, group = type)) +
    geom_line() +
    facet_wrap(~ State, scales = "free_y") +
    ylab("Rate") + xlab("Year") +
    scale_x_continuous(breaks = c(2000, 2004, 2007),
                         labels = c("00","04", "07")) +
    opts(title = "Homicides and Homicides with Firearm, ordered by correlation"))
dev.print(png, "guns-executions/output/homicides-firearm-st.png",
          width = 960, height = 600)


#Guns traced to the US
#c(3090, 5260, 1950, 3060, 6700)
#2004:2008

#Total guns seized in Mexico
#30000  #hmmm, according to PGR it was 28,000 over two years
#Guns submitted for tracking
#7200
