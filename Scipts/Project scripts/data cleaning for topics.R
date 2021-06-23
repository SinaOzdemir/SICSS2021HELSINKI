# Data carpentering for topic models
packs<- c("here","tidyverse")
lapply(packs, library, character.only = T)
datas<- list.files(here::here("data-master","project-data"),all.files = T,full.names = T,no.. = T)
questions_colnames<-c("Parliament",
                      "Session",
                      "Title",
                      "Question",
                      "MP",
                      "Ministry",
                      "Marginal_topic",
                      "Constitutency")

questions<- read.csv(file = datas[4],sep = ",",
                     stringsAsFactors = F) %>%
  select(1:8) %>% set_names(nm = questions_colnames)
topic_10<- read.csv(file = datas[1]) %>% rename(topic_10 = labels)
topic_15<- read.csv(file= datas[2]) %>% rename(topic_15 = labels)

question_topics<-cbind(questions,topic_10,topic_15)

question_topics$Question<- str_remove_all(string = question_topics$Question,pattern = "Â")

question_topics$Title<- str_remove_all(string = question_topics$Title,pattern = "â€™")

saveRDS(object = question_topics,file = paste0(data_path,"/Questions_topics.RDS"))
write.table(x = question_topics,file = paste0(data_path,"/Questions_topics.csv"),
            sep = ",",
            fileEncoding = "UTF-8",
            row.names = F,
            col.names = T)

write.table(x = question_topics,file = paste0(data_path,"/Questions_topics.txt"),
            sep = ",",
            fileEncoding = "UTF-8",
            row.names = F,
            col.names = T)

