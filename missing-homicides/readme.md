How reliable are Mexican Homicide Statistics?
================================================

There are 2 main sources of homicide statistics in Mexico, the vital
statistics from the INEGI, and the police data which are available at
the ICESI (a civic association not affiliate with the
government which gets the data from the SNSP [Secretaría Nacional de Seguridad Pública]). But as it turns out the data from the ICESI is only an estimate
(even if the secretary of the interior uses the data in his presentations
as if it were the number of homicides), 
still, you can download the final numbers from the Statistical Yearbooks of 
each state. Since both data sources are available at the state level you can
compare them and see if there are any differences.

The plot gets thicker: it turns out the data from the ICESI for 2008 are only
estimates (missing over 1,100 homicides in Chihuahua, looks like it was a mid-year
"estimate"). The INEGI releases a series of statistical yearkbooks for each state
that contain the final (final being over 90% reported) data according to the local police forces (homicide is a 
local crime in Mexico). I didn't include the statistical yearbooks because they're
about 250MB, but in the directory "anuarios" you'll find a script to download them

Even thicker: the data from the ICESI and the statistical yearbooks are not even 
homicides, but police reports. So if 18 kids are killed in a massacre at the same 
time, and there's only one police report, they are recorded as one. The statistical
yearbooks do have the data available by number of victims, but they combine "homicidios
dolosos" (homicide) with "homicidios culposos" (manslaughter). I wonder, wonder why
they would do this?

Data are also available from PAHO and the UN, but only at the national level.

Output
------
* Chart of homicides rate according to the INEGI, ICESI, PAHO, and the UN Crime Survey.
* Bar plot of the differences in number if homicides, one for the ICESI data and another for the final data from the Statistical Yearbooks.
* Scatter plot of the different homicide data (INEGI vs ICESI). That is see if the police records (labeled ICESI) match those of the vital statistics system(labeled INEGI). The police records are missing over 1,100 homicides in Chihuahua alone.
* Scatter plot against the proportions.

Sources
------
__Mexican Homicide Data:__

[INEGI](http://www.inegi.org.mx/est/contenidos/espanol/proyectos/continuas/vitales/bd/mortalidad/MortalidadGeneral.asp?s=est&c=11144)

[ICESI](http://www.icesi.org.mx/documentos/estadisticas/estadisticas/denuncias_homicidio_doloso_1997_2008.xls)

[Statistical Yearbooks](http://www.inegi.org.mx/est/contenidos/espanol/sistemas/sisnav/selproy.aspx): The following states were not available as of Feb-17-2009, so I used the estimates that appear in the file from the ICESI: Durango, Tlaxcala, Yucatan and Nayarit. Furthermore there was a mistake in the statistical yearbook for Querétaro (the data from "homicidios dolosos"[homicide] and "homicidios culposos"[manslaughter] was transposed).

[PAHO](http://www.paho.org/English/SHA/coredata/tabulator/newTabulator.htm) Pan American Health Organization, Health Analysis and Statistics Unit. Regional Core Health Data Initiative; Technical Health Information System. Washington DC, 2007.

UN Crime Survey: Eight and Seventh United Nations Survey of Crime Trends and Operations of Criminal Justice Systems

__Population Data:__

[Indicadores demográficos básicos 1990-2030](http://www.conapo.gob.mx/index.php?option=com_content&view=article&id=125&Itemid=203)

CodeBook:
---------
INEGIvsICESI.csv

Colums:
State	| INEGI	| ICESI	| Abbrv	| Anuario	| Stat.Yrbks

State - Name of the State

INEGI - Number of homicides according to the INEGI

ICESI - Number of homicides according to the ICESI (which takes the data from SNSP)

Anuario - The raw values according to the Statistical Yearbooks

Stat.Yrbks - The values from the Statistical Yearbooks if available, if not, the data is from the ICESI

