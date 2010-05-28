########################################################
#####       Author: Diego Valle Jones
#####       Website: www.diegovalle.net
#####       Date Created: Tue May 25 09:58:24 2010
########################################################
#This program does this and that
#http://www.jornada.unam.mx/2009/12/26/index.php?section=politica&article=004n1pol
#http://www.america.gov/st/washfile-english/2006/May/200605041351421xeneerg0.5226862.html

mj = c(30840, 30061, 23914, 18394, 15323)
poppy = c(21600, 16889, 12059, 13189, 13264)
drugs <- data.frame(eradicated = c(mj, poppy),
                    years = rep(2005:2009, 2),
                    type = rep(c("marijuana", "poppy"), each = 5))

print(ggplot(drugs, aes(factor(years), eradicated, group = type,
                  color = type)) +
    geom_line() +
    ylab("hectares eradicated") + xlab("") +
    opts(title = "The amount of cannabis and opium poppy\neradicated has decreased") +
    scale_y_continuous(formatter = "comma"))
dev.print(png, "drugs/output/cannabis-poppy.png", width=640, height=480)


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
