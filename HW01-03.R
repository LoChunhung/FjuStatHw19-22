#輔大應統所在職專班作業五及作業六
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

#exercise5 試呈現各縣市學生總人數是否存在差異?
#Step1. 修正升格六都後的縣市名稱
dfStud[,"縣市名稱"] <-gsub("12 高雄市","64 高雄市",dfStud[,"縣市名稱"])
dfStud[,"縣市名稱"] <-gsub("50 高雄市","64 高雄市",dfStud[,"縣市名稱"])
dfStud[,"縣市名稱"] <-gsub("19 臺中市","66 臺中市",dfStud[,"縣市名稱"])
dfStud[,"縣市名稱"] <-gsub("06 臺中市","66 臺中市",dfStud[,"縣市名稱"])
dfStud[,"縣市名稱"] <-gsub("11 臺南市","67 臺南市",dfStud[,"縣市名稱"])
dfStud[,"縣市名稱"] <-gsub("21 臺南市","67 臺南市",dfStud[,"縣市名稱"])
dfStud[,"縣市名稱"] <-gsub("03 桃園市","68 桃園市",dfStud[,"縣市名稱"])
dfStud[,"縣市名稱"] <-gsub("30 臺北市","63 臺北市",dfStud[,"縣市名稱"])
dfStud[,"縣市名稱"] <-gsub("01 新北市","65 新北市",dfStud[,"縣市名稱"])

#Step2. 計算縣市匯總並透過piechart來了解學生人數占比:
#結論.  6個直轄市的學生人數佔了接近總學生數的75%
dfAmtByCity <- aggregate.data.frame(dfStud$"總計", list(SchName = dfStud$"縣市名稱"), FUN = "sum")
dfOdrBySAmt <- dfAmtByCity[order(dfAmtByCity$x, decreasing = TRUE),]
pie(dfOdrBySAmt$x, labels = (dfOdrBySAmt$SchName), main = "各縣市學生比例")

#北(新竹以北),中(嘉義以北),南,東及離島學生總人數是否存在差異?
#北中南三區域學生總人數遠高於東部與離島，而北部學生總人數占學生總人數一半
dfStudArea <- dfAmtByCity
dfStudArea$Area <- c("北","北","中","中","中","中","中","南","東","東","離","北","北","中","北","南","北","中","南","北","離")
#dfOrderByCityNo$SchName <-factor(dfStudArea$Area)
aggregate(dfStudArea$x, by=list(TW_Area=dfStudArea$Area), FUN=sum)

#exercise6 試問淡江大學學士班最近四年男女比例是否發生變化?
# 每年男性學生比例逐步提高
dfDJUnv<-dfStud[dfStud[,2] == "淡江大學" & dfStud[,4] == "B 學士",c(2,8:15) ]
MFAmt <- as.matrix.data.frame(rowsum(dfDJUnv[,2:9], group = dfDJUnv$"學校名稱"))
MFRatio<-c("淡1男女比"=(MFAmt[1]/MFAmt[2]),"淡2男女比"=(MFAmt[3]/MFAmt[4]),"淡3男女比"=(MFAmt[5]/MFAmt[6]),"淡4男女比"=(MFAmt[7]/MFAmt[8]))
barplot(MFRatio,col = 1:4)
