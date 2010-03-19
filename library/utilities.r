########################################################
#####       Author: Diego Valle Jones
#####       Website: www.diegovalle.net
#####       Date Created: Thu Feb 04 13:35:41 2010
########################################################
#Shared functions

#Group  dates into intervals
cutDates <- function(df, dates) {
  vec <- c(df$Date[1], dates, df$Date[nrow(df)] + 1000)
  cut(df$Date, vec)
}

#Get rid of the full name of the states (eg: Veracruz de
#Ignacio de la Llave changes to Veracruz
cleanNames <- function(df, varname = "County"){
  df[[varname]] <- gsub("* de .*","", df[[varname]])
  df[[varname]]
}