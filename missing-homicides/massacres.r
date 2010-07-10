########################################################
#####       Author: Diego Valle Jones
#####       Website: www.diegovalle.net
#####       Date Created: Sun Apr 04 13:06:20 2010
########################################################
#Check if some of the big massacres that occured in Mexico were recorded in the INEGI homicide database

whichNumber <- function(df, county, month, year){
  which(df$County == county &
        df$Month.of.Murder == month &
        df$Year.of.Murder == year)
}

extractCol <- function(df, county, month, year) {
  num <- whichNumber(df, county, month, year)
  df[((num-2):(num+2)), ]
}
#Tijuana prison riot](http://news.newamericamedia.org/news/view_article.html?article_id=413e55db3c6d5eac317d63edb8ce03d8): September 2008,  25 dead. In the INEGI homicide database
hom.tj <- read.csv("timelines/data/county-month.csv.bz2")
tj <- extractCol(hom.tj, "Tijuana", "Septiembre", "2008")

#[Ensenada](http://articles.latimes.com/1998/sep/19/news/mn-24394): September 19, 1998, 18 dead. In the INEGI homidice database
en <- extractCol(hom.tj, "Ensenada", "Septiembre", "1998")

#[Reynosa prison riot](http://www.horacerotam.com/Not_interior1.asp?Id=NHCT22047&link=280):  October 2008, 21 dead. In the INEGI homicide database
hom.ry <- read.csv("timelines/data/county-month-nl-tam.csv.bz2")
ry <- extractCol(hom.ry, "Reynosa", "Octubre", "2008")


#[Acteal Massacre](http://zedillo.presidencia.gob.mx/pages/chiapas/docs/crono.html): 45 dead December 22, 1997. Not in the INEGI homicide database
hom.chip <- read.csv("timelines/data/county-month-chiapas.csv.bz2")
acteal <- extractCol(hom.chip, "Chenalhó", "Diciembre", "1997")

#since no deaths occured in Chenalhó lets check for the whole state of Chiapas
chiapas <- extractCol(hom.chip, "Chiapas", "Diciembre", "1997")


#[Aguas Blancas Massacre](http://www.sfgate.com/chronicle/special/mexico/massacre.html): (Warning: Graphic Video) 17 dead June 28, 1995. In the INEGI homicide database
hom.gue <- read.csv("timelines/data/county-month-gue-oax.csv.bz2")
AB <- extractCol(hom.gue, "Coyuca de Benítez", "Junio", "1995")

#Cananea-Arizpe
hom.son <- read.csv("timelines/data/county-month.csv.bz2")
cana <- extractCol(hom.son, "Arizpe", "Mayo", "2007")

#[Decapitated Bodies in Yucatán](http://www2.esmas.com/noticierostelevisa/mexico/009070/hallan-doce-cadaveres-decapitados-yucatan): August 28 2008, 12 dead. In the INEGI homicide database
yuc <- extractCol(hom.tj, "Yucatán", "Agosto", "2008")

#[24 dead outside Mexico City](http://www.nytimes.com/2008/09/14/world/americas/14mexico.html?_r=1): September 13, 2008, 24 dead. In the INEGI homicide database
hom.mx <- read.csv("timelines/data/county-month-mx.csv.bz2")
oco <- extractCol(hom.mx, "Ocoyoacac", "Septiembre", "2008")

massacres <- rbind(AB, acteal, chiapas, en, cana, yuc, oco, tj, ry)
write.csv(massacres, "missing-homicides/output/massacres.csv")
rm(hom.tj, hom.gue, hom.chip, hom.ry, hom.son)
