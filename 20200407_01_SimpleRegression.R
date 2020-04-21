install.packages("ALSM")
library("ALSM")
data("TolucaCompany")
View(TolucaCompany)

# exercise 1:
plot(TolucaCompany$x, TolucaCompany$y)
cor(TolucaCompany$x, TolucaCompany$y)

# exercise 2:
aa<-lm(y~x, data=TolucaCompany)
plot(y~x, data= TolucaCompany)
abline(coef(aa))
summary(aa)
# exercise 3:
predict(aa, data.frame(x=65))
