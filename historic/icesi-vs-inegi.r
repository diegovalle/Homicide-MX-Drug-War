########################################################
#####       Author: Diego Valle Jones
#####       Website: www.diegovalle.net
#####       Date Created: Fri Feb 05 20:34:20 2010
########################################################
#1. Time series of the different agencies that collect
#homicide data in Mexico
#2. Scatter plot of the INEGI homicide data vs the ICESI.
#Chihuahua is a big outlier

library(ggplot2)
library(directlabels)

homts <- read.csv("data/PAHO-UN-INEGI-ICESI.csv")
ggplot(melt(homts, id="Year"), aes(Year, value, group = variable,
                                   color = variable)) +
       geom_line(size=1.5) +
       ylab("Homicide rate") +
      opts(title = "Different estimates of the homicide rate")
dev.print(png, file = "output/PAHO-UN-INEGI-ICESI.png", width = 500, height = 300)

#FADE IN:
#LOWLY GOVERNMENT OFFICIAL Fernando is on the phone with a POWERFUL
#MEXICAN POLITICIAN named Felipe

#                    POWERFUL MEXICAN POLITICIAN

#(into phone)
#What the heck are you doing!



#                   FERNANDO

#(into phone)
#I’m deleting over 1,100 hundred murders from the police database boss



#                  POWERFUL MEXICAN POLITICIAN

#(into phone)
#Amigo: 2010 will be the 100th anniversary of the Mexican Revolution and the 200th anniversary of the Independence War, perhaps we should mark the occasion in a special way


#                  FERNANDO

#(into phone)
#Yes Jefe, in 2010 I will delete 2,100 murders from the database
#to mark the occasion


#                  POWERFUL MEXICAN POLITICIAN

#(into phone)
#Ja, ja, ja, pinche bola de pendejos, nadie se va a dar cuenta de lo que hicimos.
#Oye, ya nos dijo a que estado le vamos a dar en la madre a la siguiente.
#(English Subtitles)
#Please invest in Mexico, it is a safe an honest country

#FADE TO:

#EXT. INSIDE THE LOBBY OF A GOVERNMENT BUILDING - DAY
#FERNANDO breaks into song backed up by ten "edacanes"

#I am the very model of a modern Mexican politician
#With many cheerful facts about the murder rate.
#I'm quitting because of my party's political calculus;
#I know the president of my party is an animalculous:
#In short, in lying, cheating, and stealing
#I am the very model of a modern Mexican politician

#                                                           FADE OUT

#                  THE END
ivsi <- read.csv("data/INEGIvsICESI.csv")
ggplot(ivsi, aes(INEGI, ICESI,
                 label = paste(State," (",
                       as.character(INEGI-ICESI), ")", sep = ""))) +
       geom_text(aes(size = sqrt(abs(INEGI-ICESI))), hjust=-.1) +
       geom_point() +
       geom_abline(slope=1, linetype=2, color="blue") +
       opts(title = "Who's hiding homicides? (INEGI - ICESI)") +
       scale_x_continuous(limits = c(0, 4000)) +
       opts(legend.position = "none")
dev.print(png, file = "output/INEGIvsICES.png", width = 600, height = 480)
