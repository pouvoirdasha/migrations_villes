setwd("~/0 ENSAE/3A/S2/Social_network/Rendu final/migrations_villes/création de la base")
library(data.table)

data = fread("../base-flux-mobilite-residentielle-2022.csv")

data[, migrations_intra_ville := fifelse(CODGEO == DCRAN, 
                                         1, 0)]

data = data[migrations_intra_ville == 0 & DCRAN != "99999"]

df = data[, c("LIBGEO", "L_DCRAN")]

setnames(df, c("LIBGEO", "L_DCRAN"), c("source", "target"))

fwrite(df, "../edges_mobilites.csv")




df2 = data[, c("LIBGEO", "L_DCRAN", "NBFLUX_C22_POP01P")]
setnames(df2, c("LIBGEO", "L_DCRAN", "NBFLUX_C22_POP01P"), c("source", "target", "nb_migrations"))
fwrite(df2, "../edges_mobilites_nb.csv")


df3 = data[, c("CODGEO", "DCRAN", "NBFLUX_C22_POP01P")]
setnames(df3, c("CODGEO", "DCRAN", "NBFLUX_C22_POP01P"), c("source", "target", "nb_migrations"))


info_com = fread("communes-france-2025.csv")
info_com = info_com[, c("code_insee", "nom_standard", 
                        "latitude_centre", "longitude_centre")]

pop_com = fread("donnees_communes.csv")
pop_com = pop_com[, c("COM", "PTOT")]
setnames(pop_com, "COM", "code_insee")

df_com = merge(info_com, pop_com)
df_com = df_com[!is.na(latitude_centre)]
df_com = df_com[, c("code_insee", "PTOT", "latitude_centre", "longitude_centre")]

setwd("C:/Users/jonas/Downloads/géographie_communes/centroide_PLM")

arr_paris = as.data.table(st_read("centroides_paris.shp"))
arr_paris[, code_insee := c_arinsee]
arr_paris = arr_paris[, c("code_insee", "X", "Y")]
arr_paris = merge(arr_paris, pop_com)


arr_lyon = as.data.table(st_read("centroides_lyon.shp"))
arr_lyon[, code_insee := insee]
arr_lyon = arr_lyon[, c("code_insee", "X", "Y")]
arr_lyon = merge(arr_lyon, pop_com)

arr_marseille = as.data.table(st_read("centroides_marseille.shp"))
arr_marseille = arr_marseille[statut == "arrondissement municipal"]
arr_marseille[, code_insee := com_arm_cu]
arr_marseille = arr_marseille[, c("code_insee", "X", "Y")]
arr_marseille = merge(arr_marseille, pop_com)

arr = rbind(arr_lyon, arr_marseille, arr_paris)

setnames(arr, c("Y", "X"), c("latitude_centre", "longitude_centre"))


df_com_arr = rbind(arr, df_com)
setnames(df_com_arr, c("latitude_centre", "longitude_centre"),
         c("latitude", "longitude"))
setnames(df_com_arr, "PTOT", "population")
setwd("~/0 ENSAE/3A/S2/Social_network/Rendu final/migrations_villes/création de la base")

fwrite(df_com_arr, "../communes.csv")
