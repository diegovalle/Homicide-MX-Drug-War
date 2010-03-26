Homicide in Mexico and the Drug War
=========================================================
Homicides in Mexico have increased greatly since the government sent in the military to fight drug cartels in December 2006. These series of scripts explore various statistics related to the increase in violence

Summary
--------

* From 2007 to 2008 there was a 65% increase in the homicide rate
* While homicides have increased greatly, most of the increase has been concentrated in the states controlled by drug cartels, the overall homicide rate in Mexico is about half that of Brazil
* The homicide data is not very reliable and if fails Benford's law. There were 1,157 homicides missing from the official police records in the state of Chihuahua. If the police data is to be believed, there were less homicides in the whole state of Chihuahua than in Ciudad of Juarez (which is located in Chihuahua).
* There’s evidence that sending the army to fight the drug cartels has increased the homicide rate.
* Since the army took control of Ciudad Juarez it has become the most violent city in the world.

The Story in Charts
--------------------

_While the drug war met with some success at first, the homicide rate increased 65% between 2007 and 2008_

![homicide rate in Mexico 1990-2009](http://imgur.com/nhrhy.png)

------------------------------------------------------------------------------------------------------------------------

_As you can see Mexico is pretty violent, but not as violent as Brazil_

![International Comparison](http://imgur.com/TWxh9.png)

--------------------------------------------------------------------------------------------------------------------------

_Most of the violence is concentrated in the states controlled by the drug cartels. Chihuahua looks like a war zone_

![Choropleth of homicide rates in 2009](http://github.com/diegovalle/Homicide-MX-Drug-War/raw/master/states/output/montage2008.png)

-------------------------------------------------------------------------------------------------------------------------

_Here's what it looks like at the municipality level. Keep in mind that the big municipalities tend to draw more attention because of their size, but they also tend to have low population densities_

![Choropleth of homicide rates by municipality](http://imgur.com/eX8cK.png)

------------------------------------------------------------------------------------------------------------------------

_There have been some big changes in homicide rates since the goverment declared war on the drug cartels at the end of 2006_

![Change in homicide rates](http://imgur.com/AhM8c.png)

-----------------------------------------------------------------------------------------------------------------------------

_The top row is composed of the states that are home to drug trafficking organizations, though I would have preferred it if the kmeans clustering algorithm had classified Sonora instead of Nayarit with the narco-states. There were some big decreases in the homicide rates of the State of Mexico, Morelos, Oaxaca and Michoacan._

![Homicide by State](http://imgur.com/JE2b2.png)

------------------------------------------------------------------------------------------------------------------------

_In Mexico there are two ways to measure the number of homicides: 1) Police Data (SNSP) and 2) Vital Statistics (INEGI). The bar plot compares them to see if the police records (labeled SNSP and filled with blue) match those of the vital statistics system (labeled INEGI and filled with red). The police records are missing 1,153 homicides in Chihuahua alone! Just to give you some perspective, in Ciudad Juarez, Chihuahua's biggest city, there were more than [1,600 homicides](http://www.reuters.com/article/idUSN08340024), more than the 1,414 reported in the whole state according to police records._

_read the file readme.md in the directory [missing-homicides](http://github.com/diegovalle/Homicide-MX-Drug-War/tree/master/missing-homicides/) to see why this happened_

![Who's missing homicides?](http://imgur.com/ybq4G.png "Chihuahua is missing 1153 homicides")

-------------------------------------------------------------------------------------------------------------------------

_More generally there are some big differences in the reported homicides. But not enough to make them useless_

![Differences in homicide rates](http://imgur.com/7uJOm.png)

-----------------------------------------------------------------------------------------------------------------------------------

_Benford’s Law was used as the expected distribution for the first digit of reported homicide rates. Not surprisingly, in a corrupt country like Mexico, both homicide series failed the test_

![Benford's law](http://imgur.com/M7IMP.png)


------------------------------------------------------------------------------------------------------------------------------------
__With the exception of Michoacan and Guerrero, when the army moved in, there was an increase in homicides__

_Chihuahua didn't fare well_

![Chihuahua](http://imgur.com/oaKOY.png)

_Durango also didn't fare well_

![Durango](http://imgur.com/G9Wh3.png)

_A similar thing happened in the rest of the states where the government sent in the army_

------------------------------------------------------------------------------------------------------------------------------------

_Annualized monthly homicide rates in Ciudad Juarez. The city turned into the most violent in the world after the army took control of it. Even rushing in reinforcements didn't return the murder rate to its former levels and after three months the bloodshed became even greater._

![Ciudad Juarez](http://imgur.com/gPN45.png)




Requirements
------------
*    You'll need to download a map of Mexico from the [ICESI](http://www.icesi.org.mx/estadisticas/estadisticas_encuestasTablas.asp) (Control-f xico and download the zip file)
*    You'll also need to download two maps of Mexico at the state and county level from the [INEGI](http://mapserver.inegi.org.mx/data/mgm/). (Note: you have to register to download them. Registration is free.). They have to be version 3.1.1 or they won't work

    [Áreas Geoestadísticas Estatales y Zonas Pendientes por Asignar (6.47 Mb)](http://mapserver.inegi.org.mx/data/mgm/redirect.cfm?fileX=ESTADOS311)

    [Áreas Geoestadísticas Municipales y Zonas Pendientes por Asignar (30.6 Mb)](http://mapserver.inegi.org.mx/data/mgm/redirect.cfm?fileX=MUNICIPIOS311)

*    Edit the file "config/config.yaml" with the locations of the maps you downloaded
*    Imagemagick if you want to merge the state level homicide rate maps with the bar plots

To Run
-------

Just run the script "run-all.r" and it will create all the charts in their respective directories. If you want to get data for femicides edit the file "config/config.yaml" and change the sex to Female


Contents
--------
In the directories you'll find:

* accidents-homicides-suicides: Estimates the homicide rate for all of Mexico based on accidental and violent death data from the INEGI. As a bonus it includes the suicide and accident rates.
* Benford: See of the homicide data from the INEGI and ICESI follow Bendford's law
* conapo-pop-estimates: Estimates of the population of Mexico, done by the CONAPO, at the state level for the period 1990-2030
* choropleths: Choropleths of the murder rate by county in Mexico for the years 1990, 1995, 2000, and 2006-2008
* drugs: Some regressions to see if drug consumption is correlated with the homicide rate. (It is, except for mariguana)
* timelines: Pretty timelines of the effect on the murder rate of sending the army to fight the drug cartels
* historic: Plot of the Mexican homicide rate from 1990 to 2009, a
  comparison with that of the US, Brazil, and England and Wales
* missing-homicides: Plots of the different homicide data to figure out how thrust-worthy the Mexican statistics are.
* most-violent-counties: A small multiple plot of the least and most violent municipalities for men and women
* states: Pretty plots and choropleths of the homicide rate at the state level

Each directory contains its own readme so you may want to look at them

Data Sources
------------
__Homicide data:__

Website of the INEGI:  [INEGI](http://www.inegi.org.mx/est/contenidos/espanol/proyectos/continuas/vitales/bd/mortalidad/MortalidadGeneral.asp?s=est&c=11144) for the
murder rate according to vital statistics

Website of the ICESI: [ICESI](http://www.icesi.org.mx) for the murder rate according to the Mexican police (which turns out not be a murder rate, and only an poor estimate of the final tally)

Website of the INEGI: [Statistical Yearbooks](http://www.inegi.org.mx/est/contenidos/espanol/sistemas/sisnav/selproy.aspx) that contain the final (over 90% reported) number of reports filed by the police for the crime of murder.

__Population:__

[census data](http://www.inegi.org.mx/inegi/default.aspx?c=9260&s=est) for the years 1990, 1995, 2000 at the county level. 

[CONAPO](http://conapo.gob.mx/index.php?option=com_content&view=article&id=125&Itemid=203)
for population estimates at the national level (1990-2030), state level (1990-2030) and county level(2005-2030).

__Check the readme files in each subdirectory for detailed information.__


Output
-------
historic:

* A png chart of the homicide rate in Mexico
* A png chart of the homicide rate in Mexico, the US, and England and Wales

timelines:

* Time series divided into before and after military operations for high crime states or states where the military has been sent
* Chart of the murder rate in Ciudad Juarez before and after the military took over since it is the most violent city in the world
* A latex file in the "report" directory with the confidence intervals of the breakpoints

most-violent-counties:

* Small multiples chart of the most and least violent counties for men and women

choropleths:

* Choropleths of Mexican Homicide Rates 1990, 1995, 2000, and 2006-2008

accidents-homicides-suicides:

* csv files with the rates of accident, homicides and suicides

states:

* Maps and charts with the homicide rate at the state level
* Maps and charts with the change in homicide rate from 2006 to 2008
* If you run merge.bat you get a merged chart of the bar plots and maps
* A small multiples chart with the murder rate of each state from 1990 to 2008

Benford:

* Do the homicide data follow Benford's law?

missing-homicides

* Why is there such a big difference between the two sources (police records and vital statistics) of homicide data

drugs:

* Correlations between drug use and homicides

Notes
-----
Where possible I tried using the official mid-year population estimates from the CONAPO, but for some of the choropleths (1990, 1995 and 2000) I used census data at the county level.

Author
-----
[Diego Valle](http://www.diegovalle.net)
