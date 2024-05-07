install.packages("UsingR")
library("UsingR")
View(Galton)
y <- Galton$child
x <- Galton$parent
summary(lm(y~x))


#%利用公式確認迴歸係數
# formula 1. deviation from the mean(Xi-Xbar)
y <-Galton$child
x <-Galton$parent
beta1 <- cor(y,x) * sd(y)/sd(x)
beta0 <- mean(y) - beta1*mean(x)
rbind(c(beta0,beta1),coef(lm( y~ x)))

# formula 2. (Xi- Xbar) , (Yi- Ybar) 去中心化
yc <- y- mean(y)
xc <- x - mean(x)
beta1<- sum(yc*xc)/sum(xc^2)
c(beta1, coef(lm(y~x))[2])

# formula 3.標準化資料 ( Xi-Xbar) / Sx , (Yi-Ybar)/ Sy) => beta1 = corr(x,y)
yn <- (y- mean(y))/sd(y)
xn <- (x- mean(x))/sd(x)
c(cor(y,x), cor(yn, xn), coef(lm(yn ~xn))[2])

# formula 4. xy腳色互換
beta1 <- cor(y, x) * sd(x) /sd(y)
beta0 <- mean(x) - beta1*mean(y)
rbind(c(beta0,beta1), coef(lm(x~y)))

%