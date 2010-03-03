########################################################
#####       Author: Diego Valle Jones
#####       Website: www.diegovalle.net
#####       Date Created: Wed Feb 03 20:54:12 2010
########################################################
#This program plots the murder rate in Ciudad Juarez
#before and after the army took over.

#The population data is from the CONAPO (2005-2030)
#The murder data for 2007 and 2008 is from the INEGI
#The murder data for 2009 is from:
#http://www.puntoporpunto.com/informacion-general/en_juarez_suman_mil_13_asesina.php
#and
#http://www.larednoticias.com/detalle.cfm?s=26

#I couldn't get this song out of my head
#Nomberr uan, Nomberr uan, haha :'(

#Aca en el norte la vida sigue,
#a pesar de reinar la ley del oeste.

#I come from the land
#of the macho man
#y las putas y los narcos
#y los cholos y mojados,
#es mi forntera tan violenta
#que la vida te renta.

#Aca en el norte la vida sigue,
#a pesar de reinar la ley del oeste.

#You don`t have to be over 21,
#to drink all that you can
#and fuck with who you want.
#Welcome to the town of the lost souls,
#the lonely, the drugs
#and the beautiful, beatiful girls.

#Aca en el norte la vida sigue,
#a pesar de reinar la ley del mas fuerte.

#Es mi ciudad, don`t let me down.
#I love my town.
#`Cause Ciudad Juarez is the number one.
#Es mi ciudad, donde hay lealtad.
#Amo ese lugar.
#`Cause ciudad Juarez is the number one.
#Number one, number one, number one.

#Es mi ciudad, don`t let me down...

library(ggplot2)
library(Cairo)

source("constants.r")

hom <- read.csv(bzfile("data/county-month.csv.bz2"))
cdjuarez09 <- c(136, 240, 73, 90, 125, 247, 248, 337,
                304, 290, 374, 317)
cdjuarez0708 <- subset(hom,
                       Code == "08 037" &
                       (Year.of.Murder == "2008" |
                        Year.of.Murder =="2007") &
                       Month.of.Murder != "Total")
cdjuarez0708$Tot <- apply(cdjuarez0708[ , 5:ncol(cdjuarez0708)], 1, sum, na.rm = T)
pop0709 <- c(1359787, 1384102, 1407849)

#A sequence of dates starting at the end of the month
start <- as.Date(as.Date("2007/2/01"))
next.mon <- seq(start, length=36, by='1 month')
dates <- next.mon - 1
cdj <- data.frame(Murders = c(cdjuarez0708$Tot, cdjuarez09),
           Date = dates)
#Anualized murder rate
cdj$rate <- (cdj$Murders / rep(pop0709, each = 12)) * 100000 * 12

cdj$group <- cutDates(cdj, c(op.chi, cdj.rein))

Cairo(file = "output/ciudad-juarez.png", width=600, height=400)
ggplot(cdj, aes(Date,rate)) +
    geom_point(aes(size = Murders), color = "darkred") +
    geom_vline(aes(xintercept = op.chi), alpha = .7) +
    geom_text(aes(x,y, label = "Joint Operation Chihuahua"),
            data = data.frame(x = op.chi, y = 152),
            size = 4, hjust = 1.01, vjust = 0) +
    geom_vline(aes(xintercept = cdj.rein), alpha = .7) +
    geom_text(aes(x,y, label = "Reinforcements sent"),
            data = data.frame(x = cdj.rein, y = 252),
            size = 4, hjust = 1.01, vjust = 0) +
    geom_smooth(aes(group = group), se = FALSE) +
    ylab("Annualized murder rate") + xlab("") +
    opts(title = "Murder rates in Ciudad Juarez before and after the army took control")
dev.off()
