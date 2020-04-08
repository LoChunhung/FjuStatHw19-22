#點2系列相關係數(Point-biserial Correlation)
#因名目尺度的特性不具備連續變數的正負性質，造成正負號無法代表正負相關
library(ltm)
vocabulary <- c(12,13,15,17,20,60,63,65,70,75)
class<-c(0,0,0,0,1,1,0,1,1,1) # 0,1代表性別
biserial.cor(vocabulary,class)
cor.test(vocabulary,class)