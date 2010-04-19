########################################################
#####       Author: Diego Valle Jones
#####       Website: www.diegovalle.net
#####       Date Created: Fri Mar 19 07:53:06 2010
########################################################
#Run all scripts and save the charts in the output directories

#If you have a slow computer you might want to go get a cup of coffee

source("initialize/init.r")

source("accidents-homicides-suicides/accidents-homicides-suicides.r")
source("guns-executions/guns-executions.r")
source("trends/seasonal-decomposition.r")
source("predictions/predictions.r")
source("historic/homicide-historic.r")
source("missing-homicides/missing-homicides.r")
source("missing-homicides/massacres.r")
source("INEGIvsSNSP/inegi-vs-snsp.r")
source("Benford/benford.r")
source("drugs/druguse.r")
source("most-violent-counties/most-violent.r")
source("timelines/timelines-mun.r")
source("timelines/ciudad-juarez.r")
#You need the maps for the next lines
source("states/homicide-bystate.r")
source("choropleths/county-maps-homicide.r")
