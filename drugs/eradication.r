########################################################
#####       Author: Diego Valle Jones
#####       Website: www.diegovalle.net
#####       Date Created: Tue May 25 09:58:24 2010
########################################################
#Pretty plots of marijuana and opium eradication

drugPlot <- function(df, filename) {
  print(ggplot(df, aes(years, area, group = type,
                    color = type)) +
      geom_line() +
      geom_rect(xmin = 2006, xmax = 2009,
              ymin=0, ymax=Inf, alpha = .02, fill = "red",
                color= "#efefef") +
      annotate("text", x = 2007.5, y = 28000, label = "Drug War") +
      ylab("Eradication (ha)") + xlab("") +
      opts(title = "The amount of cannabis and opium poppy\neradicated has decreased") +
      scale_y_continuous(formatter = "comma"))
  filename <- paste("drugs/output/", filename)
  dev.print(png, filename, width=640, height=480)
}

#http://www.state.gov/p/inl/rls/nrcrpt/2010/vol1/137197.htm
#Eradication (ha)
mj <- c(14135, 18663, 23316, 30162, 30857, 30852, 36585, 30775, 28699)
opium <- c(11471, 13189, 11410, 16890, 21609, 15926, 20034, 19158, 19115)
drugs <- data.frame(area = c(mj, opium),
                    years = rep(2009:2001, 2),
                    type = rep(c("marijuana", "poppy"), each = 9))
drugPlot(drugs, "cannabis-poppy-eradication.png")

#Harvestable / Net Cultivation (ha)
mj <- c(12000, 8900, NA, 8600, 5600, 5800, 7500, 7900, 4100)
poppy <- c(15000, 6900, NA, 5100, 3300, 3500, 4800, 2700, 4400)
drugs <- data.frame(area = c(mj, poppy),
                    years = rep(2009:2001, 2),
                    type = rep(c("marijuana", "poppy"), each = 9))
drugPlot(drugs, "cannabis-poppy-cultivation.png")


#WORLD DRUG REPORT 2009
#http://www.unodc.org/documents/wdr/WDR_2009/WDR2009_eng_web.pdf page 220
#Prices adjusted for purity and inflation
cok.prc <- c(421,343,263,251,232,275,217,208,189,193,224,227,158,166,147,140,134,162,216)
p <- qplot(1990:2008, cok.prc, geom="line") +
    geom_rect(xmin = 2006, xmax = 2009,
            ymin=0, ymax=Inf, alpha = .02, fill = "red") +
    annotate("text", x = 2007.5, y = 370, label = "Drug War") +
    opts(title = "There has been an increase in the price of\ncocaine adjusted for purity and inflation\nsince the start of the drug war") +
    ylab("Street price - US$/gram") + xlab("year")
print(p)
dev.print(png, "drugs/output/coke-price.png", width=640, height=480)
