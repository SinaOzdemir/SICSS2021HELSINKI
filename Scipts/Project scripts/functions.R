# Group project functions:

meta_data_grapher <- function(data){
  
  data_class<- map_df(data, class) %>% pivot_longer(cols = 1:ncol(.),
                                                    names_to = "variable_names",values_to = "variable_class")
  
  meta_data<- Hmisc::contents(data)[["contents"]] %>% 
    as_tibble(rownames = "variable_names") %>% left_join(x = .,y = data_class, by = "variable_names") %>%
    mutate(class_storage = paste0(.$variable_class,"/",Storage))
  
  
  meta_graph <- meta_plot<- meta_data %>% ggplot(aes(x = variable_names, y = NAs))+
    geom_bar(aes(fill = NAs),stat = "identity",position = "dodge")+
    geom_text(aes(label = class_storage),nudge_y = 2.5)+
    theme_minimal()+theme(axis.text.x = element_text(angle = 90))+coord_flip()+
    labs(x = "Variable", y = "NA count",title = "Storage type and NA counts of Parliament data \n N = 136",subtitle = "labels indicate variable class/storage")
  
  return(meta_graph)
}