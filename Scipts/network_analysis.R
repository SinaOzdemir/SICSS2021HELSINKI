#Network analysis 16.06.2021


# Setup -------------------------------------------------------------------

library(igraph)
library(tidyverse)
library(patchwork)
data_path<- file.path(getwd(),"data-master")

data<- read.csv(file = file.path(data_path,"org_x_collaboration.csv"),stringsAsFactors = F,header = F) %>% as.matrix()

colnames(data)<-paste("company",seq_along(1:ncol(data)),sep = "_")

network<- igraph::graph_from_adjacency_matrix(adjmatrix = data,mode = "undirected",weighted = T)

n_degree<- degree(network)

summary(n_degree)

#Degree centrality is the simplest centrality measure to compute.
#Recall that a node's degree is simply a count of how many social connections (i.e., edges) it has.
#The degree centrality for a node is simply its degree.
#A node with 10 social connections would have a degree centrality of 10.
#A node with 1 edge would have a degree centrality of 1.
#For degree centrality, higher values mean that the node is more central

n_degree_df<- n_degree %>%
  as_tibble() %>%
  set_names(nm = "degree") %>% 
  mutate(across(degree,as.numeric))

n_degree_hist<- n_degree_df %>% 
  ggplot(aes(x = degree))+
  geom_histogram(aes(y=..density..),color = "darkblue",fill = "steelblue")+
  geom_density(alpha = .4, fill = "magenta")+ theme_minimal()+
  labs(title = "Degree centrality of organizations network")

#Betweenness centrality measures how often a node occurs on all shortest paths between two nodes.
#Hence, the betweenness of a node N is calculated considering couples of nodes (v1, v2) and
#counting the number of shortest paths linking those two nodes, which pass through node N

n_between_df <- betweenness(network) %>% 
  as_tibble() %>%
  set_names(nm = "between") %>% 
  mutate(across(between,as.numeric))

n_between_hist<- n_between_df %>% 
  ggplot(aes(x = between))+
  geom_histogram(aes(y=..density..),color = "darkgreen",fill = "lightgreen")+
  geom_density(alpha = .4, fill = "darkblue")+ theme_minimal()+
  labs(title = "Betweenness centrality of organizations network")

#Closeness centrality is a way of detecting nodes that are able to spread information very efficiently through a graph.
#The closeness centrality of a node measures its average farness (inverse distance) to all other nodes.
#Nodes with a high closeness score have the shortest distances to all other nodes.

n_closeness_df <- closeness(network) %>% 
  as_tibble() %>%
  set_names(nm = "closeness") %>% 
  mutate(across(closeness,as.numeric))


n_close_hist<- n_closeness_df %>% 
  ggplot(aes(x = closeness))+
  geom_histogram(aes(y=..density..),color = "red",fill = "pink")+
  geom_density(alpha = .4, fill = "yellow")+ theme_minimal()+
  labs(title = "Closeness centrality of organizations network")


(n_degree_hist + patchwork::plot_spacer()+n_between_hist)/(plot_spacer()+n_close_hist+plot_spacer())


# correlation between centrality measures ---------------------------------

central_cor = cbind(n_between_df,n_closeness_df,n_degree_df) %>%
  cor(., method = c("pearson")) %>%
  as.matrix()

install.packages("corrplot")
library(corrplot)

corr_plot<- corrplot(central_cor,type = "lower",title = "Pearson's correlation between centrality measures",diag = T)

install.packages("ggcorrplot")
library(ggcorrplot)

corr_plot_2<-ggcorrplot(central_cor,method = "square" ,hc.order = TRUE, type = "lower",
           lab = TRUE, title = "Pearson's correlation between centrality measures")



# plotting the network ----------------------------------------------------


V(network)$color <- 'steelblue'
V(network)$size <- degree(network)*.7

E(network)$color <- 'magenta'

l = layout_with_kk( network )

plot(network, layout = l, main = "Sina Ozdemir",sub = "	The Kamada-Kawai layout algorithm \n Vertex sizes rescaled by .7")
