source("initialize/load-libraries.r")

config <- yaml.load_file("config/config.yaml")
map.icesi <- config$maps$map.icesi
map.inegi.ct <- config$maps$map.inegi.ct
map.inegi.st <- config$maps$map.inegi.st