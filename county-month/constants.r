########################################################
#####       Author: Diego Valle Jones
#####       Website: www.diegovalle.net
#####       Date Created: Thu Feb 04 13:35:41 2010
########################################################
#Constants consisting of the start of the military operations against
#drug cartels

#Each state has a number assigned to them in the csv file
baja.california <- "^02"
chihuahua <- "^08"
durango <- "^10"
michoacan <- "^16"
sinaloa <- "^25"
sonora <- "^26"

guerrero <- "^12"
oaxaca <- "^20"

tamaulipas <- "^28"
nuevo.leon <- "^19"

########################################################
#Start of the joint operations to combat drug cartels
########################################################
#From: Wikipedia
op.mich <- as.Date("12/11/2006", "%m/%d/%Y")

#From:http://www.pgr.gob.mx/cmsocial/coms07/210107%20resultado%20de%20operaciones%20conjuntas.ppt
#OPERATIVO CONJUNTO  TIJUANA
op.tij <-  as.Date("01/03/2007", "%m/%d/%Y")
#Operativo Conjunto Guerrero
op.gue <- as.Date("01/12/2007", "%m/%d/%Y")
#Operativo Conjunto Triángulo Dorado(SINALOA, DURANGO Y CHIHUAHUA)
op.tria.dor <- as.Date("01/17/2007", "%m/%d/%Y")

#Operativo Conjunto Chihuaha
#www.el-mexicano.com.mx%2Fnoticias%2Fnacional%2F2009%2F03%2F02%2Fsitian-militares-ciudad-juarez.aspx&ei=OoZgS-nmA4XYtgOHwpGzCw&usg=AFQjCNH5AvHSTNwSpMPqT98OuiSYA8kbjg&sig2=rucCCB325xG_lYgmU_Rodw
#http://www.juarezpress.com/not_detalle.php?id_n=12641&busca=sedena
#El secretario de la Defensa, Guillermo Galván, informa que para esa fecha ya estaban destacamentados en ciudad Juárez 539 efectivos, y anuncia arribo de tres Hércules.
op.chi <- as.Date("03/27/2008", "%m/%d/%Y")

#Operación Conjunta Culiacán-Navolato
#http://www.tabascohoy.com.mx/nota.php?id_nota=155210
op.sin <-  as.Date("05/13/2008", "%m/%d/%Y")

#http://www.elsiglodedurango.com.mx/descargas/pdf/2007/02/19/19dgo08a.pdf?v
op.tam.nl <- as.Date("02/17/2007","%m/%d/%Y")
