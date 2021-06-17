#Complex systems and simulations

install.packages("deSolve")
library(deSolve)
library(tidyverse)


#time starts from 0 and continues until 365 by 1 to represent 365 days of year at a daily intervals

time <- seq(0,365, by = 1)


#three groups of people: health, sick and killed

groups<- c(health = 5382000, sick = 100, killed = 0)

#model parameters; infection and kill rate
#parameter values for Norway are taken from: https://bit.ly/3vza06e

parameters<- c( infection_rate = (24151/1000000), death_rate = (491/1000000))

#lets set up the simulation model

covid_model<- function(time, groups, parameters){
  with(as.list(c(groups,parameters)),{
    dead_change <- sick * death_rate
    sick_change <- sick * infection_rate
    health_change <- - (sick_change+dead_change)
    
   
    
    
    #more sick people means more infection
    if(time >= 1){
      infection_rate <- infection_rate + sick_change
      
    }
    
    #limited health care capacity, assuming that all health care locations operate at the max capacity
    # 10 new patients with a new disease breaks the system, so the death starts to rise exponentially
    
    if(infection_rate > 5){
      death_rate<- death_rate + sick_change
    }
    
    return(list(c(health_change,sick_change,dead_change),infection_rate = infection_rate, death_rate = death_rate))
  })
}

data<- data.frame(deSolve::dede(y = groups, times = time,func = covid_model, parms = parameters, method = "lsodar") )


data_round<- data %>% mutate(across(c(sick,killed),round))

data_long<- data_round %>% pivot_longer(-time, names_to = "variable") %>% filter(variable %in% c("killed","sick"))

ggplot(data_long, aes(time, value, color = variable))+geom_point(aes(color = variable))+theme_minimal()

#end of the year score:

## sick: 6575
## dead: 134
