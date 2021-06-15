#Programming tasks 15.06.2021


# setup -------------------------------------------------------------------

packs<-c("caret","tidyverse")

install.packages("caret")

lapply(packs, library, character.only = T)

data_path<- file.path(getwd(),"data-master")
