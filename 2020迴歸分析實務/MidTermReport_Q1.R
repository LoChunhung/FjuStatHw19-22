getwd()
setwd("C:/Users/Chunhung.Lo/Documents/Projects/FJCU2020_RegressionAnalysis")
# Section Tidy Data -Start
#install.packages("readxl") # 安裝並載入可直接讀取excel的package
library("readxl")
UniStudent <- read_excel("108_student.xls",skip = 2)
class(UniStudent) # 確認是否為特殊物件
dfStud <- data.frame(UniStudent) # 調整為dataframe資料類型
class(dfStud)
rm(UniStudent) #刪除舊有資料集
ls() #檢查現有的list物件

for(i in 6:23){
  dfStud[,i] <-gsub("-","0",dfStud[,i])
  dfStud[,i]<-as.numeric(dfStud[,i])
} #整理資料，將有關學生人數部分的欄位由文字型別轉為數值型別

dfSD1 <- dfStud[(dfStud$"日間.進修別" == 'D 日' & dfStud$"體系別" == "1 一般"),]
# subset(dfStud, (dfStud$"日間.進修別" == 'D 日' & dfStud$"體系別" == "1 一般")) #驗證輸出 
#Section Tidy Data -End
#Section- Question 1
# Q1-1
dfSD1_UG <- dfSD1[dfSD1$"等級別" == "B 學士",c("學校名稱","總計")]
names(dfSD1_UG)[2] <- "學士班人數" #更名
dfSD1_G <- dfSD1[dfSD1$"等級別" == "M 碩士",c("學校名稱","總計")]
names(dfSD1_G)[2] <- "碩士班人數"  #更名
Q11 <- merge(dfSD1_UG,dfSD1_G, by = "學校名稱")

plot(Q11$"學士班人數", Q11$"碩士班人數" , xlab = "學士班人數", ylab = "碩士班人數")
cor(Q11[,c(2,3)])
#pearson 
cor.test(Q11$"學士班人數", Q11$"碩士班人數")
#spearman
cor.test(Q11$"學士班人數", Q11$"碩士班人數", method = "spearman")

#Q1-2 - 2個2元變數間的關係，使用 Phi correlation coefficient
library(psych)
#library(ltm)
dfSD2 <- dfSD1[, c(1:2,4:7)]
dfSD2["公私立"] = "私立"
dfSD2[grepl(c("國立"),dfSD1$"學校名稱"), "公私立"] <- "公立"
dfSD2[grepl(c("市立"),dfSD1$"學校名稱"), "公私立"] <- "公立"
#相關係數(Phi correlation coefficient)
dfPublicSex<-aggregate.data.frame(dfSD2[c("男生計","女生計")],by = list("公私立" = dfSD2$"公私立"),sum)
rownames(dfPublicSex) = dfPublicSex$'公私立'
dfPublicSex = dfPublicSex[-1]
phi(dfPublicSex) #結果女性就讀私立學校的比率高於就讀公立學校呈現弱相關。


#Q1-3 -欲了解台大,政大,清大,交大,輔大,銘傳,文化各校學生人數的結構差異
#學士,碩士,博士的人數比例差異(不計在職專班)
#試以合適的圖形呈現並解釋之
#library(data.table)
dfSD3<-subset(dfSD1,dfSD1$"等級別" != "X 4+X", 1:5)
x <- c("0001","0002","0003","0007","1002","1006", "1016" )
C6comp<-do.call(rbind,
                lapply(x, function(x) subset(dfSD3 ,dfSD3$"學校代碼" == x, 1:5))
                )

y <- c("B 學士","M 碩士","D 博士")
C6comp2<-do.call(cbind,
                 lapply(y, function(y) subset(C6comp ,C6comp$"等級別" == y, c(2,5)))
)
C6comp2<-C6comp2[  c(-3,-5)]
names(C6comp2)<- c("SchName","B","M","D")

C6comp2["SchName"] <- c("政大","清大","台大","交大","輔大","文化","銘傳")
row.names(C6comp2) <- c(2,3,1,4,5,6,7)

barplot(cbind(B,M,D) ~ SchName, data = C6comp2[order(row.names(C6comp2),decreasing = FALSE),],
              legend = c("學","碩","博"),args.legend = list(x = "topleft")
        ,ylim = c(0,40000), ylab = "總學生人數", xlab = "大學名稱")

par(mfrow = c(2,4))
X <- c("0003","0001","0002","0007","1002","1006","1016")
for (s in X) {
    print(s)
    lapply(s, function(s) pie(C6comp[C6comp$"學校代碼" == s,"總計"],
                              labels = C6comp[C6comp$"學校代碼" == s,"等級別"],
                              main = C6comp[C6comp$"學校代碼"== s,"學校名稱"][1]
                              ) 
           )
}

# barplot(C6comp$"總計" ~ C6comp$"等級別", data = C6comp)
# barplot(GNP ~ Year, data = longley)
# View(longley)
# barplot(cbind(Employed, Unemployed) ~ Year, data = longley)


# Data tidy
# method1:lapply and do.call()
# method2: package:data.table , lappy and %>% 
# C6comp <- (lapply(x, 
#                   function(x) subset(dfStud,dfStud$"學校代碼" == x, 1:5)) %>% 
#              do.call(rbind, .))
#Q1-2 
##觀念錯誤
# biserial.cor(dfSD2$"男生計", dfSD2$"公私立")
# biserial.cor(dfSD2$"女生計", dfSD2$"公私立")
# dfSM<-aggregate.data.frame(dfSD2["男生計"],by = list("公私立" = dfSD2$"公私立", "學校名稱" = dfSD2$"學校名稱"),sum)
# biserial.cor(dfSM$"男生計", dfSM$"公私立")
# dfSF<-aggregate.data.frame(dfSD2["女生計"],by = list("公私立" = dfSD2$"公私立", "學校名稱" = dfSD2$"學校名稱"),sum)
# biserial.cor(dfSF$"女生計", dfSF$"公私立")

