getwd()
setwd("C:\\Datasets\\Applied_Regression_Analysis")
# install.packages("readxl") # 安裝並載入可直接讀取excel的package
library("readxl")
UniStudent <- read_excel("106_student.xls")
class(UniStudent) # 確認是否為特殊物件

dfStud <- data.frame(UniStudent) # 調整為dataframe資料類型
class(dfStud)
rm(UniStudent) #刪除舊有資料集
ls() #檢查現有的list物件

#整理資料，將有關學生人數部分的欄位由文字型別轉為數值型別
for(i in 6:23){
  dfStud[,i] <-gsub("-","0",dfStud[,i])
  dfStud[,i]<-as.numeric(dfStud[,i])
}
#Exercise 1
#求平均值
mean_arr<- aggregate.data.frame(dfStud$"男生計",
                     list( Bachelor = dfStud[,"等級別"] == "B 學士",
                           DayCourse = dfStud[,3] == "D 日"), FUN = "mean")
print(mean_arr[ mean_arr$Bachelor & mean_arr$DayCourse,"x"  ])
#求變異數
sd_arr<-aggregate.data.frame(dfStud$"男生計",
                     list( Bachelor = dfStud[,4] == "B 學士",
                           DayCourse = dfStud[,3] == "D 日"), FUN = "sd")
print(sd_arr[ mean_arr$Bachelor & mean_arr$DayCourse,"x"  ])
#求峰度與偏度
#install.packages("moments") #安裝moments pacakge
library("moments")
skewness_tbl<- aggregate.data.frame(dfStud$"男生計",
                     list( Bachelor = dfStud[,"等級別"] == "B 學士",
                           DayCourse = dfStud[,3] == "D 日"), FUN = "skewness")
print(skewness_tbl[ skewness_tbl$Bachelor & skewness_tbl$DayCourse,"x"  ])
kurtosis_tbl<- aggregate.data.frame(dfStud$"男生計",
                     list( Bachelor = dfStud[,"等級別"] == "B 學士",
                           DayCourse = dfStud[,3] == "D 日"), FUN = "kurtosis")
print(kurtosis_tbl[kurtosis_tbl$Bachelor & kurtosis_tbl$DayCourse,"x"  ])

#Exercise 2
Stud_TTL <-aggregate.data.frame(dfStud$"總計", list(SchName = dfStud$"學校名稱"), FUN = "sum")
Stud_TTL <- Stud_TTL[order(Stud_TTL$x, decreasing = TRUE),]
head(Stud_TTL,5)
Stud_TTL[25,]
