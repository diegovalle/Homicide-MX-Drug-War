########################################################
#####       Author: Diego Valle Jones
#####       Website: www.diegovalle.net
#####       Date Created: Fri Feb 12 21:48:28 2010
########################################################
#Regressions of drug use and homicides rates to see if
#Castañeda and Aguilar are right that an increase in drug use
#hasn't increased violence


drugs <- read.csv("drugs/data/druguse.csv")
drugs$Abbrv <- iconv(drugs$Abbrv, "windows-1252", "utf-8")
#The drug usage as a percetage
drugs[,2:7] <- drugs[,2:7] / 100

drawPlots <- function(df, x, y) {
  reg <- lm(logit(drugs[[x]], percents = TRUE) ~ drugs[[y]])
  pvalue <- summary(reg)$coefficients[,4][2]
  color <- ifelse(pvalue > .05, "red", "blue")
  if(pvalue > .05 & pvalue < .10)
    color <- "black"
  ggplot(df, aes_string(x = x, y = y, label = "Abbrv")) +
         geom_text(alpha = .5) +
         stat_smooth(method = lm, color = color) +
         #let's make the axes look the same
         coord_cartesian(ylim = c(-9, 80)) +
         scale_x_continuous(formatter = "percent") +
         opts(legend.position = "none")
}

grid.newpage()
pushViewport(viewport(layout =  grid.layout(nrow = 2, ncol = 2)))

subplot <- function(x, y) viewport(layout.pos.row = x,
                                   layout.pos.col = y)

print(drawPlots(drugs, "Cocaine", "Homicide.Rate"),
      vp = subplot(1, 1))
print(drawPlots(drugs, "Marihuana", "Homicide.Rate"),
      vp = subplot(1, 2))
print(drawPlots(drugs, "Amphetamines", "Homicide.Rate"),
      vp = subplot(2, 1))
print(drawPlots(drugs, "Illegal.Drugs", "Homicide.Rate"),
      vp = subplot(2, 2))

dev.print(png, "drugs/output/Drug Use.png", width=500, height=500)
