#課程練習
#default R datasets: trees
summary(trees)

cor(trees$Girth, trees$Volume)
# the value is very close to 1, 
# which indicates a very strong positive
# correlation between tree girth and tree
# volume. This means that trees with a
# larger girth tend to have a larger volume

cor(trees)
# Notice that the values along the
# diagnoal of the matrix are all
# equal to 1, because a variable always
# correlates perfectly with itself.

#two-tails T test
cor.test(trees$Girth, trees$Volume)

# The correlation is estimated at 0.967,
# with a 95% confidence interval of 0.932 to 0.984.
# This mean that as tree girth increases, 
# tree volume tends to increase also.
# because the p-value of 2.2e-16 
# is much less than the significance level
# of 0.05, we can reject the null hypothesis 
# that there is no correlation between girth and volume,
# in favor of the alternative hypothesis 
# that the two variables are correlated.

# self-exercise
# example:
# (x,y)= (-2,4), (-1,1), (0,0), (1,2), (2,4)
x = c(-2,-1,0,1,2)
y = c(4,1,0,1,4)
cor(x,y)
cor.test(x,y)

plot(x,y)
