fit<- lm(Volume~Girth, trees)
names(fit)
coef(fit)
fit$residuals
par(mfcol=c(2,2))
plot(fit)
install.packages("car")
library(car)
