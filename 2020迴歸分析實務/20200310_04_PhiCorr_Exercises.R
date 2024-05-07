# Phi correlation 
library(psych)
class <-c(0,0,0,0,1,1,0,1,1,1)
gender<-c(1,1,0,1,1,1,0,0,1,1)
df<-table(class, gender)
phi(df)