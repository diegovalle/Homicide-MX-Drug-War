source("initialize/load-libraries.r")

config <- yaml.load_file("config/config.yaml")
map.icesi <- config$maps$map.icesi
map.inegi.ct <- config$maps$map.inegi.ct
map.inegi.st <- config$maps$map.inegi.st

#Unzip the maps
unzip("maps/maps.zip", exdir = "maps")

testMapsExist <- function(f){
  mapfiles <- c("ESTADOS.shp", "ESTADOS.shx", "ESTADOS.dbf",
                "MUNICIPIOS.shp", "MUNICIPIOS.shx", "MUNICIPIOS.dbf")
  mapfiles <- sapply(mapfiles, function(x) paste("maps/", x, sep = ""))
  if(!(FALSE %in% file.exists(mapfiles))){
    f
  } else {
      print("get the maps from:")
      print("homicide-maps-3.1.1.zip from http://files.diegovalle.net/")
      print("or")
      print("v3.1.1 from http://mapserver.inegi.org.mx/data/mgm/")
      print("Áreas Geoestadísticas Estatales y Zonas Pendientes por Asignar (6.47 Mb)")
      print("Áreas Geoestadísticas Municipales y Zonas Pendientes por Asignar (30.6 Mb)")
      print("Unzip the files into the 'maps' subdirectory")
  }
}
