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

#Average the data from Reforma and Milenio
exe$Executions[4:8] <- exe$Renglones[4:8]
exe$Executions[9] <- (exe$Reforma[9] + exe$Renglones[9]) / 2
exe$Executions[10:12] <- (exe$Reforma[10:12] + exe$Milenio[10:12]) / 2
exe <- exe[,1:4]

exe$Homicides <- c(homr$Tot[9:19], NA)
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
print(ggplot(exe, aes(Year, Firearm.Homicides / Homicides)) +
    geom_line() +
    scale_y_continuous(formatter = "percent"))
dev.print(png, "guns-executions/output/percent-by-firearm.png",
          width = 500, height = 400)



############################################################
#Small Multiples of Homicide and Homicide with Firearm Rates
#############################################################
fir.state <- read.csv("guns-executions/data/firearm-hom-statetot.csv")
state <- read.csv("accidents-homicides-suicides/output/states.csv")
pop <- read.csv("conapo-pop-estimates/conapo-states.csv")

state <- merge(fir.state, state[,c(1,10:20)], by = "State")
state <- merge(state, pop[ ,c(1,10:20)], by = "State")

popclmns <- 24:34
firclmns <- 2:12
homclmns <- 13:23
state[firclmns] <- state[firclmns] / state[, popclmns] * 100000
state[homclmns] <- state[homclmns] / state[, popclmns] *100000

mstate <- melt(state[,1:23], id ="State")
mstate$type <- factor(rep(c("Firearm\nHomicides", "Homicides"),
                          each = 32*11))
mstate$variable <- rep(1998:2008, each = 32)

mstate$type <- factor(mstate$type, levels = rev(levels(mstate$type)))

#Is the data cointegrated?
unitRoot <- function(df){
    f <- subset(df, type == "Firearm\nHomicides")$value
    h <- subset(df, type == "Homicides")$value
    reg <- lm(h ~ f)
    ht <- adf.test(residuals(reg))
    ht
}
#FFFFFFFFFFFFFFFCCCCCCCCC Chihuahua and Guerrero and Durango are coint
dlply(mstate, .(State), unitRoot)

#Simple error correction, with eight samples per state there's not much
#info
coint <- function(df){
    f <- subset(df, type == "Firearm\nHomicides")$value
    h <- subset(df, type == "Homicides")$value
    coint.res <- residuals(lm(h ~ f))
    coint.res <- coint.res[-c(7:8)]
    d_h <- diff(h)
    d_f <- diff(f)
    diff.dat <- data.frame(embed(cbind(d_h, d_f), 2))
    colnames(diff.dat) <- c("d_h", "d_f", "d_h.1", "d_f.1")
    reg <- lm(d_h ~ coint.res + d_h.1 + d_f.1, data = diff.dat)
    print(df$State)
    print(summary(reg))
    print(plot(coint.res), type = "l")
}
#Doesn't work :(
dlply(mstate, .(State), coint)

correl <- function(df){
    f <- subset(df, type == "Firearm\nHomicides")$value
    h <- subset(df, type == "Homicides")$value
    cor(f, h)[1]
}

#mstate <- merge(mstate, ddply(mstate, .(State), correl), by = "State")
mstate$State <- cleanNames(mstate, "State")
mstate <- subset(mstate, State %in% c("Chihuahua", "Sinaloa", "Durango", "Sonora", "Guerrero", "Baja California","Michoacán", "Tamaulipas"))
#mstate$State <- paste(mstate$State,"-", round(mstate$V1,2))

#mstate$State <- with(mstate, reorder(factor(State), dif))
scale_color <- scale_colour
print(ggplot(mstate, aes(variable, value,
                         color = type, group = type)) +
    geom_line() +
    facet_wrap(~ State, scales = "free_y") +
    ylab("Rate") + xlab("Year") +
    scale_x_continuous(breaks = c(2000, 2004, 2007),
                         labels = c("00","04", "07")) +
    opts(title = "Homicides and Homicides with Firearm"))
dev.print(png, "guns-executions/output/homicides-firearm-st.png",
          width = 600, height = 400)


###############################################################
##Now homicides committed with a firearm as a proportion of
#all homicides
##############################################################
pstate <- state[2:12] / state [13:23]
pstate$State <- state$State
mpstate <- melt(pstate, id = "State")
mpstate$variable <- rep(1998:2008, each = 32)
mpstate$State <- factor(cleanNames(mpstate, "State"))

mpstate <- ddply(mpstate, .(State), transform,
                 dif = value[5] - value[length(value)])

mpstate$State <- reorder(mpstate$State, mpstate$dif)
print(ggplot(mpstate, aes(variable, value)) +
    geom_line() +
    facet_wrap(~ State, scales = "free_y") +
    ylab("Proportion") + xlab("Year") +
    scale_x_continuous(breaks = c(2000, 2004, 2007),
                         labels = c("00","04", "07")) +
    scale_y_continuous(formatter = "percent") +
    stat_smooth(method = lm, se = FALSE) +
    opts(title = "Proportion of Homicides commited with a Firearm (ordered by difference in proportions from 2004 to 2007)"))
dev.print(png, "guns-executions/output/homicides-firearm-st-p2005.png",
          width = 960, height = 600)


mpstate <- subset(mpstate, State %in% c("Chihuahua", "Sinaloa", "Durango", "Sonora", "Guerrero", "Baja California","Michoacán", "Tamaulipas"))
m <- function(df){
    lm(df$variable ~ df$value)$coef[2]
}
mpstate <- merge(mpstate, ddply(mpstate, .(State), m),
                 by = c("State"))
mpstate$State <- reorder(mpstate$State, mpstate$"df$value")
print(ggplot(mpstate, aes(variable, value)) +
    geom_line() +
    facet_wrap(~ State, scales = "free_y") +
    ylab("Proportion") + xlab("Year") +
    scale_x_continuous(breaks = c(2000, 2004, 2007),
                         labels = c("00","04", "07")) +
    scale_y_continuous(formatter = "percent") +
    stat_smooth(method = lm, se = FALSE) +
    opts(title = "Proportion of Homicides commited with a Firearm"))
dev.print(png, "guns-executions/output/homicides-firearm-st-p.png",
          width = 600, height = 400)

#Guns traced to the US
#c(3090, 5260, 1950, 3060, 6700)
#2004:2008

#Total guns seized in Mexico
#30000  #hmmm, according to PGR it was 28,000 over two years
#Guns submitted for tracking
#7200

#Assault by rifle shotgun and larger firearm discharge
asweap <-  c(105, 80, 54, 50, 61, 48, 54, 55, 42, 41, 104)
#pop9808 <- c(95790135, 97114831, 98438557, 99715527, 100909374, 101999555, 103001867, 103946866, 104874282, 105790725, 106682518)
print(qplot(1998:2008, asweap, geom="line") +
    geom_line() +
 #   geom_point(aes(size = asweap)) +
    xlab("Year") + ylab("Number of Deaths") +
    opts(title="Number of deaths in Mexico by\nassault by rifle, shotgun and larger firearm discharge"))
dev.print(png, "guns-executions/output/long-guns.png",
          width = 500, height = 400)

