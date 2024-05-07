summary(trees)
lm(Volume ~ Girth, data = trees)
treemodel <- lm(Volume ~ Girth, data = trees)
summary(treemodel)
