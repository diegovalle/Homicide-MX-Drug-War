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

cleanHom <-  function(df) {
  df <- subset(df, Code  == "#NAME?" &
              Year.of.Murder != "Total" &
              Year.of.Murder != "No especificado" &
              Month.of.Murder != "Total" &
              Month.of.Murder != "No especificado" &
              County != "Extranjero"
               )
  df$Year.of.Murder <- as.numeric(gsub('[[:alpha:]]', '',
                                        df$Year.of.Murder))
  df <- subset(df, Year.of.Murder >= 1990)
  col2cvt <- 5:ncol(df)
  df[is.na(df)] <- 0
  df$Total.Murders <- apply(df[ , col2cvt], 1, sum)
  df$Month.of.Murder <- factor(df$Month.of.Murder)
  #The months are in a weird order, so 04=Abril, etc.
  levels(df$Month.of.Murder) <- c("04","08","12","01","02","07","06","03","05","11","10","09")
  df
}

addMonths <- function(df){
  states <- unique(factor(df$County))
  start <- as.Date("1990/2/01")
  next.mon <- seq(start, length=12*19, by='1 month')
  period <- next.mon - 1
  dates.df <- data.frame(Date = factor(rep(period,
                                    each = 32)),
                         County = states)
  dates <- strptime(as.character(dates.df$Date), "%Y-%m-%d")
  dates.df$Month.of.Murder <- dates$mon + 1
  dates.df$Year.of.Murder <- dates$year + 1900
  df$Month.of.Murder <- as.numeric(df$Month.of.Murder)
  df <- merge(dates.df, df,
                   by = c("Month.of.Murder",
                          "Year.of.Murder", "County"),
                   all.x = TRUE)
  df[is.na(df)] <- 0
  df
}
