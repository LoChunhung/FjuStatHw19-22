# Spearman 等級相關係數
# Spearman Rand Order Correlation Coefficient
# Appilied to data from two different population
vocabulary <- c(12,13,15,17,20,60,63,65,70,75)
reading    <- c(38,40,51,58,65,68,70,72,80,86)
plot(vocabulary, reading)
#圖形尚無法理解相關性
cor(vocabulary, reading, method = "spearman")
# 1代表絕對正相關字彙量越多，閱讀能力越強

cor.test(vocabulary, reading, alternative = "two.sided", method = "spearman", exact = FALSE)
# 虛無假設不成立
