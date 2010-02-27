########################################################
#####       Author: Diego Valle Jones
#####       Website: www.diegovalle.net
#####       Date Created: Thu Feb 04 13:35:41 2010
########################################################
#Constants consisting of the start of the military operations against
#drug cartels

#Each state has a number assigned to them in the csv file
baja.california <- "^02"
chihuahua <- "^08"
durango <- "^10"
michoacan <- "^16"
sinaloa <- "^25"
sonora <- "^26"

guerrero <- "^12"
oaxaca <- "^20"

tamaulipas <- "^28"
nuevo.leon <- "^19"

########################################################
#Start of the joint operations to combat drug cartels
########################################################
#From: Wikipedia
op.mich <- as.Date("12/11/2006", "%m/%d/%Y")

#OPERATIVO CONJUNTO  TIJUANA
op.tij <-  as.Date("01/03/2007", "%m/%d/%Y")
#Operativo Conjunto Guerrero
op.gue <- as.Date("01/15/2007", "%m/%d/%Y")
#Operativo Conjunto Triángulo Dorado(SINALOA, DURANGO Y CHIHUAHUA)
op.tria.dor <- as.Date("01/13/2007", "%m/%d/%Y")
op.tria.dor.II <- as.Date("05/01/2007", "%m/%d/%Y")
op.tria.dor.III <- as.Date("02/01/2008", "%m/%d/%Y")

#Operativo Conjunto Chihuaha
#El secretario de la Defensa, Guillermo Galván, informa que para esa fecha ya estaban destacamentados en ciudad Juárez 539 efectivos, y anuncia arribo de tres Hércules.
op.chi <- as.Date("03/27/2008", "%m/%d/%Y")

#Operación Conjunta Culiacán-Navolato
op.sin <-  as.Date("05/13/2008", "%m/%d/%Y")

#Opertivo Conjunto Tamaulipas - Nuevo León
op.tam.nl <- as.Date("02/17/2007","%m/%d/%Y")

#Operativo Sonora
op.son <- as.Date("03/07/2008", "%m/%d/%Y")

#Reinfocements for Ciudad Juarez
#2,000 arrived March 1st 2009 and another 3,000 arrived during the
#next 15 days
cdj.rein <- as.Date("03/01/2009", "%m/%d/%Y")

#Alfredo Beltrán Leyva caputred
bel.ley <- as.Date("01/21/2008", "%m/%d/%Y")

#Eduardo Arellano Félix "El Doctor" captured
doctor <- as.Date("10/26/2008", "%m/%d/%Y")


#Group  dates into intervals
cutDates <- function(df, dates) {
  vec <- c(df$Date[1], dates, df$Date[nrow(df)] + 1000)
  cut(df$Date, vec)
}
