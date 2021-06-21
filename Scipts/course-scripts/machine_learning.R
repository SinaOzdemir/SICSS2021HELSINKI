#Programming tasks 15.06.2021


# setup -------------------------------------------------------------------

packs<-c("caret","tidyverse","psych","Hmisc")

install.packages("caret")
install.packages("psych")
lapply(packs, library, character.only = T)

data_path<- file.path(getwd(),"data-master")

wvs<- read.csv(file = file.path(data_path,"wvs.csv")) %>%
  select(X,V10,V4:V9) %>%
  purrr::set_names(nm = c("id","V10","V4","V5","V6","V7","V8","V9"))
  
wvs$V10<-as.factor(wvs$V10)

#  data summary -----------------------------------------------------------

data_meta<- Hmisc::contents(wvs)[["contents"]] %>% 
  as_tibble(rownames = "var.names")

summary<- wvs %>%
  select(-id) %>%
  psych::describe(x = .) %>%
  as_tibble(rownames = "variables") %>%
  select(-vars)


# re-run provided script --------------------------------------------------


index = createDataPartition(y=wvs$V10, p=0.7, list=FALSE)
train = wvs[index,]
test = wvs[-index,]

table( train$V10 )
table( test$V10 )

model = train( V10 ~ V4 + V5 + V6 + V7 + V8 + V9,  data=train, method="rpart" )

pred = predict(model , newdata = test,type = "raw")

tab_class <- table( test$V10 , pred )

print( tab_class )

confusionMatrix(tab_class, mode = "everything")


# Exercises-------------------------------------------------------------------------

# Exercise 1:

##V10 has several unwanted values: -5, -2 and -1. Remove them from the data and rerun the analysis.

wvs_trimmed<- read.csv(file = file.path(data_path,"wvs.csv")) %>%
  select(X,V10,V4:V9) %>%
  purrr::set_names(nm = c("id","V10","V4","V5","V6","V7","V8","V9")) %>%
  filter(V10 > 0) %>%
  select(-id)

wvs_trimmed$V10<- as.factor(wvs_trimmed$V10)

table(wvs_trimmed$V10)

clean_index <- createDataPartition(y = wvs_trimmed$V10, p = .7,list = F)

train_clean <- wvs_trimmed[clean_index,]
test_clean<-wvs_trimmed[-clean_index,]

model_clean <- train( V10 ~ V4 + V5 + V6 + V7 + V8 + V9,  data=train_clean, method="rpart" )

pred_clean <- predict(model_clean, newdata = test_clean, type = "raw")

tab_class_clean <- table(test_clean$V10,pred_clean)

confusionMatrix(tab_class_clean,mode = "everything")


### Prediction accuracy did not change at all trying with a different model


model_clean_ord <- train( V10 ~ V4 + V5 + V6 + V7 + V8 + V9,  data=train_clean, method="ORFsvm")

pred_clean_ord <- predict(model_clean_ord, newdata = test_clean, type = "raw")

tab_class_clean_ord <- table(test_clean$V10,pred_clean_ord)

confusionMatrix(tab_class_clean_ord,mode = "everything")