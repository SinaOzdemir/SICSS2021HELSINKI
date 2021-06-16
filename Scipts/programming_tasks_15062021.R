#Programming tasks 15.06.2021


# setup -------------------------------------------------------------------

packs<-c("caret","tidyverse","psych","Hmisc")

install.packages("caret")
install.packages("psych")
lapply(packs, library, character.only = T)

data_path<- file.path(getwd(),"data-master")

wvs<- read.csv(file = file.path(data_path,"wvs.csv"))


#  data summary -----------------------------------------------------------


