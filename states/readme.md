Homicide in Mexico at the State Level
=====================================
* Maps and charts with the homicide rate at the state level
* Maps and charts with the change in homicide rate from 2006 to 2008
* If you run combine.bat you get a merged chart of the bar plots and maps
* A small multiples chart with the murder rate of each state from 1990 to 2008

Sources
------
__Homicide Data:__

[INEGI](http://www.inegi.org.mx/est/contenidos/espanol/proyectos/continuas/vitales/bd/mortalidad/MortalidadGeneral.asp?s=est&c=11144)

__Population Data:__

[Indicadores demográficos básicos 1990-2030](http://www.conapo.gob.mx/index.php?option=com_content&view=article&id=125&Itemid=203)

Codebook
--------
Variables used to download the data from the INEGI:

Mortalidad general												

Consulta de: Defunciones accidentales y violentas   Por: Ent y mun de ocurrencia, Año de ocurrencia y Sexo   Según: Año de registro											
									


The first four columns of the database are nameless but correspond to:

Code - Numeric code for each state and county

County - Name of each county

Year.of.Murder - The year in which the violent death _occurred_

Sex	- Sex of the deceased

1990 ... 2008 - The rest of the columns correspond to the year in which the murder was _registered_

The weird order of the database is because the website of the INEGI is a steaming pile of broccoli an only lets you download the data ordered by the year in which the murder was registered.				


Notes:
------
If you want charts of femicides edit the file "config/config.yaml" and set sex to Women				
